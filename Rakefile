# frozen_string_literal: true

require_relative "app/init"



load "tasks/rubocop.rake"
load "tasks/assets.rake"
load "tasks/db.rake"
load "tasks/dev.rake"

task :test do
  require "test/unit"
  require "test/unit/ui/console/testrunner"
  
  test_files = Dir["test/**/*_test.rb"]
  if test_files.empty?
    puts "No tests found."
  else
    test_files.each { |file| require File.expand_path(file) }
  end
end