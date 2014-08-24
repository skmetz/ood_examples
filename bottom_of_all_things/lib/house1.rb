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

  def initialize(random)
    @pieces = DATA.shuffle if random
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

  def pieces
    @pieces ||= DATA
  end
end


class Controller
  def play_house(random = false)
    "\n--random? #{random}--\n" +
      House.new(random).line(12)
  end
end


puts Controller.new.play_house
puts Controller.new.play_house(false)
puts Controller.new.play_house(true)

# line 18 is hiding the else of the condition
#
# Repeat this code for the summary.
#   Random is a form of primative obsession.
#   The conditional on line 18 really should have two parts.
#   If you write the conditional out, you can see the objects.
#   Rule:
#     The specific values (both true and false) of the thing I'm switching on becomes an object.
#     The concept gets a name.
#     The objects I create all get a message with this name.
#     This message returns the bit that used to be in true/false branch.
#   Therefore:
#     The problem switches from knowing why to switch and what to do, to
#     knowing why to switch, and what object to get when I do.
#   This disperses behavior into small, reuseable objects.
#
#   Also, if your only use of a value is to turn it into an object,
#   that should have happened at the first possible place, back when the value
#   was first known.  If you convert primatives into objects at first chance,
#   these objects will attract behaviour.  If you pass primatives around, you'll
#   switch on them everywhere, and miss the chance to collect all of this
#   confusingly dispersed behavior in a single, cohesive object.
