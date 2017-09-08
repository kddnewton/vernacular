require 'test_helper'

class DateSigilTest < Minitest::Test
  def test_sigil
    assert_equal Date.parse('2017-01-01'), ~d(January 1st, 2017)
  end

  def test_variable_sigil
    value = '2017-01-01'
    assert_equal Date.parse(value), ~d(value)
  end
end
