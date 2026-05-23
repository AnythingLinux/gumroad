# frozen_string_literal: true

require "spec_helper"

RSpec.describe "MySQL missing table handler" do
  it "retries query if table is missing" do
    client = ActiveRecord::Base.connection_db_config
      .configuration_hash
      .slice(*%i[host username password database port socket encoding])
      .then { |conf| Mysql2::Client.new(conf) }

    stub_const("Mysql2::Client::MISSING_TABLE_GRACE_PERIOD", 2)

    client.query("DROP TABLE IF EXISTS `foo`, `bar`")
    client.query("CREATE TABLE `bar` (id int)")
    client.query("INSERT INTO `bar`(id) VALUES (1),(2),(3)")

    Thread.new do
      sleep 1
      client.query("RENAME TABLE `bar` TO `foo`")
    end

    values = nil
    expect do
      result = client.query("SELECT id FROM `foo`")
      values = result.map { |row| row["id"].to_i }
    end.to output(/Error: missing table, retrying in/).to_stderr

    expect(values).to contain_exactly(1, 2, 3)
  ensure
    client.query("DROP TABLE IF EXISTS `foo`, `bar`")
    client.close rescue nil
  end

  it "retries dropping a table blocked by a foreign key constraint with foreign key checks disabled" do
    client = ActiveRecord::Base.connection_db_config
      .configuration_hash
      .slice(*%i[host username password database port socket encoding])
      .then { |conf| Mysql2::Client.new(conf) }

    client.query("DROP TABLE IF EXISTS `mysql_missing_table_handler_child`")
    client.query("DROP TABLE IF EXISTS `mysql_missing_table_handler_parent`")
    client.query("CREATE TABLE `mysql_missing_table_handler_parent` (`id` int NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB")
    client.query(<<~SQL)
      CREATE TABLE `mysql_missing_table_handler_child` (
        `id` int NOT NULL,
        `parent_id` int NOT NULL,
        PRIMARY KEY (`id`),
        CONSTRAINT `fk_mysql_missing_table_handler_parent`
          FOREIGN KEY (`parent_id`) REFERENCES `mysql_missing_table_handler_parent` (`id`)
      ) ENGINE=InnoDB
    SQL

    expect do
      client.query("DROP TABLE `mysql_missing_table_handler_parent`")
    end.to output(/Error: foreign key constraint blocked table drop/).to_stderr

    expect(client.query("SELECT @@FOREIGN_KEY_CHECKS AS checks").first["checks"]).to eq 1
    expect(client.query("SHOW TABLES LIKE 'mysql_missing_table_handler_parent'").to_a).to be_empty
  ensure
    if client
      begin
        client.query("SET FOREIGN_KEY_CHECKS = 0")
        client.query("DROP TABLE IF EXISTS `mysql_missing_table_handler_child`")
        client.query("DROP TABLE IF EXISTS `mysql_missing_table_handler_parent`")
      rescue StandardError
        nil
      ensure
        client.query("SET FOREIGN_KEY_CHECKS = 1") rescue nil
        client.close rescue nil
      end
    end
  end
end
