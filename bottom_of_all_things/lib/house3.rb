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

  def initialize(order = nil)
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
    House.new(choice).line(12)
  end
end

puts "\n----\n"               + Controller.new.play_house
puts "\n--:random--\n"        + Controller.new.play_house(:random)
puts "\n--:mostly_random--\n" + Controller.new.play_house(:mostly_random)

# ----
# This is the horse and the hound and the horn that belonged to the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.

# --:random--
# This is the dog that worried the house that Jack built the malt that lay in the rat that ate the maiden all forlorn that milked the cat that killed the rooster that crowed in the morn that woke the horse and the hound and the horn that belonged to the man all tattered and torn that kissed the farmer sowing his corn that kept the priest all shaven and shorn that married the cow with the crumpled horn that tossed.

# --:mostly_random--
# This is the man all tattered and torn that kissed the cow with the crumpled horn that tossed the maiden all forlorn that milked the horse and the hound and the horn that belonged to the dog that worried the malt that lay in the rooster that crowed in the morn that woke the rat that ate the cat that killed the farmer sowing his corn that kept the priest all shaven and shorn that married the house that Jack built.

# Now we have 3 choices, so can't use a boolean.
# Switched to a symbol and case statement.
# Here we're explicit about the default where before we were not. It
# was there but the code obscured it.

# Here I know the reason I might switch and the thing that should happen
# when I do.
