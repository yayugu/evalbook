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
  attr_accessor :title,
                :author,
                :body, 
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
    headheight
  end

  def headheight
    tiny
  end

  def headsep
    maxsep = height - textwidth - headheight - topmargin
    if maxsep * 0.3 > small
      maxsep * 0.7
    else
      maxsep - small
    end
  end

  def topskip
    0
  end

  def textheight
    ((width * 0.925 / lineskip(@fontsize)).to_i - 1) * lineskip(@fontsize) + @fontsize
  end

  def oddsidemargin
    (width - textheight - tiny / 2) / 2
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

  def tiny
    @fontsize * 0.5
  end

  def small
    @fontsize * 0.8
  end

  def normalsize
    @fontsize
  end

  def large
    @fontsize * 1.3
  end

  def Large
    @fontsize * 1.5
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

