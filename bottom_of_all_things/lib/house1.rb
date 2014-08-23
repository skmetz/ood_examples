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

  def initialize(random = false)
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
    puts "\n--random? #{random}--"
    puts House.new(random).line(12)
  end
end


puts Controller.new.play_house
puts Controller.new.play_house(false)
puts Controller.new.play_house(true)

# line 18 is hiding the else of the condition
