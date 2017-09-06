require 'test_helper'

class URISigilTest < Minitest::Test
  def test_sigil
    assert_equal URI('https://github.com/kddeisz/vernacular'),
                 ~u(https://github.com/kddeisz/vernacular)
  end
end
