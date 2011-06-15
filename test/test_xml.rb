# coding: utf-8
require 'helper'

class TestImage < Test::Unit::TestCase
  def setup
    #@img = HTMLDoc::Image.new
  end

  context 'Image' do
    should 'resize to not overflow space' do
      assert_equal [10, 20], HTMLDoc::Image.resize(10, 20, 20, 20)
      assert_equal [20, 10], HTMLDoc::Image.resize(20, 10, 20, 20)
      assert_equal [10, 20], HTMLDoc::Image.resize(20, 40, 20, 20)
      assert_equal [20, 10], HTMLDoc::Image.resize(40, 20, 20, 20)
    end

    should 'get the other from width and height. keep aspect ratio' do
      assert_equal [10, 20], HTMLDoc::Image.get_width_and_height(10, 20, 20, 20)
      assert_equal [10, 10], HTMLDoc::Image.get_width_and_height(10, nil, 20, 20)
      assert_equal [10, 10], HTMLDoc::Image.get_width_and_height(nil, 10, 20, 20)
      assert_equal [20, 20], HTMLDoc::Image.get_width_and_height(nil, nil, 20, 20)
    end
  end
end
