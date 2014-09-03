I've been teaching a fair amount, which means I've been revisiting my 'class problems' regularly.  When I chose these problems I believed that I understood them completely (hubris, I know) but now that I've worked them repeatedly I'm seeing new and surprising things.

These new things have to do with the _shape_ of code. Code can be written, or shaped, in many ways, and I've always thought that for any given problem many different code shapes gave equally 'good' solutions.  (I think of programming as an art and am willing to give artists a fair amount of expressive leeway.)

But I'm having a change of heart.  These days it feels like all shapes are not equally 'good', that some code shapes are better than others because they _expose_ information that others conceal..  This blog post illustrates the transition I'm undergoing.

Example 1 below is a slightly modified version <a href="#note1">[1]</a> of the code used in my previous blog post <a href="http://www.sandimetz.com/blog/2014/05/28/betting-on-wrong" target="_blank">Getting It Right by Betting on Wrong</a>, about the
<a href="http://en.wikipedia.org/wiki/Open/closed_principle" target="_blank">Open/Closed </a> principle.  The ```House``` class contains code to produce the tale 'The House that Jack Built' <a href="#note2">[2]</a>. The ```Controller``` class invokes ```House#line``` in its ```#play_house``` method on line 33.  Line 37 invokes the controller.  The output is on line 40.

###Example 1: The House that Jack Built
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

Example 1 works fine but let's imagine that requirements change.  Our customer tells us that they like ```House``` and they want it to continue to work as is but they'd also like a variant that randomizes the data before producing the tale.  

Example 2 meets this new requirement.  ```House#initialize``` now takes ```random```,  an optional ```Boolean```.  If ```random``` is ```false```, ```House``` behaves normally, if ```true```, ```House``` randomizes and caches the data before producing the tale.

###Example 2
<pre class="line-numbers" data-line="4,21"><code class="language-ruby">class House
  # ...
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
    House.new(random).line(12)
  end
end

puts "\n--random? false--\n" + Controller.new.play_house(false)
puts "\n--random? true --\n" + Controller.new.play_house(true)

# --random? false--
# This is the horse and the hound and the horn that belonged to the farmer sowing his corn that kept the rooster that crowed in the morn that woke the priest all shaven and shorn that married the man all tattered and torn that kissed the maiden all forlorn that milked the cow with the crumpled horn that tossed the dog that worried the cat that killed the rat that ate the malt that lay in the house that Jack built.

# --random? true --
# This is the rat that ate the malt that lay in the priest all shaven and shorn that married the farmer sowing his corn that kept the cat that killed the house that Jack built the horse and the hound and the horn that belonged to the man all tattered and torn that kissed the cow with the crumpled horn that tossed the maiden all forlorn that milked the dog that worried the rooster that crowed in the morn that woke.</code></pre>

Example 2 now contains conditionals on line 4 and 21.  These conditionals collaborate to meet the 'random' requirement but the way the code is shaped makes it hard to see that these two conditionals are about the same concept.  Not only are they far apart in the code but one is expressed as a trailing ```if``` (which checks the value of ```random```) and the other as ```||=``` (which checks the value of ```@pieces```).

Changing the requirements again will make the problem more obvious.  Perhaps, when shown the output, our customer decides they'd like a third variant.  The randomized version can end in very unsatisfying ways (for example, with 'the rat that ate').  Our customer would like a 'mostly random' version which randomizes all pieces except the last.  This 'mostly random' version should always end with 'the house that Jack built'.

Example 3 shows the interesting new bits of code.  

###Example 3
<pre class="line-numbers" data-line="6,11-17"><code class="language-ruby">class House
  # ...
  attr_reader :pieces

  def initialize(order = nil)
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

Now that we have three different situations it's no longer enough to pass a boolean so ```House```'s initialize method now takes a symbol (:random, :mostly_random or anything else).  ```House#initialize``` sets the value of ```@pieces``` to the result of calling ```initialize_pieces``` on this symbol.  ```#initialize_pieces``` contains a case statement that checks the symbol, puts the data in the correct order and then returns it.

Example 3 does two new things.  First, it adds a third variant, and second, it moves _all_ of the code relating to the concept of 'data order' into a single ```case``` statement.  

While we certainly needed to do the first we could easily have gotten by without doing the second.  We _could_ have kept the existing ```#pieces``` method and left the else branch off of the new case statement, like so:
<pre class="line-numbers"><code class="language-ruby">  def initialize_pieces(order)
    case order
    when :random
      DATA.shuffle
    when :mostly_random
      DATA[0...-1].shuffle &lt;&lt; DATA.last
    end
  end

  def pieces
    @pieces ||= DATA
  end</code></pre>

This works, yes, but the code doesn't feel natural.  Once the number of variants forces us to change to a case statement it feels more 'right' to expect the case statement to provide every order, including the default.  Thus, Example 3 line 17 replaces Example 2 line 21 and all of the code that controls the concept of 'order' is now in the same place.

The key idea here is that 'not changing the order' is a real thing, as real as randomizing or 'mostly' randomizing it.  It's not as if :random and :mostly\_random represent one concept and 'doing nothing' represents another.  There's one concept, 'order', and a number of different possibilities.  One possible way to order something is to _leave its current order unchanged_; this algorithm is as valid as any other.

Now that we're treating every order as a real thing, what next?  Well, as a thought exercise, what would you do if there was lots of code in each branch of the case statement, so much that you felt obliged to extract each branch into a method of its own.  What would you name these methods?

Example 3a does just this.  It names the concepts represented by each branch and moves the code into new methods with those names.  

###Example 3a
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

These ```xxx_order``` methods all represent 'order' variants.  The fact that we can even imagine the name ```default_order``` supports the notion that it's the same kind of thing as ```random_order``` or ```mostly_random_order```.

Once

  1. the choice of 'order' is controlled in a single place and
  2. each order variant is given a name,

it's becomes easy to see 'order' objects hidden in this code.  Instead of forcing ```House``` to know both the values of order upon which it should switch and what to do in every case, we can dispearse the 'what to do' logic into other objects.  Example 4 creates a new class for each kind of order.

###Example 4

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

Example 4 created three new classes, each of which plays the 'orderer' role.  Each 'orderer' implements #order to take a list and return it in the correct order.

These things are extremely easy to test. :-)  It's a feature.

xxxxxxxxxxxxxxxxxx

Let's do one small refactoring before the next point.  In Example 4a, the

###Example 4a

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

###Example 5

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

###Example 6

<pre class="line-numbers"><code class="language-ruby">class Controller
  # ...
  def orderer_for(choice)
    Object.const_get(
      (choice || 'default').to_s.split('_').map(&:capitalize).join
      ).new
  end
end</code></pre>

May as well move the factory to an Order module.

###Example 7

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
puts "\n--:mostly_random--\n" + Controller.new.play_house(:mostly_random)</code></pre>

Passing the random Boolean (Example 1, line 7) or the order Symbol (Example 2, line 9) to House forces House to know about every possible value and to supply the appropriate behavior for each case. This is a form of
<a href="http://sourcemaking.com/refactoring/primitive-obsession"
   target="_blank">
  primitive obsession
</a>.
These arguments are objects; you shouldn't be making decisions about what to do based on their values, you should instead send them messages and reply on them to supply their own behavior.  

In an example small enough to fit into a blog post this code isn't so bad but it stands proxy for the real world where grown-up variants are much more painful.  

In real life if I'm switching on the order Symbol here in House it's not uncommon to have similar case statements in other parts of my code (in other contexts) where I check for identical values but supply different behavior.  Multiple case statements which repeat a common structure but vary the behavior fall pry to
<a href="http://sourcemaking.com/refactoring/shotgun-surgery"
   target="_blank">
  shotgun surgery
</a>
and indicates that you are missing objects.

It can be hard to see this because we often arrange code in ways that obscure it. The conditional on line 18 really should have two parts. If you write the conditional out you can see the objects.

Process:

Name the concept.
Create a class for each value that you are switching on.
Implement a polymorphic (i.e., named after the concept) method in each class.
Move the behavior from its old location in the branch of the conditional to the new method in the new object.

Once you do this the problem switches from knowing both why you switch and what to do when you do, to knowing why to switch and what object to get when you do.  This disperses behavior into small, reusable objects.

Also, if your only use of a value is to turn it into an object, that should have happened at the first possible place, back when the value was first known.  If you convert primitives into objects at first chance these objects will attract behavior and you'll avoid shotgun surgery changes. If you pass primitives around you'll switch on them everywhere and will miss the chance to collect all of this confusingly dispersed behavior in a single, cohesive, reusable object.



Negative space is a thing.
The optical illusion of vase, face. http://en.wikipedia.org/wiki/Rubin_vase
Spreading the 'if' statements out hides the two specializations and makes it harder to create the objects.
With two, really, who cares, but as soon as you have 3, watch for churn.



<a name="note1">[1]</a>
All of this
<a href="https://github.com/skmetz/ood_examples/tree/master/bottom_of_all_things/lib"
   target="_blank">
  code
</a>
is on github.



<a name="note2">[2]</a>
<a href="http://en.wikipedia.org/wiki/This_Is_the_House_That_Jack_Built"
   target="_blank">
  This Is the House That Jack Built
</a>
is a
<a href="http://en.wikipedia.org/wiki/Cumulative_tale"
   target="_blank">
  cumulative tale.
</a>
Cumulative tales are like
<a href="http://en.wikipedia.org/wiki/Cumulative_song"
   target="_blank">
  cumulative songs
</a>
which in turn are one wikipedia hop from
<a href="http://en.wikipedia.org/wiki/The_Complexity_of_Songs"
   target="_blank">
  the complexity of songs
</a>
which in turn link to the article on
<a href="http://en.wikipedia.org/wiki/Computational_complexity_theory"
   target="_blank">
  computational complexity theory</a>.
Tales and songs work great as examples because they let us practice dealing with complexity without requiring that we learn about revolving bank loans or shipping containers.  

The domains are simple but the problems are surprisingly complex.
