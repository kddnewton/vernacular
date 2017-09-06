require 'test_helper'

class NumberSigilTest < Minitest::Test
  def test_sigil
    assert_equal 86400, ~n(24 * 60 * 60)
  end
end
