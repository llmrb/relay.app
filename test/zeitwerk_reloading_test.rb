# frozen_string_literal: true

require "tmpdir"
require "test/unit"
require "zeitwerk"

class ZeitwerkReloadingTest < Test::Unit::TestCase
  def test_loader_can_reload_updated_constants_when_reloading_is_enabled
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "example.rb"), <<~RUBY)
        class Example
          def self.value
            :before
          end
        end
      RUBY

      loader = Zeitwerk::Loader.new
      loader.push_dir(dir)
      loader.enable_reloading
      loader.setup

      assert_equal :before, Example.value

      File.write(File.join(dir, "example.rb"), <<~RUBY)
        class Example
          def self.value
            :after
          end
        end
      RUBY

      loader.reload

      assert_equal :after, Example.value
    ensure
      loader&.unload
      Object.send(:remove_const, :Example) if Object.const_defined?(:Example)
    end
  end
end
