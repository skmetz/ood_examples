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
      DATA.shuffle
    when :mostly_random
      DATA[0...-1].shuffle << DATA.last
    else
      DATA
    end
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

# Now we have 3 choices, so can't use a boolean.
# Switched to a symbol and case statement.
# Here we're explicit about the default where before we were not, but it
# was still there, the code obscured it.

# Here I know the reason I might switch, and the thing that should happen
# when each switch happens.
