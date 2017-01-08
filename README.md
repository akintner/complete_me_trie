#Complete-Me Trie
Everyone in today's smartphone-saturated world has had their
share of interactions with textual "autocomplete." You
may have sometimes even wondered if autocomplete is
worth the trouble, given the ridiculous completions it
sometimes attempts.
<br>
But how would you actually __make__ an autocomplete system?
<br>
In this project, __CompleteMe__ we'll be exploring this idea by
a simple textual autocomplete system. Perhaps in the process we will develop
some sympathy for the developers who built the seemingly
incompetent systems on our phones...

### Data Structure -- Introduction to Tries

A common way to solve this problem is using a data structure
called a __Trie__. The name comes from the idea of a Re-trie-val
tree, and it's useful for storing and then fetching paths through
arbitrary (often textual) data.

A Trie is somewhat similar to the binary trees you may have seen before,
but whereas each node in a binary tree points to up to 2 subtrees,
nodes within our retrieval tries will point to `N` subtrees, where `N`
is the size of the alphabet we want to complete within.

Thus for a simple latin-alphabet text trie, each node will potentially
have 26 children, one for each character that could potentially follow
the text entered thus far.
(In graph theory terms, we could classify this as a Directed, Acyclic
graph of order 26, but hey, who's counting?)

What we end up with is a broadly-branched tree where paths from the
root to the leaves represent "words" within the dictionary.

Take a moment and read more about Tries:

* [Tries writeup in the DSA Repo](https://github.com/turingschool/data_structures_and_algorithms/tree/master/tries)
* [Tries Wikipedia Article](https://en.wikipedia.org/wiki/Trie)

### Input File

Of course, our Trie won't be very useful without a good dataset
to populate it. Fortunately, our computers ship with a special
file containing a list of standard dictionary words.
It lives at `/usr/share/dict/words`

Using the unix utility `wc` (word count), we can see that the file
contains 235886 words:

```
$ cat /usr/share/dict/words | wc -l
235886
```

Should be enough for us!

### Required Features

To complete the project, you will need to build an autocomplete
system which provides the following features:

1. Insert a single word to the autocomplete dictionary
2. Count the number of words in the dictionary
3. Populate a newline-separated list of words into the dictionary
4. Suggest completions for a substring
5. Mark a selection for a substring
6. Weight subsequent suggestions based on previous selections

### Basic Interaction Model

We'll expect to interact with your completion project from an interactive
pry session, following a model something like this:

```ruby
# open pry from root project directory
require "./lib/complete_me"

completion = CompleteMe.new

completion.insert("pizza")

completion.count
=> 1

completion.suggest("piz")
=> ["pizza"]

dictionary = File.read("/usr/share/dict/words")

completion.populate(dictionary)

completion.count
=> 235886

completion.suggest("piz")
=> ["pizza", "pizzeria", "pizzicato"]
```

### Usage Weighting

The common gripe about autocomplete systems is that they give us
suggestions that are technically valid but not at all what we wanted.

A solution to this problem is to "train" the completion dictionary
over time based on the user's actual selections. So, if a user
consistently selects "pizza" in response to completions for "pizz",
it probably makes sense to recommend that as their first suggestion.

To facilitate this, your library should support a `select` method,
which takes a substring and the selected suggestion. You
will need to record this selection in your trie and use it
to influence future selections to make.

Here's what that interaction model should look like:


```ruby
require "./lib/complete_me"

completion = CompleteMe.new

dictionary = File.read("/usr/share/dict/words")

completion.populate(dictionary)

completion.suggest("piz")
=> ["pizza", "pizzeria", "pizzicato"]

completion.select("piz", "pizzeria")

completion.suggest("piz")
=> ["pizzeria", "pizza", "pizzicato"]
```

## Support Tooling

Please make sure that, before your evaluation, your project has each of the following:

* SimpleCov reporting accurate test coverage statistics
* TravisCI running your all your tests and they all pass
* CodeClimate evaluating the quality of your code (best to set it up early to see the change over time)

## Supporting Features

In addition to the base features included above, you must choose **one** of the following to implement:

### 1. Substring-Specific Selection Tracking

A simple approach to tracking selections would be to simply
"count" the number of times a given word is selected
(e.g. "pizza" - 4 times, etc). But a more sophisticated solution
would allow us to track selection information _per completion string_.
<br>
That is, we want to make sure that when `select`ing a given word,
that selection is only counted toward subsequent suggestions against
the same substring. Here's an example:

```
require "./lib/complete_me"

completion = CompleteMe.new

dictionary = File.read("/usr/share/dict/words")

completion.populate(dictionary)

completion.select("piz", "pizzeria")
completion.select("piz", "pizzeria")
completion.select("piz", "pizzeria")

completion.select("pi", "pizza")
completion.select("pi", "pizza")
completion.select("pi", "pizzicato")

completion.suggest("piz")
=> ["pizzeria", "pizza", "pizzicato"]

completion.suggest("pi")
=> ["pizza", "pizzicato","pizzeria"]
```

In this example, against the substring "piz" we choose
"pizzeria" 3 times, making it the dominant choice for this
substring.
<br>
However for the substring "pi", we choose "pizza" twice and
"pizzicato" once. The previous selections of "pizzeria" against
"piz" don't count when suggesting against "pi", so now "pizza"
and "pizzicato" come up as the top choices.

### 2. Word Deletion and Tree Pruning

Let's add a feature that let's us delete words from the tree.
When deleting a node, we'll need to consider a couple of cases.
<br>
First, make sure that we adjust our tree so that the node relating to
the removed word is no longer seen as a valid word. This means
that subsequent suggestions should no longer return it as a match for
any of its substrings.
<br>
For "intermediate" nodes (i.e. nodes that still have
children below them), this is all you need to do.
<br>
However, for **leaf nodes** (i.e. nodes at the end of the tree), we
will also want to **completely remove** those nodes from the tree.
Since the node in question no longer represents a word and there
are no remaining nodes below it, there's no point in keeping it in the
tree, so we should remove it.
<br>
**Additionally**, once we remove this node, we would also want to
remove any of its parents for which it was the only child. That is --
if, once we remove our word in question, the node above it is now
a path to nowhere, we should also remove that node. This process would
repeat up the chain until we finally reach "word" node that we want
to keep around.
<br>
The exact implementation of this process will depend on how your
tree is built, so we likely won't include it in the spec harness. You
will need to provide your own tests that demonstrate this functionality.
