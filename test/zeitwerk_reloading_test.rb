# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "test/unit"
require "zeitwerk"

class ZeitwerkReloadingTest < Test::Unit::TestCase
  def test_loader_reloads_updated_relay_constants
    Dir.mktmpdir do |dir|
      app_dir = File.join(dir, "app")
      routes_dir = File.join(app_dir, "routes")
      FileUtils.mkdir_p(routes_dir)

      File.write(File.join(routes_dir, "example.rb"), <<~RUBY)
        module Relay::Routes
          class Example
            def self.value
              :before
            end
          end
        end
      RUBY

      loader = Zeitwerk::Loader.new
      loader.push_dir(app_dir, namespace: Relay)
      loader.enable_reloading
      loader.setup

      assert_equal :before, Relay::Routes::Example.value

      File.write(File.join(routes_dir, "example.rb"), <<~RUBY)
        module Relay::Routes
          class Example
            def self.value
              :after
            end
          end
        end
      RUBY

      loader.reload

      assert_equal :after, Relay::Routes::Example.value
    ensure
      loader&.unload
    end
  end
end
