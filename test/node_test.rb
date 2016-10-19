require './lib/node'
require "minitest/autorun"
require "minitest/pride"

class NodeTest < Minitest::Test

  def test_it_exists
    assert Node.new('a')
  end

  def test_it_knows_its_letter
    node = Node.new('a')
    assert_equal 'a', node.letter
  end

  def test_it_inserts_links
    node = Node.new('a')
    node.insert_link('b')
    assert_equal ['b'], node.links.keys
  end

  def test_it_inserts_multiple_links_and_saves_keys
    node = Node.new('a')
    node.insert_link('b')
    node.insert_link('c')
    assert_equal ['b','c'], node.links.keys
  end

  def test_it_links_to_a_node_given_a_letter
    node = Node.new('a')
    node.insert_link('b')
    assert_equal 'b', node.link_to('b').letter
  end

  def test_it_knows_its_one_link
    node = Node.new('a')
    node.insert_link('b')
    assert_equal true, node.includes_link?('b')
  end

  def test_it_inserts_multiple_links
    node = Node.new('a')
    node.insert_link('b')
    node.insert_link('c')
    assert_equal true, node.includes_link?('c')
  end

  def test_by_default_it_is_not_a_terminator
    node = Node.new('a')
    refute node.terminator
  end

  def test_make_terminator_makes_it_a_terminator
    node = Node.new('a')
    node.make_terminator
    assert node.terminator
  end

  def test_delete_removes_terminator
    node = Node.new('a')
    node.make_terminator
    node.remove_terminator
    refute node.terminator
  end

  def test_disappear_removes_links
    node = Node.new('p')
    node.links['i'] = Node.new('i')
    node.disappear 
    assert_equal({}, node.links)
  end

  def test_delete_key_removes_key
    node = Node.new('p')
    node.links['i'] = Node.new('i')
    node.delete_key('i')
    assert_equal({}, node.links)
  end

  def test_delete_key_removes_only_key
    node = Node.new('p')
    node.links['i'] = Node.new('i')
    node.links['e'] = Node.new('e')
    node.delete_key('i')
    assert_equal 1, node.links.length
  end

  def test_0_selects_by_default
    node = Node.new('p')
    assert_equal 0, node.selects
  end

  def test_select_increments_selects_by_1
    node = Node.new('p')
    node.select
    assert_equal 1, node.selects
  end
  
end