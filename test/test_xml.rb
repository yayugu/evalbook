# coding: utf-8
require 'helper'

class TestImage < Test::Unit::TestCase
  def setup
    #@img = HTMLDoc::Image.new
  end

  context 'image' do
    should 'resize to not overflow space' do
      assert_equal [10, 20], HTMLDoc::Image.resize(10, 20, 20, 20)
      assert_equal [20, 10], HTMLDoc::Image.resize(20, 10, 20, 20)
      assert_equal [10, 20], HTMLDoc::Image.resize(20, 40, 20, 20)
      assert_equal [20, 10], HTMLDoc::Image.resize(40, 20, 20, 20)
    end
  end
end
