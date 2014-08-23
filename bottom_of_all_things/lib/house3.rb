class House
  DATA = [
    'the horse and the hound and the horn that belonged to',
    'the farmer sowing his corn that kept',
    'the rooster that crowed in the morn that woke',
    'the priest all shaven and shorn that married',
    'the man all tattered and torn that kissed',
    'the maiden all forlorn that milked',
    'the cow with the crumpled horn that tossed',
    'the dog that worried',
    'the cat that killed',
    'the rat that ate',
    'the malt that lay in',
    'the house that Jack built',
  ]

  attr_reader :pieces

  def initialize(order = :default)
    @pieces = initialize_pieces(order)
  end

  def recite
    (1..pieces.length).map {|i| line(i)}.join("\n")
  end

  def line(number)
    "This is #{phrase(number)}.\n"
  end

  private
  def phrase(number)
    pieces.last(number).join(" ")
  end

  def initialize_pieces(order)
    case order
    when :random
      Random.new.order(DATA)
    when :mostly_random
      MostlyRandom.new.order(DATA)
    else
      Default.new.order(DATA)
    end
  end
end


class Default
  def order(data)
    data
  end
end

class Random
  def order(data)
    data.shuffle
  end
end

class MostlyRandom
  def order(data)
    data[0...-1].shuffle << data.last
  end
end

class Controller
  def play_house(choice = nil)
    puts "\n--#{choice}--"
    puts House.new(choice).line(12)
  end
end


puts Controller.new.play_house
puts Controller.new.play_house(:default)
puts Controller.new.play_house(:random)
puts Controller.new.play_house(:mostly_random)


# Each branch of the case statement could become a polymorphic method in
# a class for the specific value in the condition.
#
# Here I talk argument 'order' and the only use I make of it is to choose
# a class in #initialize_pieces.  This choice should be made before we get here.
