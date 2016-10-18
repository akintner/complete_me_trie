require 'simplecov'
SimpleCov.start

require_relative '../lib/node'
require_relative '../lib/complete_me.rb'
require "minitest/autorun"
require "minitest/pride"

class CompleteMeTest < Minitest::Test

  def test_it_exists
    assert CompleteMe.new
  end

  def test_complete_me_initializes_with_a_root_node_with_no_letter
    completion = CompleteMe.new
    assert_equal "", completion.root_node.letter
  end

  def test_it_inserts_the_word_pizza
    completion = CompleteMe.new
    completion.insert('pizza')
    result = completion.root_node.includes_link?('p')
    assert_equal true, result
  end

  def test_it_keeps_track_of_words_inserted
    completion = CompleteMe.new
    completion.insert('pizza')
    assert_equal 1, completion.count
  end

  def test_it_inserts_multiple_words
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('hello')
    completion.insert('world')
    assert_equal 3, completion.count
  end

  def test_inserting_the_same_word_twice_does_not_increase_count
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pizza')
    assert_equal 1, completion.count
  end

  def test_find_suggestions_t_from_a
    completion = CompleteMe.new
    completion.insert('at')
    node_at_a = completion.root_node.link_to('a')
    suggestions = completion.find_suggestions(node_at_a)
    assert_equal ['t'], suggestions
  end

  def test_find_suggestions_gives_all_words_from_root_node
    completion = CompleteMe.new
    completion.insert('ant')
    completion.insert('and')
    completion.insert('at')
    suggestions = completion.find_suggestions(completion.root_node)
    assert_equal ['ant', 'and', 'at'], suggestions
  end

  def test_find_suggestions_finds_nt_nd_t_from_ant_and_at
    completion = CompleteMe.new
    completion.insert('ant')
    completion.insert('and')
    completion.insert('at')
    node_at_a = completion.root_node.link_to('a')
    suggestions = completion.find_suggestions(node_at_a)
    assert_equal ['nt', 'nd', 't'], suggestions
  end

  def test_find_suggestions_finds_izza_zaz_and_izzeria_from_piz
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pizzeria')
    completion.insert('pizzaz')
    node_at_z = completion.root_node.link_to('p').link_to('i').link_to('z')
    suggestions = completion.find_suggestions(node_at_z)
    assert_equal ['za','zaz', 'zeria'], suggestions
  end

  def test_find_node_z_given_fragment_piz
    completion = CompleteMe.new
    completion.insert('pizza')
    result = completion.node_finder('piz').letter
    assert_equal 'z', result
  end

  def test_it_can_find_root_node
    completion = CompleteMe.new
    node = completion.node_finder("")
    assert_equal completion.root_node, node
  end

  def test_it_suggests_all_words_given_nothing
    completion = CompleteMe.new
    completion.insert('an')
    completion.insert('at')
    completion.insert('pie')
    suggestion = completion.suggest("")
    assert_equal ["an", "at", "pie"], suggestion
  end

  def test_it_suggests_an_from_a
    completion = CompleteMe.new
    completion.insert('an')
    suggestion = completion.suggest('a')
    assert_equal ['an'], suggestion
  end

  def test_it_suggests_at_and_an_from_a
    completion = CompleteMe.new
    completion.insert('an')
    completion.insert('at')
    suggestion = completion.suggest('a')
    assert_equal ['an', 'at'], suggestion
  end

  def test_it_suggests_ant_from_an
    completion = CompleteMe.new
    completion.insert('ant')
    suggestion = completion.suggest('an')
    assert_equal ['ant'], suggestion
  end

  def test_it_suggests_pizzeria_and_pizza_from_piz
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pizzeria')
    suggestion = completion.suggest('piz')
    assert_equal ['pizza', 'pizzeria'], suggestion
  end

  def test_it_suggests_pizzeria_pizza_pizzaz_from_piz
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pizzeria')
    completion.insert('pizzaz')
    suggestion = completion.suggest('piz')
    assert_equal ['pizza', 'pizzaz','pizzeria'], suggestion
  end

  def test_it_populates_an_input_file
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/simple_words.txt')
    completion.populate(dictionary)
    assert_equal 19, completion.count
  end

  def test_it_populates_an_input_file_and_makes_suggestions
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/simple_words.txt')
    completion.populate(dictionary)
    suggestion = completion.suggest('he')
    assert_equal ['hell','hello'] , suggestion
  end

  def test_it_populates_and_doesnt_suggest_its_fragment
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/simple_words.txt')
    completion.populate(dictionary)
    suggestion = completion.suggest('mass')
    assert_equal ['massive','massif'] , suggestion
  end

  def test_it_populates_huge_file
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)
    assert_equal 235886, completion.count
  end

  def test_it_populates_huge_number_of_words_and_makes_suggestions
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/words.txt')
    completion.populate(dictionary)
    suggestion = completion.suggest('aar')
    assert_equal ["aardvark", "aardwolf"], suggestion
  end

  def test_it_suggests_nothing_when_no_words_are_there
    completion = CompleteMe.new
    suggestion = completion.suggest('a')
    assert_equal [], suggestion
  end

  def test_it_suggests_nothing_given_crazy_fragment
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/simple_words.txt')
    completion.populate(dictionary)
    suggestion = completion.suggest('zzzzzzzz')
    assert_equal [], suggestion
  end

  def test_it_deletes_nothing_when_nothing_is_passed
    completion = CompleteMe.new
    refute completion.delete("")
  end

  def test_it_deletes_nothing_when_no_words_exists
    completion = CompleteMe.new
    refute completion.delete("pizza")
  end

  def test_it_deletes_nothing_when_something_exists
    completion = CompleteMe.new
    completion.insert('pizza')
    refute completion.delete("")
  end

  def test_delete_removes_terminator
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.delete('pizza')
    suggestion = completion.suggest('piz')
    assert_equal [], suggestion
  end
  
  def test_delete_removes_terminator_with_populated_list
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/simple_words.txt')
    completion.populate(dictionary)
    completion.delete('pizza')
    suggestion = completion.suggest('piz')
    assert_equal ["pizzaz", "pizzeria"] , suggestion
  end

  def test_delete_then_insert_puts_word_back
    completion = CompleteMe.new
    dictionary = File.read('./test/dictionaries/simple_words.txt')
    completion.populate(dictionary)
    completion.delete('pizza')
    completion.insert('pizza')
    suggestion = completion.suggest('piz')
    assert_equal ["pizza","pizzaz", "pizzeria"] , suggestion
  end

  def test_it_deletes_nodes
    completion = CompleteMe.new
    completion.insert('pi')
    completion.delete('pi')
    result = completion.root_node.includes_link?('p')
    assert_equal false, result
  end

  def test_it_deletes_nodes_all_the_way_to_root
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pets')
    completion.delete('pizza')
    result = completion.root_node.link_to('p').includes_link?('i')
    assert_equal false, result
  end

  def test_it_deletes_only_necessary_nodes
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pets')
    completion.insert('pie')
    completion.delete('pizza')
    result_true = completion.root_node.link_to('p').link_to('i').includes_link?('e')
    result_false = completion.root_node.link_to('p').link_to('i').includes_link?('z')
    assert_equal true, result_true
    assert_equal false, result_false
  end

  def test_delete_removes_word_from_count
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.delete('pizza')
    assert_equal 0, completion.count
  end

  def test_deleting_nothing_removes_no_words_from_count
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.delete('pi')
    assert_equal 1, completion.count
  end

  def test_select_adds_selection_to_word
    completion = CompleteMe.new
    completion.insert('an')
    completion.select('a', 'an')
    completion.node_finder('an').inspect
    result = completion.node_finder('an').selects
    assert_equal 1, result
  end

  def test_selecting_twice_adds_selection_to_word
    completion = CompleteMe.new
    completion.insert('an')
    completion.select('a', 'an')
    completion.select('a', 'an')
    result = completion.node_finder('an').selects
    assert_equal 2, result
  end

  def test_selecting_only_works_when_word_is_a_suggestion
    completion = CompleteMe.new
    completion.insert('an')
    completion.select('p', 'an')
    result = completion.node_finder('an').selects
    assert_equal 0, result
  end

  def test_selecting_nothing_does_nothing
    completion = CompleteMe.new
    refute completion.select('', '')
  end

  def test_it_suggest_sorts_by_selections
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('pizzeria')
    completion.select('piz', 'pizzeria')
    result = completion.suggest('piz')
    assert_equal ['pizzeria', 'pizza'], result
  end
  
end