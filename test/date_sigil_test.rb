require 'test_helper'

class DateSigilTest < Minitest::Test
  def test_sigil
    assert_equal Date.parse('2017-01-01'), ~d(January 1st, 2017)
  end
end
