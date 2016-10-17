require_relative '../lib/node'
require 'pry'

class CompleteMe

  attr_reader :count,
              :root_node

  def initialize
    @count = 0
    @root_node = Node.new
  end

  def add_other_letters(length, letter, characters, node)
    next_node = node.link_to(letter)
    if length == 1
      @count += 1 unless next_node.terminator
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
  
  def populate_suggestions(letter, node, suggestions)
    next_node = node.link_to(letter)
    suggestions << letter if next_node.terminator
    find_suggestions(next_node).each {|suggestion| suggestions << letter + suggestion}
  end
  
  def find_suggestions(node)
    suggestions = []
    node_links = node.links.keys 
    node_links.each {|letter| populate_suggestions(letter, node, suggestions)}
    suggestions
  end

  def suggest(fragment)
    suggestions = []
    node = node_finder(fragment)
    if node!= nil
      second_halves = find_suggestions(node)
      suggestions = second_halves.map {|second_half| fragment + second_half}
    end
    sort_by_selections(suggestions)
  end

  def search(length, letter, characters, node)
    if length == 1
      node.link_to(letter)
    else
      node_finder(characters.join, node.link_to(letter))
    end
  end

  def node_finder(fragment, node = @root_node)
    return @root_node if fragment == ""
    length = fragment.length
    characters = fragment.chars
    letter = characters.delete_at(0)
    search(length, letter, characters, node) if node.includes_link?(letter)
  end

  def populate(dictionary)
    words_array = dictionary.split("\n")
    words_array.each {|word| insert(word)}
  end

  def vanish_node(node, characters, letter)
    if node != @root_node && node.links.length == 0
      node.disappear
      delete_nodes(characters.join, letter)
    end
  end

  def delete_nodes(word,previous_letter = "")
    node = node_finder(word)
    characters = word.chars
    letter = characters.delete_at(-1)
    if node != nil
      node.delete_key(previous_letter)
      vanish_node(node, characters, letter)
    end
  end

  def remove_terminator_and_delete(node, word)
    if node.terminator
      node.remove_terminator 
      delete_nodes(word) if node.links.length == 0
      @count -= 1
    end
  end

  def delete(word)
    node = node_finder(word)
    remove_terminator_and_delete(node, word) if node != nil
  end

  def select(fragment, word)
    node = node_finder(word)
    if suggest(fragment).include?(word)
      node.select if node != nil
    end
  end

  def sort_by_selections(words)
    suggestions = words.sort_by do |word|
      node_finder(word).selects * -1
    end
  end

end
