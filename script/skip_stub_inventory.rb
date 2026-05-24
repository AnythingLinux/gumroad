#!/usr/bin/env ruby
# frozen_string_literal: true

# Regenerate skip-stub inventory counts for docs/migration-backfill.md.
#
# Tracks issue #5257. Definition of done: this script reports 0 skip-stubs.
#
# Usage:
#   bin/rails runner script/skip_stub_inventory.rb        # print summary
#   ruby script/skip_stub_inventory.rb --list             # list every file
#   ruby script/skip_stub_inventory.rb --check            # exit 1 if any skips remain
#
# Counts lines matching /^\s*skip\b/ in test/**/*_test.rb.

require "find"

TEST_DIR = File.expand_path("../test", __dir__)
SKIP_RE = /^\s*skip\b/

def collect
  results = []
  Find.find(TEST_DIR) do |path|
    next unless path.end_with?("_test.rb")
    skips = File.foreach(path).count { |line| line =~ SKIP_RE }
    next if skips.zero?
    rel = path.sub("#{File.expand_path("..", __dir__)}/", "")
    results << [rel, skips]
  end
  results.sort_by { |_, n| -n }
end

mode = ARGV.first

inventory = collect
total_files = inventory.size
total_skips = inventory.sum { |_, n| n }

case mode
when "--list"
  inventory.each { |path, n| puts "#{n}\t#{path}" }
when "--check"
  if total_skips.zero?
    puts "✓ no skip-stubs remain"
    exit 0
  else
    warn "✗ #{total_skips} skip(s) across #{total_files} file(s) — see docs/migration-backfill.md (#5257)"
    exit 1
  end
else
  by_domain = inventory.group_by { |path, _| path.split("/")[1] }
  puts "Skip-stub inventory (#{total_files} files, #{total_skips} skips)"
  puts "-" * 60
  by_domain.sort_by { |_, files| -files.size }.each do |domain, files|
    skips = files.sum { |_, n| n }
    printf "  %-20s %4d files  %4d skips\n", "test/#{domain}/", files.size, skips
  end
end
