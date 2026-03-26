# frozen_string_literal: true

desc "Run tests"
task :test do
  abort "no tests found" if Dir["test/**/*_test.rb"].empty?

  sh "bundle exec ruby -Itest -e 'Dir[""test/**/*_test.rb""].sort.each { |file| require File.expand_path(file) }'"
end
