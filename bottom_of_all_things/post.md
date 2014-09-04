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

This works, yes, but the code doesn't feel natural.  Once the number of variants forces us to change to a ```case``` statement it feels more 'right' to expect it to deal with all of the ordering, even the default.  Thus, Example 3 line 17 replaces Example 2 line 21 and all of the code that controls the concept of 'order' is now grouped together in the same place.

The key idea here is that 'not changing the order' is a real thing, as real as randomizing or 'mostly' randomizing it.  It's not as if :random and :mostly\_random represent one concept and 'doing nothing' represents another.  There's one concept, 'order', and a number of different possibilities.  One way to order something is to _leave its current order unchanged_; this algorithm is as valid as any other.

Now that we're treating every order as a real thing, let's do a thought exercise.
Image that each branch of the case statement contained many lines of code, so much that you felt obliged to extract them into methods of their own.  What would you name the extracted methods?

Example 3a illustrates this.  You can think of it as naming concepts represented by each branch and moving the code into new methods with those names.  

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

These ```xxx_order``` methods above represent 'order' variants.  Unsurprisingly, in most cases the method names reflect the symbol names that we check in the case statement.  Symbol ```:random``` becomes method ```#random_order```, ```:mostly_random``` becomes ```#mostly_random__order``` and the else branch becomes ```#default_order```.  The fact that we can  imagine the name ```default_order``` supports the notion that the code in the else branch represents the same kind of thing as the others.

Now that we've explicitly named these things we can see that our names have a repeating suffix. When methods have a repeating prefix or suffix it's a sign that you have untapped objects hidden within your code. Going through the exercise of giving the case statement branches explicit names helps to identify these missing objects.  Instead of forcing ```House``` to know both the values of order upon which it should switch and what to do in every case, we should dispearse the 'what to do' logic into other objects.  

Example 4 creates a new class for each kind of order.

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

Example 4 creates three new classes, each of which plays the 'orderer' role.  Each 'orderer' implements #order to take a list and return it in the correct order.

These new classes are extremely easy to test. :-)

Example 4a slightly rearranges the case statement (and likely offends some Rubyists, but that's for another day) to make it obvious that the purpose of this case statement is to choose the class.

###Example 4a

<pre class="line-numbers" data-line="11"><code class="language-ruby">class House
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

If this syntax is new to you remember that the ```case...end``` statement returns an object to which you can send a message.  The case statement above returns a class; on line 11 we send ```new.order(DATA)``` to that class.  Thus, the case statement's responsibility is to return a class that plays the role of 'orderer'; ordering is a separate task that happens afterwards.

Example 4a now reveals a curious thing.  ```House``` is initialized on the ```order``` symbol,  which it immediately converts it into a _different_ object. You can think of ```House``` as being _injected_ with a behaviorally impaired kind of 'orderer' (the symbol) which it is then forced to convert into a more robust kind of 'orderer' (an instance of ```Random```, ```MostlyRandom``` or ```Default```)<a href="#note3">[3]</a>.  In this implementation ```House``` depends on (knows about) many things.  It knows the names of all possible symbols, the names all of the 'orderer' class, and the mapping between the two.  Many distant changes might force changes to ```House``` and it would be more flexible if it knew less.

We could spare ```House``` many of these dependencies if we injected the object it actually wants.

Example 5 does exactly that.  Here ```House``` is injected with an 'orderer' and the ```Controller``` is now responsible for converting the symbol to the right orderer object.

###Example 5

<pre class="line-numbers" data-line="13,17-23"><code class="language-ruby">class House
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

The responsibility for converting feeble 'orderer' objects into more robust ones belongs no more in ```Controller``` than it did in ```House```, but this new code _is_ an improvement. We want to do this conversion at the first opportunity and we're pushing it back up the stack, looking for it's natural home.

With this change```House``` is open/closed to new 'orderers'; you can inject any object you like as long as it implements ```#order```.  ```House``` also has fewer dependencies; it can collaborate with new 'orderers' without being forced to change.

```Controller#orderer_for```, however, is _not_ yet open/closed. The ```#orderer_for``` method above must change if you add new 'orderers'.  If you're willing to depend on a naming convention and to allow a bit of metaprogramming (as in  Example 6), you can take a symbol and return the correct 'orderer' object.

###Example 6

<pre class="line-numbers"><code class="language-ruby">class Controller
  # ...
  def orderer_for(choice)
    Object.const_get(
      (choice || 'default').to_s.split('_').map(&:capitalize).join
      ).new
  end
end</code></pre>

Example 6 makes ```Controller#orderer_for``` open/closed.  As long as you follow the naming convention, it will convert any symbol to an instance of its corresponding class.

The ```#orderer_for``` method was bad enough when it was merely in the wrong place but now that we've complicated the code in the name of making it open/closed it feels increasingly important to put this responsibility where it belongs.  We have a number of things that revolved around the concept of 'order' (three classes and this factory method), they should probably all be together.  Example 7 creates a ```Order``` module to hold them all.

###Example 7

<pre class="line-numbers"><code class="language-ruby">module Order
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
      data[0...-1].shuffle << data.last
    end
  end
end</code></pre>

Here's a complete listing of the code as it now exists.

###Example: Complete

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

On final thought before we return to the original problem of 'code shapes'. I realize this is a small example and that these techniques can feel like overkill for a problem of this size.  Perhaps they are; I wouldn't resist if you insisted that it were so.  However, there _are_ bigger problems for which these techniques are the perfect solution.  I reply on your ability to see that there's a larger abstraction. You can't use these techniques there unless you learn them here.  

###Reprise of Example 2
But what about the shapes?
Remember the first change in requirements, where the concept of 'order' had code on both line 4 and line 21?

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
end</code></pre>

The shape of this code hides objects.  What if, instead of the above, we wrote it down in the sipmlest, most explicit way possible?

<pre class="line-numbers"><code class="language-ruby">class House
  # ...
  attr_reader :pieces
  def initialize(random = false)
    @pieces =
      if random
        DATA.shuffle
      else
        DATA
      end
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
end</code></pre>



###Summary



Code shape matters, especially when it comes to conditionals.  Dividing a conditional into two parts and separating these parts in code makes it harder to see underlying objects.  Clarity can be achieved by putting all of the parts of a conditional back together. Write simple code, and write _all_ of the code.  Once you do, new objects will reveal themselves.

The 'default' is just another kind of specialization.  Negative space is a thing just like positive space; in the
<a href="http://en.wikipedia.org/wiki/Rubin_vase"
   target="_blank">
   Rubin Vase image
</a>
the face and the vase are equally real.



Once you do you'll see that the 'default' is often the exact same kind of thing as the exception and that

<a href="http://sourcemaking.com/refactoring/primitive-obsession"
   target="_blank">
  primitive obsession
</a>
indicates that you are missing objects.
Turn primatives into robust domain specific objects at the first opportunity.  Don't pass them around.


<a href="http://sourcemaking.com/refactoring/shotgun-surgery"
   target="_blank">
  shotgun surgery
</a>
indicates that you are missing objects.



It can be hard to see this because we often arrange code in ways that obscure it. The conditional on line 18 really should have two parts. If you write the conditional out you can see the objects.


Negative space is a thing.
The optical illusion of vase, face. http://en.wikipedia.org/wiki/Rubin_vase
Spreading the 'if' statements out hides the two specializations and makes it harder to create the objects.
With two, really, who cares, but as soon as you have 3, watch for churn.



<a name="note1">[1]</a>
<a href="https://github.com/skmetz/ood_examples/tree/master/bottom_of_all_things/lib"
   target="_blank">
  This code
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
which in link to the article on
<a href="http://en.wikipedia.org/wiki/Computational_complexity_theory"
   target="_blank">
  computational complexity theory</a>.
Tales and songs are great as examples because they let us practice dealing with complexity without requiring that we learn about revolving bank loans or shipping containers. They provide surprisingly complex problems within simple, well-known domains.


<a nane="#note3">[3]</a>
This is a form of
<a href="http://sourcemaking.com/refactoring/primitive-obsession"
   target="_blank">
  primitive obsession
</a>
