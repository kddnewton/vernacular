require 'test_helper'

class VersionTest < Minitest::Test
  def test_version
    refute_nil ::Vernacular::VERSION
  end
end
