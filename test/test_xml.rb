# coding: utf-8
require 'helper'

class TestImage < Test::Unit::TestCase
  def setup
    #@img = TransformHTMLToTeX::Image.new
  end

  context 'Image' do
    should 'resize to not overflow space' do
      assert_equal [10, 20], TransformHTMLToTex::Image.resize(10, 20, 20, 20)
      assert_equal [20, 10], TransformHTMLToTex::Image.resize(20, 10, 20, 20)
      assert_equal [10, 20], TransformHTMLToTex::Image.resize(20, 40, 20, 20)
      assert_equal [20, 10], TransformHTMLToTex::Image.resize(40, 20, 20, 20)
    end

    should 'get the other from width and height. keep aspect ratio' do
      assert_equal [10, 20], TransformHTMLToTex::Image.get_width_and_height(10, 20, 20, 20)
      assert_equal [10, 10], TransformHTMLToTex::Image.get_width_and_height(10, nil, 20, 20)
      assert_equal [10, 10], TransformHTMLToTex::Image.get_width_and_height(nil, 10, 20, 20)
      assert_equal [20, 20], TransformHTMLToTex::Image.get_width_and_height(nil, nil, 20, 20)
    end
  end
end

class TestTransformHTMLToTex < Test::Unit::TestCase
  def setup
    @p = TransformHTMLToTex.new
  end
  
  should 'parse XML' do
    assert_equal '', @p.parse(Nokogiri::XML('Hello, World!'))
    assert_equal 'Hello, World!', @p.parse(Nokogiri::XML('<unknowntag>Hello, World!</unknowntag>'))

  end

  should 'parse ruby(ルビ)' do
    assert_equal '\kana{阿井宇}{あいう}',
                 @p.parse(Nokogiri::XML('<ruby><rb>阿井宇</rb><rp>(</rp><rt>あいう</rt><rp>)</rp></ruby>'))
  end
  
  should 'parse a(hyperlink)' do
    #assert_equal '', @p.parse(Nokogiri::XML('<a href="http://google.com/">google</a>'))
  end

end

