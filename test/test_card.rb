require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestCard < Test::Unit::TestCase
  def setup
    # testing various input formats for cards
    @c1 = Card.new("9c")
    @c2 = Card.new("TD")
    @c3 = Card.new("jh")
    @c4 = Card.new("qS")
  end

  def test_build_from_card
    assert_equal("9c", Card.new(@c1).to_s)
  end

  def test_class_face_value
    assert_nil(Card.face_value('L'))
    assert_equal('A', Card.face_value('A'))
  end

  def test_build_from_value
    assert_equal(@c1, Card.new(7))
    assert_equal(@c2, Card.new(21))
    assert_equal(@c3, Card.new(35))
    assert_equal(@c4, Card.new(49))
  end

  def test_face
    assert_equal('9', @c1.face)
    assert_equal('T', @c2.face)
    assert_equal('J', @c3.face)
    assert_equal('Q', @c4.face)
  end

  def test_suit
    assert_equal('c', @c1.suit)
    assert_equal('d', @c2.suit)
    assert_equal('h', @c3.suit)
    assert_equal('s', @c4.suit)
  end

  def test_comparison
    assert(@c1 < @c2)
    assert(@c3 > @c2)
  end

  def test_equals
    c = Card.new("9h")
    assert_not_equal(@c1, c)
    assert_equal(@c1, @c1)
  end

  def test_hash
    assert_equal(15, @c1.hash)
  end
end
