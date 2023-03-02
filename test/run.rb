#!/usr/bin/env ruby

$VERBOSE = true

$LOAD_PATH.unshift("lib", "test")

Dir.glob("test/**/test_*.rb") do |test_rb|
  require File.expand_path(test_rb)
end
