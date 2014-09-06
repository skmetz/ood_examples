I've been
<a href="http://www.sandimetz.com/courses/"
   target="_blank">teaching</a>
a fair amount, which means I've been revisiting my 'class problems' regularly.&nbsp;&nbsp;When I chose the problems, I thought that I understood them completely (hubris, I know) but now that I've worked them repeatedly I'm seeing new and surprising things.

These new things have to do with the _shape_ of code.&nbsp;&nbsp;Code can be written, or shaped, in many ways, and I've always believed that for any given problem many different code shapes gave equally 'good' solutions.&nbsp;&nbsp;(I think of programming as an art and am willing to give artists a fair amount of expressive leeway.)

But I'm having a change of heart.&nbsp;&nbsp;These days it feels like all shapes are not equally 'good', that some code shapes are actually better than others.&nbsp;&nbsp;Some shapes _expose_ information that others conceal.&nbsp;&nbsp;This blog post illustrates the transition I'm undergoing.

Example 1 below is a slightly modified version of the code <a href="#note1">[1]</a> used in my previous blog post <a href="http://www.sandimetz.com/blog/2014/05/28/betting-on-wrong" target="_blank">Getting It Right by Betting on Wrong</a> about the
<a href="http://en.wikipedia.org/wiki/Open/closed_principle" target="_blank">Open/Closed </a> principle.&nbsp;&nbsp;The ```House``` class contains code to produce the tale 'The House that Jack Built' <a href="#note2">[2]</a>.&nbsp;&nbsp;The ```Controller``` class invokes ```House#line``` in its ```#play_house``` method on line 33.&nbsp;&nbsp;Line 37 invokes the controller.&nbsp;&nbsp;The output is on line 40.

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

Example 1 works fine but let's imagine that requirements change.&nbsp;&nbsp;Our customer tells us that they like ```House``` and they want it to continue to work as is, but they'd also like a variant that randomizes the data before producing the tale.&nbsp;&nbsp;

Example 2 meets this new requirement.&nbsp;&nbsp;```House#initialize``` now takes ```random```, a boolean.&nbsp;&nbsp;If ```random``` is ```false```, ```House``` behaves normally, if ```true```, ```House``` randomizes and caches the data before producing the tale.

###Example 2
<pre class="line-numbers" data-line="4,21"><code class="language-ruby">class House
  # ...
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

Example 2 now contains conditionals on line 4 and 21.&nbsp;&nbsp;These conditionals collaborate to meet the 'random' requirement but the way the code is shaped makes it hard to see that these two conditionals are about the same concept.&nbsp;&nbsp;Not only are they far apart in the code but one is expressed as a trailing ```if``` (which checks the value of ```random```) and the other as ```||=``` (which checks the value of ```@pieces```).

Changing the requirements again will bring the underlying issue more sharply into focus.&nbsp;&nbsp;Our customer, when shown the output, decides they'd like a third variant.&nbsp;&nbsp;The current 'randomized' version can end in very unsatisfying ways (for example, with 'the rat that ate').&nbsp;&nbsp;Our customer would like a 'mostly random' version which randomizes all pieces except the last.&nbsp;&nbsp;This 'mostly random' version should always end with 'the house that Jack built'.

Example 3 shows the interesting new bits of code.&nbsp;&nbsp;

###Example 3
<pre class="line-numbers" data-line="6,11-17"><code class="language-ruby">class House
  # ...
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

Now that we have three different ordering requirements it's no longer sufficient to pass a boolean.&nbsp;&nbsp;Therefore, ```House```'s initialize method takes a symbol (:random, :mostly_random or anything else) and sets the value of ```@pieces``` to the result of calling ```initialize_pieces``` on that symbol (line 6 above).&nbsp;&nbsp;```#initialize_pieces``` contains a case statement (lines 11-18) that arranges the data in the correct order and returns it.

Example 3 does two new things.&nbsp;&nbsp;First, it adds the new 'mostly random' variant, and second, it moves _all_ of the code related to the concept of 'data order' into a single ```case``` statement.&nbsp;&nbsp;

While we certainly need to do the first we could easily have gotten by without the second.&nbsp;&nbsp;We could instead have kept the existing ```#pieces``` method and omitted the else branch from the new case statement, like so:
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

This works, but the code doesn't feel natural.&nbsp;&nbsp;Once the number of variants forces us to change to a ```case``` statement it feels more 'right' to expect that case statement to deal with all of the ordering, including the default.&nbsp;&nbsp;The code above separates the default from the variants while Example 3 treats the default _as_ a variant. Example 3 line 17 replaces Example 2 line 21 and groups all of the code that controls the concept of 'order' in  one place.

The key idea here is that 'not changing the order' is a real thing, as real as 'randomizing' or 'mostly randomizing' it.&nbsp;&nbsp;It's not as if :random and :mostly\_random represent one concept and 'doing nothing' represents another.&nbsp;&nbsp;There's one concept, 'order', and a number of different possibilities.&nbsp;&nbsp;One way to order something is to _leave its current order unchanged_; this is an algorithm as valid as any other.

Now that we're treating every order as a real thing let's do a thought exercise.&nbsp;&nbsp;Imagine that each branch of the case statement contained many lines of code, so much that you felt obliged to extract them into methods of their own.&nbsp;&nbsp;How would you name these extracted methods?

Example 3a illustrates one possibility.

###Example 3a
<pre class="line-numbers" data-line="14,18,22"><code class="language-ruby">class House
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

These ```xxx_order``` methods above represent 'order' variants.&nbsp;&nbsp;Unsurprisingly, most of the method names reflect the symbols that we used in the case statement.&nbsp;&nbsp;Symbol ```:random``` becomes method ```#random_order```, ```:mostly_random``` becomes ```#mostly_random__order``` and the else branch becomes ```#default_order```.&nbsp;&nbsp;The fact that we can imagine a method named ```#default_order``` supports the notion that the else branch represents the same kind of thing as the other branches.&nbsp;&nbsp;Ordering something as 'unchanged' is as valid as ordering it 'random'; to insist otherwise judges some algorithms as not as 'real' than others.

Now that we've explicitly named the methods we can see that the names have a repeating suffix.&nbsp;&nbsp;When methods have a repeating prefix or suffix it's a sign that you have untapped objects hidden within your code.&nbsp;&nbsp;Going through the exercise of giving the branches of the case statement explicit names helps identify these missing objects.&nbsp;&nbsp;Instead of forcing ```House``` to know both 1) the values of ```order``` upon which it should switch and 2) what to do in every case, we can disperse the 'what to do' logic into other objects.&nbsp;&nbsp;

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

Example 4 creates three new classes, each of which plays the 'orderer' role.&nbsp;&nbsp;Each 'orderer' implements #order to take a list and return it in the correct order.

These classes will be a delight to test. :-)

Example 4a slightly rearranges the case statement (and likely offends some Rubyists, but that's for another day) to make its purpose more obvious.

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

If the syntax above is new to you remember that the ```case...end``` statement returns an object to which you can send a message.&nbsp;&nbsp;This case statement returns a class; line 11 sends ```new.order(DATA)``` to that class.&nbsp;&nbsp;Thus, the case statement's responsibility is to return a class that plays the role of 'orderer'; actual ordering is a separate task that happens afterwards.

Example 4a reveals a curious thing.&nbsp;&nbsp;```House``` is initialized on the ```order``` symbol, which it immediately converts into a _different_ object.&nbsp;&nbsp;You can think of ```House``` as being _injected_ with a behaviorally impaired kind of 'orderer' (the symbol) which it is then forced to convert into a more robust kind of 'orderer' (an instance of ```Random```, ```MostlyRandom``` or ```Default```).&nbsp;&nbsp;In the above implementation ```House``` depends on (knows about) many things.&nbsp;&nbsp;It knows the names of all possible symbols, the names all of the 'orderer' classes and the mapping between the two.&nbsp;&nbsp;Many distant changes might force changes to ```House```; it would be more flexible if it knew less.

We could spare ```House``` many of these dependencies if we inject the object it actually wants, and Example 5 does exactly that.&nbsp;&nbsp;Here, ```Controller``` has assumed responsibility for creating 'orderer's and injecting them into ```House``` (line 13).

###Example 5

<pre class="line-numbers" data-line="13"><code class="language-ruby">class House
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

The responsibility for converting feeble 'orderer' objects into more robust ones belongs no more in ```Controller``` than it did in ```House```, but this new code _is_ an improvement.&nbsp;&nbsp;It's best to do these kinds of conversions at the first opportunity and at least now we're pushing the conversion back up the stack, searching for its natural home.

With this change ```House``` becomes open/closed to new 'orderers'; you can inject any object you like as long as it implements ```#order```.&nbsp;&nbsp;```House``` also has fewer dependencies; it can collaborate with new 'orderers' without being forced to change.

The ```Controller#orderer_for``` method, however, is _not_ yet open/closed; it must change if you add new 'orderers'.&nbsp;&nbsp;If you're willing to commit to a naming convention and do a bit of metaprogramming (as in Example 6), this is easily remedied.

###Example 6

<pre class="line-numbers"><code class="language-ruby">class Controller
  # ...
  def orderer_for(choice)
    Object.const_get(
      (choice || 'default').to_s.split('_').map(&:capitalize).join
      ).new
  end
end</code></pre>

As long as you follow the naming convention this code will convert any symbol to an instance of the corresponding class.

```Controller```'s ```#orderer_for``` method was uncomfortable when it was merely in the wrong place but now that we've complicated the code in the name of making it open/closed it feels increasingly important to figure out where the method belongs.&nbsp;&nbsp;We have a number of things that revolve around the concept of 'order' (three classes and this factory method) and this code would be easier to understand if they all lived together.&nbsp;&nbsp;Example 7 creates an ```Order``` module to hold them.

###Example 7

<pre class="line-numbers"><code class="language-ruby">module Order
  def self.new(choice)
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
end</code></pre>

Moving the factory method to the ```Order``` module makes it natural to change its name from ```#orderer_for``` (as in Example 6 line 3) to ```#new``` (above, line 2).&nbsp;&nbsp;The ```#new``` method of ```Order``` takes a symbol for an argument and returns the right 'orderer'.&nbsp;&nbsp;You need not care about the class of the returned object; the thing you get back responds to ```#order``` and that's good enough.

Here's a complete listing of the current code.

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
  def self.new(choice)
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
    House.new(Order.new(choice)).line(12)
  end
end

puts "\n----\n"               + Controller.new.play_house
puts "\n--:random--\n"        + Controller.new.play_house(:random)
puts "\n--:mostly_random--\n" + Controller.new.play_house(:mostly_random)</code></pre>

This refactoring is complete, and I have just one final thought before we return to the original problem of 'code shapes'.&nbsp;&nbsp;

I totally understand that this is a small example and that these techniques can feel like overkill for a problem of this size.&nbsp;&nbsp;Perhaps they are; I wouldn't resist if you insisted it were so.&nbsp;&nbsp;However, there _are_ bigger problems for which these techniques are the perfect solution and I rely on your ability to see the larger abstraction.&nbsp;&nbsp;You can't choose whether to use these techniques _unless you know them_ and it's much easier practice on a small example like this.&nbsp;&nbsp;

###Example 2: Reprise
And now, back to the idea that some code shapes are better than others.&nbsp;&nbsp;Here's a reminder of Example 2, the code that was written to meet the first new requirement.

<pre class="line-numbers" data-line="4,21"><code class="language-ruby">class House
  # ...
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
end</code></pre>

At first glance this code seems fine but its shape hides objects that we found during the refactoring.&nbsp;&nbsp;Line 4 hides ```Order::Random``` and line 21, ```Order::Default```.

We can easily expose these objects by rewriting the code in a more explicit, straightforward way.&nbsp;&nbsp;The code below replaces the ```#pieces``` method with an ```else``` branch in the ```if``` statement and adds an ```attr_reader``` for ```@pieces```.

<pre class="line-numbers" data-line="6-9"><code class="language-ruby">class House
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

Once the ```if``` statement on line 6 is written this way we can see that it uses the value of the boolean ```random``` to choose the algorithm to apply to ```DATA```.&nbsp;&nbsp;This is a form of <a href="http://sourcemaking.com/refactoring/primitive-obsession"
   target="_blank">
  primitive obsession</a>.&nbsp;&nbsp;
The booleans ```true``` and ```false``` should be replaced by more robust 'orderer' objects that provide these algorithms and which are injected into ```House``` in their stead.

The arrangement of the code in the original Example 2 hides these objects, the code above reveals them.

###Summary

Code shape matters, especially when it comes to conditionals.&nbsp;&nbsp;Dividing a conditional into multiple parts and placing those parts far apart makes it hard to see underlying objects.&nbsp;&nbsp;The opposite is also true; clarity can be achieved by hunting down all the parts of a conditional and putting them back together.&nbsp;&nbsp;

When conditionals are shaped correctly it's easy to see and extract missing objects.&nbsp;&nbsp;Once extracted, these more robust objects can be re-injected in place of the original primitives.&nbsp;&nbsp;When ```House``` was injected with an 'orderer' it became both more consistent and more flexible.&nbsp;&nbsp;The likelihood that it will be forced to change went down and its ability to collaborate with objects it knows little about went up.

And finally, the 'default' is often just another kind of specialization.&nbsp;&nbsp;Negative space is as valid as positive; in the
<a href="http://en.wikipedia.org/wiki/Rubin_vase"
   target="_blank">
   Rubin Vase image
</a>
the vase and the face are equally real.&nbsp;&nbsp;Recognizing that the default case is in the same category as all the other specializations  allows you to inject an object that does the _right_ thing, and objects that can be trusted to do the right thing make everything easier.
<br/>
<br/>
<br/>
_This exercise was extracted from my Practical Object-Oriented Design course, which is chock full of stuff like this._

<strong>
_<a href="http://www.sandimetz.com/pood-durham-2014"
  target="_blank">
  Sign up</a> to take the course on Oct 29-31 in Durham, North Carolina (BBQ included)._

_<a href="http://www.sandimetz.com/courses/"
  target="_blank">
  Schedule</a> a private course._

_<a href="http://www.sandimetz.com/subscribe"
  target="_blank">
  Sign up</a> for my newsletter._
</strong>
<br/>
<br/>
###Notes
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
Tales and songs are great as examples because they let us practice dealing with complexity without requiring that we learn about revolving bank loans or shipping containers.&nbsp;&nbsp;They provide surprisingly complex problems within simple, well-known domains.
