require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestPokerHand < Test::Unit::TestCase
  context "A PokerHand instance" do

    setup do
      @quads = PokerHand.new('Kc Kh Kd Ks Qs')
      @full_boat = PokerHand.new(["2H", "2D", "4C", "4D", "4S"])
      @flush = PokerHand.new("3D 6D 7D TD QD 5H 2S")
      @straight = PokerHand.new("8H 9D TS JH QC AS")
      @trips = PokerHand.new("2D 9C AS AH AC")
      @two_pair = PokerHand.new("As Ac Kc Kd 2s")
      @pair = PokerHand.new("As Ac Kc Qd 2s")
      @ace_high = PokerHand.new("As Jh 9c 7d 5s")
    end

    should "handle single card hands" do
      assert_equal(PokerHand.new('As').rank, @ace_high.rank)
    end

    should "handle two card hands" do
      assert_equal(PokerHand.new('As Ac').rank, @pair.rank)
    end

    should "handle three card hands" do
      assert_equal(PokerHand.new('As Ac Ah').rank, @trips.rank)
    end

    should "handle four card hands" do
      assert_equal(PokerHand.new('As Ac Kd Kh').rank, @two_pair.rank)
      assert_equal(PokerHand.new('As Ac Ad Ah').rank, @quads.rank)
    end

    should "handle lower case face card names" do
      assert_equal(0, PokerHand.new('kc kd') <=> PokerHand.new('Kc Kd'))
      assert_equal(0, PokerHand.new('kc kd') <=> PokerHand.new('Kc KD'))
    end
    
    should "handle hands without space" do
      assert_equal(0, PokerHand.new('KcKd') <=> PokerHand.new('Kc Kd'))
      assert_equal(0, PokerHand.new('KcKd9d') <=> PokerHand.new('Kc Kd 9d'))
    end
    
    should "raise a clear error with invalid cards" do
      e = assert_raises(ArgumentError) { PokerHand.new('Fc') }
      assert_match(/"F"/, e.message)
      e = assert_raises(ArgumentError) { PokerHand.new('Tp') }
      assert_match(/"p"/, e.message)
    end

    should "sort using rank" do
      assert_equal("As Ah Ac 9c 2d", @trips.sort_using_rank)
      assert_equal("4s 4d 4c 2h 2d", @full_boat.sort_using_rank)
      assert_equal("Qd Td 7d 6d 3d 2s 5h", @flush.sort_using_rank)
      assert_equal("Qc Jh Ts 9d 8h As", @straight.sort_using_rank)

      assert_equal("As Ah 3d 3c Kd", PokerHand.new("AS AH KD 3D 3C").sort_using_rank)
      assert_equal("As Ah 3d 3c 2d", PokerHand.new("2D AS AH 3D 3C").sort_using_rank)
    end

    should "return card sorted by face value" do
      assert_equal(['A', 'A', 'A', '9', '2'],
                   @trips.by_face.hand.collect {|c| c.face})
    end

    should "return cards sorted by suit" do
      assert_equal(['s', 'h', 'd', 'c', 'c'],
                   @trips.by_suit.hand.collect {|c| c.suit})
    end

    should "return just the face values of the cards" do
      assert_equal(['2', '9', 'A', 'A', 'A'], @trips.face_values)
    end

    should "recognize a straight flush" do
      assert !@flush.straight_flush?
      assert !@straight.straight_flush?
      assert PokerHand.new("8H 9H TH JH QH AS").straight_flush?
    end

    should "recognize a royal flush" do
      assert !@flush.royal_flush?
      assert PokerHand.new("AD KD QD JD TD").royal_flush?
    end

    should "recognize a flush" do
      assert @flush.flush?
      assert !@trips.flush?
    end

    should "recognize a four of a kind" do
      assert !@trips.four_of_a_kind?
      assert PokerHand.new("AD 9C AS AH AC")
    end

    should "recognize a full house" do
      assert !@trips.full_house?
      assert @full_boat.full_house?
    end

    should "recognize a straight" do
      assert @straight.straight?
      assert PokerHand.new("AH 2S 3D 4H 5D").straight?
    end

    should "recognize a three of a kind" do
      assert @trips.three_of_a_kind?
    end

    should "recognize a two pair" do
      assert PokerHand.new("2S 2D TH TD 4S").two_pair?
      assert !PokerHand.new("6D 7C 5D 5H 3S").two_pair?
    end

    should "recognize a pair" do
      assert !PokerHand.new("5C JC 2H 7S 3D").pair?
      assert PokerHand.new("6D 7C 5D 5H 3S").pair?
    end

    should "recognize a hand with the rank highest_card" do
      # hard to test, make sure it does not return null
      assert PokerHand.new("2D 4S 6C 8C TH").highest_card?
    end

    should "have an instance variable hand that is an array of Cards" do
      assert_instance_of Card, @trips.hand[0]
    end

    should "return the hand's rating as a string" do
      assert_equal "Three of a kind", @trips.hand_rating
      assert_equal "Full house", @full_boat.hand_rating
    end

    should "respond to rank" do
      # rank is an alias for hand_rating
      assert_respond_to @trips, :rank
    end

    should "return the hand as a string" do
      assert_equal("2d 9c As Ah Ac", @trips.just_cards)
    end

    should "return the hand's score" do
      assert_equal([4, 'A', '9', '2'], @trips.score[0])
    end

    should "be able to match regular expressions" do
      assert_match(/9c/, @trips.to_s)
      assert_no_match(/AD/, @trips.to_s)
    end

    should "return the correct number of cards in the hand" do
      assert_equal(0, PokerHand.new.size)
      assert_equal(1, PokerHand.new("2c").size)
      assert_equal(2, PokerHand.new("2c 3d").size)
    end

    should "be comparable to other PokerHands" do
      hand1 = PokerHand.new("5C JC 2H 5S 3D")
      hand2 = PokerHand.new("6D 7C 5D 5H 3S")
      assert_equal(1, hand1 <=> hand2)
      assert_equal(-1, hand2 <=> hand1)
    end

    should "be considered equal to other poker hands that contain the same cards" do
      assert_equal(0, @trips <=> @trips)

      hand1 = PokerHand.new("Ac Qc Ks Kd 9d 3c")
      hand2 = PokerHand.new("Ah Qs 9h Kh Kc 3s")
      assert_equal(0, hand1 <=> hand2)
    end

    should "be able to insert new cards into the hand" do
      ph = PokerHand.new()
      ph << "Qd"
      ph << Card.new("2D")
      ph << ["3d", "4d"]
      assert_equal("Qd 2d 3d 4d", ph.just_cards)
    end

    should "be able to delete a card" do
      ph = PokerHand.new("Ac")
      ph.delete("Ac")
      assert_equal(Array.new, ph.hand)
    end

    should "detect the two highest pairs when there are more than two" do
      ph = PokerHand.new("7d 7s 4d 4c 2h 2d")
      assert_equal([3, '7', '4', '2'], ph.two_pair?[0])
      # Explanation of [3, 6, 3, 1]
      # 3: the number for a two pair
      # 7: highest pair is two 7's
      # 4: second highest pair is two 4's
      # 2: kicker is a 2
    end

    context "when duplicates are allowed" do
      setup do
        PokerHand.allow_duplicates = true
      end

      should "create a PokerHand of unique cards" do
        uniq_ph = PokerHand.new("3s 4s 3s").uniq
        assert_instance_of(PokerHand, uniq_ph)  # want to be sure uniq hands back a PokerHand
        assert_contains(uniq_ph.hand, Card.new('3s'))
        assert_contains(uniq_ph.hand, Card.new('4s'))
      end

      should "allow five of a kind" do
        # there is no five of a kind. This just tests to make sure
        # that ruby-poker doesn't crash if given 5 of the same card
        ph = PokerHand.new("KS KS KS KS KS")
        assert_equal("Four of a kind", ph.rank)
      end

      should "allow duplicates on initialize" do
        assert_nothing_raised RuntimeError do
          PokerHand.new("3s 3s")
        end
      end

      should "allow duplicate card to be added after initialize" do
        ph = PokerHand.new("2d")
        ph << "2d"
        assert_equal("2d 2d", ph.just_cards)
      end
    end

    context "when duplicates are not allowed" do
      setup do
        PokerHand.allow_duplicates = false
      end

      should "not allow duplicates on initialize" do
        PokerHand.allow_duplicates = false

        assert_raise RuntimeError do
          PokerHand.new("3s 3s")
        end

        PokerHand.allow_duplicates = true
      end

      should "not allow duplicates after initialize" do
        PokerHand.allow_duplicates = false

        ph = PokerHand.new("2d")
        assert_raise RuntimeError do
          ph << "2d"
        end

        PokerHand.allow_duplicates = true
      end
    end
    
    should "have an each method" do
      cards = []
      @straight.each do |card|
        cards << card
      end
      assert_equal @straight.to_a, cards
    end
    
    should "be Enumerable" do
      assert PokerHand.include?(Enumerable)
    end
  end
  
  context "addition" do
    setup do
      @base = PokerHand.new('Ac Kc')
    end
    
    should "work with a string" do
      assert_equal PokerHand.new('Ac Kc Qc'), @base + 'Qc'
    end
    
    should "work with a card" do
      assert_equal PokerHand.new('Ac Kc Qc'), @base + Card.new('Qc')
    end
    
    should "work with a hand" do
      assert_equal PokerHand.new('Ac Kc Qc'), @base + PokerHand.new('Qc')
    end
    
    should "not affect receiver hand" do
      result = @base + 'Qc'
      assert_equal PokerHand.new('Ac Kc'), @base
    end

    should "not affect receiver cards" do
      result = @base + 'Qc'
      result.to_a.first.instance_eval { @face = Card.face_value('2') }
      assert_equal PokerHand.new('Ac Kc'), @base
    end
  end

  context "PokerHand#pair?" do

    should "return false with one card" do
      assert !PokerHand.new("2h").pair?
    end

    context "with a pair" do

      should "return 2, followed by the pair value" do
        assert_equal [2, '5'], PokerHand.new("5h 5s").pair?[0]
      end

      context "with a two card hand" do
        setup do
          @ph = PokerHand.new("5h 5s")
          @scoring = @ph.pair?[0]
        end

        should "return scoring with 2 entries" do
          assert_equal 2, @scoring.size
        end
      end

      context "with a three card hand" do
        setup do
          @ph = PokerHand.new("5h 5s 8s")
          @scoring = @ph.pair?[0]
        end

        should "return scoring with 3 entries" do
          assert_equal 3, @scoring.size
        end

        should "return the value of the kicker" do
          assert_equal '8', @scoring[2]
        end
      end

      context "with a four card hand" do
        setup do
          @ph = PokerHand.new("5h 5s 8s 7s")
          @scoring = @ph.pair?[0]
        end

        should "return scoring with 4 entries" do
          assert_equal 4, @scoring.size
        end

        should "return the values of the kickers" do
          assert_equal '8', @scoring[2]
          assert_equal '7', @scoring[3]
        end
      end

      context "with a five (or more) card hand" do
        setup do
          @ph = PokerHand.new("5h 5s 8s 7s 6s 2h")
          @scoring = @ph.pair?[0]
        end

        should "return scoring with 5 entries" do
          assert_equal 5, @scoring.size
        end

        should "return the values of the kickers" do
          assert_equal '8', @scoring[2]
          assert_equal '7', @scoring[3]
          assert_equal '6', @scoring[4]
        end
      end
    end

    context "without a pair" do
      should "return false" do
        assert !PokerHand.new("2h 3h").pair?
      end
    end
  end
  

  def assert_hand_match(expression, cards)
    hand = PokerHand.new(cards)
    assert hand.match?(expression), "#{cards} didn't match #{expression}"
  end
  
  def assert_hand_not_match(expression, cards)
    hand = PokerHand.new(cards)
    assert !hand.match?(expression), "#{cards} did match #{expression}"
  end
  
  context "matching expression" do
    should "match two faces" do
      assert_hand_match 'AA', 'Ah Ad'
      assert_hand_match 'Q8', 'Qc 8d'
    end

    should "not match two faces" do
      assert_hand_not_match 'T9', 'Tc 8s'
      assert_hand_not_match 'QQ', 'Tc 8s'
    end
    
    should "match unordered faces" do
      assert_hand_match 'K7', '7c Ks'
    end

    should "match suited when suited" do
      assert_hand_match 'Q8s', 'Qc 8c'
      assert_hand_match '56s', '5h 6h'
    end
    
    should "not match suited when offsuit" do
      assert_hand_not_match 'Q8s', 'Qc 8d'
      assert_hand_not_match '56s', '5h 6c'
    end

    should "match offsuit when offsuited" do
      assert_hand_match 'Q8o', 'Qc 8h'
      assert_hand_match '56o', '5h 6s'
    end
    
    should "not match offsuit when suited" do
      assert_hand_not_match 'Q8o', 'Qc 8c'
      assert_hand_not_match '56o', '5h 6h'
    end
    
    should "match pair min" do
      assert_hand_match 'JJ+', 'Jc Js'
      assert_hand_match '66+', 'Qc Qh'
      assert_hand_match 'JJ+', 'Ad Ac'
    end
    
    should "not match pair min" do
      assert_hand_not_match 'JJ+', 'Tc Ts'
      assert_hand_not_match '66+', 'Qc Kh'
      assert_hand_not_match 'AA+', '2d 2c'
    end
    
    should "match face min" do
      assert_hand_match 'AJ+', 'Ac Js'
      assert_hand_match 'AQ+', 'Ac Kc'
      assert_hand_match 'AJ+', 'Ac As'
      assert_hand_match 'QT+', 'Qc Ts'
      assert_hand_match 'QT+', 'Qc Qs'
      assert_hand_not_match 'QT+', 'Qc Ks' # sure? should be matched with KQ+?
      assert_hand_not_match 'AJ+', 'Ac Ts'
      assert_hand_not_match 'AJ+', 'Tc Ts'
    end
    
    should "match suited face min" do
      assert_hand_match 'AJs+', 'Ac Jc'
      assert_hand_match 'AQs+', 'Ac Kc'
      assert_hand_not_match 'AJs+', 'Ac As'
      assert_hand_match 'QTs+', 'Qc Tc'
      assert_hand_not_match 'QTs+', 'Qc Ts'
      assert_hand_not_match 'AJs+', 'Ac Qs'
    end
    
    should "match offsuit face min" do
      assert_hand_match 'AJo+', 'Ac Jd'
      assert_hand_match 'AQo+', 'Ac Kh'
      assert_hand_match 'AJo+', 'Ac As'
      assert_hand_match 'QTo+', 'Qc Td'
      assert_hand_not_match 'QTo+', 'Qc Tc'
      assert_hand_not_match 'AJo+', 'Ac Qc'
    end

    should "match face with 1 gap" do
      assert_hand_match '89+', '8c 9d'
      assert_hand_match '89+', '9c Td'
      assert_hand_match '89+', 'Tc Jd'
      assert_hand_match '89+', 'Ac Kd'
      assert_hand_not_match '89+', '8c Td'
      assert_hand_not_match '89+', 'Tc Td'
      assert_hand_not_match '89+', '7c 8d'
    end

    should "match face with 2 gaps" do
      assert_hand_match '8T+', '8c Td'
      assert_hand_match '8T+', 'Tc 8d'
      assert_hand_match '24+', '9c Jd'
      assert_hand_match '79+', 'Ac Qd'
      assert_hand_not_match '8T+', '8c 9d'
      assert_hand_not_match '8T+', 'Tc Td'
      assert_hand_not_match '8T+', 'Jc Ad'
      assert_hand_not_match '8T+', '7c 9d'
    end

    should "match face with many gaps" do
      assert_hand_match '8J+', '9c Qd'
      assert_hand_match '8Q+', '9c Kd'
      assert_hand_match '8K+', 'Ac 9d'
      assert_hand_not_match '8J+', '7c Td'
    end

    should "match face gap with suit" do
      assert_hand_match '89s+', '9c Tc'
      assert_hand_not_match '89s+', '9c Td'
      assert_hand_match '89o+', '9c Th'
      assert_hand_not_match '89o+', '9d Td'
    end
    
    [
      %w(),
      %w(Ac),
      %w(Ac Kc Qc),
      %w(Ac Kc Qc Jc Tc),
    ].each do |cards|
      should "raise an error if the number of cards is #{cards.size}" do
        hand = PokerHand.new(cards)
        assert_raises RuntimeError do
          hand.match?('AA')
        end
      end
    end
    
    should "raise an error with invalid expression" do
      hand = PokerHand.new("Ac Kc")
      assert_raises ArgumentError do
        hand.match? "foo"
      end

      assert_raises ArgumentError do
        hand.match? ""
      end
    end
  end

end
