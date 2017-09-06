require 'test_helper'

class TypedMethodReturnsTest < Minitest::Test
  def test_normal
    assert_equal 5, echo(5)
  end

  def test_raises_on_invalid_type
    assert_raises(RuntimeError) { echo('') }
  end

  private

  def echo(value) = Integer
    value
  end
end
