require_relative '../lib/node'

class CompleteMe

  attr_reader :root_node

  def initialize
    @root_node = Node.new
  end

  def add_other_letters(length, letter, characters, node)
    next_node = node.link_to(letter)
    if length == 1
      next_node.make_terminator
    else
      insert(characters.join, next_node)
    end
  end

  def insert(word, node = @root_node)
    length = word.length
    characters = word.chars
    letter = characters.delete_at(0)
    node.insert_link(letter) unless node.includes_link?(letter)
    add_other_letters(length, letter, characters, node)
  end

  def count(node = @root_node)
    count = 0
    count += 1 if node.terminator 
    count += node.links.values.inject(0) {|sum, next_node| sum + count(next_node)}
  end
  
  def populate(dictionary)
    words = dictionary.split("\n")
    words.each {|word| insert(word)}
  end

  def populate_suggestions(node, letter, suggestions)
    next_node = node.link_to(letter)
    suggestions << letter if next_node.terminator
    find_suggestions(next_node).each {|suggestion| suggestions << letter + suggestion}
  end

  def find_suggestions(node)
    suggestions = []
    node_links = node.links.keys
    node_links.each {|letter| populate_suggestions(node, letter, suggestions)}
    suggestions
  end

  def search(node, length, characters)
    if length == 1
      node
    else
      node_finder(characters.join, node)
    end
  end
  
  def node_finder(fragment, node = @root_node)
    length = fragment.length
    characters = fragment.chars
    letter = characters.delete_at(0)
    return @root_node if length == 0
    next_node = node.link_to(letter)
    search(next_node, length, characters) if node.includes_link?(letter)
  end

  def suggest(fragment)
    suggestions = []
    node = node_finder(fragment)
    if node != nil
      second_halves = find_suggestions(node)
      suggestions = second_halves.map {|second_half| fragment + second_half}
    end
    suggestions
  end

end
