Say some things.

And then more things.

The
<a href="https://github.com/skmetz/ood_examples/tree/master/bottom_of_all_things/lib"
   target="_blank">
  example code
</a>
is on github.

###Example: The House that Jack Built

<pre id="house" class="line-numbers"><code class="language-ruby">class House
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

  def recite
    (1..DATA.length).map {|i| line(i)}.join("\n")
  end

  def line(number)
    "This is #{phrase(number)}.\n"
  end

  private
  def phrase(number)
    DATA.last(number).join(" ")
  end
end

class Controller
  def play_house
    House.new.line(12)
  end
end


puts "\n----\n" + Controller.new.play_house

# ----
# This is the horse and the hound and the horn that belonged to the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.
</code></pre>

Text, text, text.

###Example 1
<pre class="line-numbers"><code class="language-ruby">class House
  DATA = [
    'the horse and the hound and the horn that belonged to',
     # ...
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
    House.new(random).line(12)
  end
end


puts "\n--random? false--\n" + Controller.new.play_house(false)
puts "\n--random? true --\n" + Controller.new.play_house(true)

# --random? false--
# This is the horse and the hound and the horn that belonged to the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.

# --random? true --
# This is the rat that ate the malt that lay in the priest all shaven and shorn that married the farmer sowing his corn that kept the cat that killed the house that Jack built the horse and the hound and the horn that belonged to the man all tattered and torn that kissed the cow with the crumpled horn that tossed the maiden all forlorn that milked the dog that worried the rooster that crowed in the morn that woke.</code></pre>

Text, Text, text.

###Example 2
<pre class="line-numbers"><code class="language-ruby">class House
  DATA = [
    'the horse and the hound and the horn that belonged to',
    # ...
  ]

  attr_reader :pieces

  def initialize(order)
    @pieces = initialize_pieces(order)
  end

  # ...
  def initialize_pieces(order)
    case order
    when :random
      DATA.shuffle
    when :mostly_random
      DATA[0...-1].shuffle &lt;&lt; DATA.last
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
# This is the man all tattered and torn that kissed the cow with the crumpled horn that tossed the maiden all forlorn that milked the horse and the hound and the horn that belonged to the dog that worried the malt that lay in the rooster that crowed in the morn that woke the rat that ate the cat that killed the farmer sowing his corn that kept the priest all shaven and shorn that married the house that Jack built.</code></pre>

Text, text text

###Example 2a

<pre class="line-numbers"><code class="language-ruby">class House
  # ...
  def initialize_pieces(order)
    case order
    when :random
      random_order
    when :mostly_random
      mostly_random_order
    else
      default_order
    end
  end

  def random_order
    DATA.shuffle
  end

  def mostly_random_order
    DATA[0...-1].shuffle &lt;&lt; DATA.last
  end

  def default_order
    DATA
  end
  # ...</code></pre>

Text text

###Example 3

<pre class="line-numbers"><code class="language-ruby">class House
  # ...
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
    data[0...-1].shuffle &lt;&lt; data.last
  end
end</code></pre>

Text, text, text

###Example 3a

<pre class="line-numbers" data-line="13"><code class="language-ruby">class House
  # ...
  def initialize_pieces(order)
    case order
    when :random
      Random
    when :mostly_random
      MostlyRandom
    else
      Default
    end.new.order(DATA)
  end
    # ...
end</code></pre>

House takes a symbol and uses it for nothing other than to convert it to a class.

The thing that passed me the symbol knew what they wanted, they should create and give me the class. Push the object creation back to them.

###Example 4

<pre class="line-numbers"><code class="language-ruby">class House
  # ...
  attr_reader :pieces

  def initialize(orderer)
    @pieces = orderer.order(DATA)
  end
  # ...
end


class Controller
  def play_house(choice = nil)
    House.new(orderer_for(choice)).line(12)
  end

  def orderer_for(choice)
    case choice
    when :random
      Random
    when :mostly_random
      MostlyRandom
    else
      Default
    end.new
  end
end</code></pre>

Text, text, text

###Example 5

<pre class="line-numbers"><code class="language-ruby">class Controller
  # ...
  def orderer_for(choice)
    Object.const_get(
      (choice || 'default').to_s.split('_').map(&:capitalize).join
      ).new
  end
end</code></pre>

May as well move the factory to an Order module.

###Example 6

<pre class="line-numbers"><code class="language-ruby">module Order
  def self.for(choice)
    Object.const_get(
      'Order::' +
      (choice || 'default').to_s.split('_').map(&:capitalize).join
      ).new
  end</code></pre>

May as well also put all of the Orderers in the Order module.

###Full Example

<pre class="line-numbers"><code class="language-ruby">class House
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

  def initialize(orderer)
    @pieces = orderer.order(DATA)
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
end


module Order
  def self.for(choice)
    Object.const_get(
      'Order::' +
      (choice || 'default').to_s.split('_').map(&:capitalize).join
      ).new
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
      data[0...-1].shuffle &lt;&lt; data.last
    end
  end
end


class Controller
  def play_house(choice = nil)
    House.new(Order.for(choice)).line(12)
  end
end


puts "\n----\n"               + Controller.new.play_house
puts "\n--:random--\n"        + Controller.new.play_house(:random)
puts "\n--:mostly_random--\n" + Controller.new.play_house(:mostly_random)

# Create an Order module to hold the Ordering classes, and put the factory
# method on the module.
</code></pre>

Passing the random Boolean (Example 1, line 7) or the order Symbol (Example 2, line 9) to House forces House to know about every possible value and to supply the appropriate behavior for each case. This is a form of
<a href="http://sourcemaking.com/refactoring/primitive-obsession"
   target="_blank">
  primitive obsession
</a>.
These arguments are objects; you shouldn't be making decisions about what to do based on their values, you should be sending them messages and replying on them to supply their own behavior.  

In an example small enough to fit into a blog post this code isn't so bad but it stands proxy for the real world where grown-up variants are much more painful.  

In real life if I'm switching on the order Symbol here in House it's not uncommon to have similar case statements in other parts of my code, in other contexts, where I check for identical values but supply different behavior.  Multiple case statements which repeat a common structure but vary the behavior fall pry to
<a href="http://sourcemaking.com/refactoring/shotgun-surgery"
   target="_blank">
  shotgun surgery
</a>
and indicates that you are missing objects.

It can be hard to see this.  We sometimes arrange code in ways that obscure it. The conditional on line 18 really should have two parts. If you write the conditional out you can see the objects.

Process:

Name the concept.
Create a class for each value that you are switching on.
Implement a polymorphic (i.e., named after the concept) method in each class.
Move the behavior from its old location in the branch of the conditional to the new method.
Therefore, the problem switches from knowing why to switch and what to do, to knowing why to switch and what object to get.  This disperses behavior into small, reusable objects.

Also, if your only use of a value is to turn it into an object, that should have happened at the first possible place, back when the value was first known.  If you convert primitives into objects at first chance these objects will attract behavior and you'll avoid shotgun surgery changes. If you pass primitives around you'll switch on them everywhere and will miss the chance to collect all of this confusingly dispersed behavior in a single, cohesive, reusable object.
