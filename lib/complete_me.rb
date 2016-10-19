require './lib/node'
require 'pry'

class CompleteMe

  attr_reader :root_node, :suggests

  def initialize
    @root_node = Node.new
  end

  def add_other_letters(length, letter, characters, node)
    if length == 1
      node.make_terminator
    else
      insert(characters.join, node)
    end
  end

  def insert(word, node = @root_node)
    characters = word.chars
    letter = characters.delete_at(0)
    node.insert_link(letter) unless node.includes_link?(letter)
    add_other_letters(word.length, letter, characters, node.link_to(letter))
  end

  def count(node = @root_node)
    count = 0
    count += 1 if node.terminator 
    linked_nodes = node.links.values
    count += linked_nodes.inject(0) {|sum, linked_node| sum + count(linked_node)} 
  end
  
  def populate(dictionary)
    dictionary.split("\n").each {|word| insert(word)}
  end

  def populate_suggestions(node, letter, fragment_suggestions)
    next_node = node.link_to(letter)
    fragment_suggestions << letter if next_node.terminator
    find_suggestions(next_node).each do |suggestion|
      fragment_suggestions << letter + suggestion
    end
  end

  def search(node, length, characters)
    if length == 1
      node
    else
      node_finder(characters.join, node)
    end
  end
  
  def node_finder(fragment, node = @root_node)
    characters = fragment.chars
    letter = characters.delete_at(0)
    return @root_node if fragment.length == 0
    next_node = node.link_to(letter)
    search(next_node, fragment.length, characters) if node.includes_link?(letter)
  end

  def select(fragment, word)
    if suggest(fragment).include?(word)
      node = node_finder(word)
      node.select if node.terminator 
    end
  end

  def find_suggestions(node)
    fragment_suggestions = []
    letters = node.links.keys
    letters.each {|letter| populate_suggestions(node, letter, fragment_suggestions)} #correct enumerable?
    fragment_suggestions
  end

  def sort_by_selections(suggestions)
    suggestions.sort_by {|suggestion| node_finder(suggestion).selects * -1}
  end

  def concatenate_halves(suggestions, node, fragment)
    second_halves = find_suggestions(node)
    suggestions = second_halves.map {|second_half| fragment + second_half}
    suggestions.unshift(fragment) if node.terminator
    suggestions
  end
  
  def suggest(fragment)
    suggestions = []
    node = node_finder(fragment)
    suggestions = concatenate_halves(suggestions, node, fragment) if node != nil
    sort_by_selections(suggestions)
  end

  def vanish_node(node, characters, letter)
    if node.links.length == 0 && node != @root_node
      node.disappear
      delete_nodes(characters.join, letter)
    end
  end

  def delete_nodes(word, key = "") 
    node = node_finder(word)
    node.delete_key(key)
    characters = word.chars
    letter = characters.delete_at(-1)
    vanish_node(node, characters, letter)
  end
  
  def delete(word)
    node = node_finder(word)
    if node != nil && node.terminator
      node.remove_terminator 
      delete_nodes(word)
    end
  end

end
