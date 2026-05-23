# frozen_string_literal: true

# Helpers for stubbing top-level (Object) constants in tests. Rails' built-in
# `stub_const` requires a parent module argument; RSpec's takes just the name.
# This module bridges that gap.
module ConstantStubbingHelpers
  def with_const(name, value)
    name = name.to_sym
    had_previous = Object.const_defined?(name, false)
    previous = Object.const_get(name) if had_previous
    Object.send(:remove_const, name) if had_previous
    Object.const_set(name, value)
    yield
  ensure
    Object.send(:remove_const, name) if Object.const_defined?(name, false)
    Object.const_set(name, previous) if had_previous
  end
end

module ActiveSupport
  class TestCase
    include ConstantStubbingHelpers
  end
end
