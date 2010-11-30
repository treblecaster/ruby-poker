class Card
  SUITS = ['c', 'd', 'h', 's']
  FACES = ('2' .. '9').to_a + [ 'T', 'J', 'Q', 'K', 'A' ]
  DECK = SUITS.product(FACES)

  def Card.face_value(face)
    face.upcase!
    FACES.index(face)
  end

  private

  def build_from_face_suit(face, suit)
    suit.downcase!
    face.upcase!

    raise ArgumentError, "Invalid suit: #{suit}" unless SUITS.include?(suit)
    raise ArgumentError, "Invalid face: #{face}" unless FACES.include?(face)

    @suit  = suit
    @face  = face
  end

  def build_from_face_suit_values(face, suit)
    build_from_face_suit(FACES[face], SUITS[suit])
  end

  def build_from_value(value)
    build_from_face_suit_values(value % FACES.size(), value / FACES.size())
  end

  def build_from_string(card)
    build_from_face_suit(card[0,1], card[1,1])
  end

  # Constructs this card object from another card object
  def build_from_card(card)
    @suit = card.suit
    @face = card.face
  end

  public

  def initialize(*value)
    if (value.size == 1)
      if (value[0].respond_to?(:to_card))
        build_from_card(value[0])
      elsif (value[0].respond_to?(:to_str))
        build_from_string(value[0])
      elsif (value[0].respond_to?(:to_int))
        build_from_value(value[0])
      end
    elsif (value.size == 2)
      if (value[0].respond_to?(:to_str) &&
          value[1].respond_to?(:to_str))
        build_from_face_suit(value[0], value[1])
      elsif (value[0].respond_to?(:to_int) &&
             value[1].respond_to?(:to_int))
        build_from_face_suit_values(value[0], value[1])
      end
    end
  end

  attr_reader :suit, :face
  include Comparable

  # Returns a string containing the representation of Card
  #
  # Card.new("7c").to_s                   # => "7c"
  def to_s
    @face + @suit
  end

  # If to_card is called on a `Card` it should return itself
  def to_card
    self
  end

  # Subtraction only makes sense when comparing face values
  def - card2
    FACES.index(@face) - FACES.index(card2.face)
  end

  # Compare the face value of this card with another card. Returns:
  # -1 if self is less than card2
  # 0 if self is the same face value of card2
  # 1 if self is greater than card2
  def <=> card2
    FACES.index(@face) <=> FACES.index(card2.face)
  end

  # Returns true if the cards are the same card. Meaning they
  # have the same suit and the same face value.
  def == card2
    @face == card2.face and @suit == card2.suit
  end
  alias :eql? :==

  # Compute a hash-code for this Card. Two Cards with the same
  # content will have the same hash code (and will compare using eql?).
  def hash
    DECK.index([@face, @suit]).hash
  end

end

