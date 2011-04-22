# coding: utf-8

require 'erb'
require 'ybookML'

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
    @wabun_bairitsu = 0.962216
  end

  def width
    @display_size / Math.sqrt(@pixel_x**2 + @pixel_y**2) * @pixel_x.to_f
  end

  def height
    @display_size / Math.sqrt(@pixel_x**2 + @pixel_y**2) * @pixel_y.to_f
  end

  def textwidth
    fontsize = @fontsize * @wabun_bairitsu
    (height * 0.95 / fontsize).to_i * fontsize
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
    max((topmargin * 1.5 / @fontsize).to_i * @fontsize, 2 * @fontsize)
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

  def in_to_pt(num)
    num * 72.0
  end

  def cm_to_pt(num)
    num * 28.3464567
  end
end

if __FILE__ == $0
  t = ErbTemplate.new
  #t.body = open(ARGV[0], 'r').read
  t.display_size = t.in_to_pt 9.7
  #t.pixel_x = 320
  #t.pixel_y = 460
  #t.display_size = t.in_to_pt 3.5
  t.pixel_x = 768
  t.pixel_y = 1004
  t.fontsize = 12
  t.wabun_bairitsu = 0.962216
  t.body = YbookML.new(open(ARGV[0], 'r').read, t).translate_to_tex
  template = open('layout.erb', 'r').read
  open(ARGV[0] + '.tex', 'w').write(ERB.new(template).result)

  open('tex.sh', 'w').write("
  cd #{Dir.pwd}
  platex #{ARGV[0]}.tex
  dvipdfmx -p #{t.width}pt,#{t.height}pt #{ARGV[0]}.dvi")

  def do_command(dirname, command)
    result = nil
    Dir.chdir(dirname) do
      result = system(command)
      unless result
        puts 'Error: command failed (#{command})'
        exit
      end
    end
    puts command.to_s
    return result
  end

  latexfile = ARGV[0] + '.tex'
  latex_file_path = File.expand_path latexfile
  working_dir = File.dirname latex_file_path
  do_command(working_dir, 'sh tex.sh')
end
