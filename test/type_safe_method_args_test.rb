require 'test_helper'

class TypeSafeMethodArgsTest < Minitest::Test
  def test_normal_args
    assert_equal 10, add5(5)
  end

  def test_raises_on_invalid_type
    assert_raises(ArgumentError) { add5('') }
  end

  private

  def add5(num : Integer)
    num + 5
  end
end
