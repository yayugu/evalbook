# coding: utf-8

def max(a, b)
  a > b ? a : b
end

class ErbTemplate
  @body
  @display_size
  @pixel_x
  @pixel_y
  @fontsize
  @wabun_bairitsu
  attr_accessor :body, 
                :display_size, 
                :pixel_x, 
                :pixel_y, 
                :fontsize, 
                :wabun_bairitsu,
                :lineskip_zw,
                :parindent_zw

  def initialize
    @wabun_bairitsu = 0.9375
  end

  def width
    @display_size / Math.sqrt(@pixel_x**2 + @pixel_y**2) * @pixel_x.to_f
  end

  def height
    @display_size / Math.sqrt(@pixel_x**2 + @pixel_y**2) * @pixel_y.to_f
  end

  def textwidth
    (height * 0.95 / fontsize).to_i * jpfontsize
  end

  def topmargin
    (height - textwidth) / 2
  end

  def textheight
    (width * 0.925 / lineskip(@fontsize)).to_i * lineskip(@fontsize)
  end

  def oddsidemargin
    #fontsize = @fontsize * @wabun_bairitsu
    #if width < in_to_pt(5)
      #(width - textheight - ((lineskip(fontsize) - fontsize) / 2)) / 2
    #else
      (width - (textheight + @fontsize)) / 2
    #end
  end

  def column
    if textwidth / @fontsize > 40
      "twocolumn"
    else
      "onecolumn"
    end
  end

  def columnsep
    max((topmargin * 1.5 / @fontsize).to_i * jpfontsize, 2 * jpfontsize)
  end

  def textwidth_consider_column
    if column == "twocolumn"
      (textwidth - columnsep) / 2
    else
      textwidth
    end
  end

  def normalsize
    @fontsize
  end

  def tiny
    @fontsize / 2.0
  end

  def huge
    @fontsize + lineskip(@fontsize)
  end

  def lineskip(fontsize)
    fontsize * @lineskip_zw
  end

  def jpfontsize
    @fontsize * @wabun_bairitsu
  end

  def in_to_pt(num)
    num * 72.0
  end

  def cm_to_pt(num)
    num * 28.3464567
  end
end
