# coding: utf-8

require 'nokogiri'
require 'uri'
require 'RMagick'

class TransformHTMLToTex
  def initialize t=nil
    @t = t
    @zenkaku_kagikakko = false
    @force_kansuji = false
  end

  def parse n
    if n.kind_of?(Nokogiri::XML::NodeSet)
      n.map do |node|
        _parse node
      end.join('')
    else
      _parse n
    end
  end

  def _parse node
    if node.kind_of?(Nokogiri::XML::Text)
      text(node.content)
    elsif node.kind_of?(Nokogiri::XML::Node)
      begin
        @node = node
        self.__send__(node.name.downcase){self.parse node.children}
      rescue NoMethodError
        self.parse node.children
      end
    else
      raise "Cannnot parse. Unknown Node: #{node.class.inspect}"
    end
  end

  def text str
    to_kansuji!(str) if @force_kansuji
    tex_escape!(str)
    str.gsub! /「/, '{\makebox[1zw][r]{「}}' if @zenkaku_kagikakko
    str
  end

  def set
    @node.keys.each do |key|
      value = @node[key]
      case key
      when 'lineskip'
        @t.lineskip_zw = value.to_f
      when 'zenkaku_kagikakko'
        if value == 'true'
          @zenkaku_kagikakko = true
        else
          @zenkaku_kagikakko = false
        end
      when 'force_kansuji'
        if value == 'true'
          @force_kansuji = true
        else
          @force_kansuji = false
        end
      when 'parindent'
        @t.parindent_zw = value.to_f
      end
    end
    ''
  end

  def title
    h = @t.fontsize / 2.0
    @node.content.each_char.map do |char|
      "\\raisebox{0pt}[#{h}pt][#{h}pt]{\\Huge\\mcfamily\\bfseries #{char}}\n"
    end.join('')
  end
  def author() "\n\n\\hfill #{yield}\n\n"; end

  def rb() "\\kana{#{yield}}"; end
  def rt() "{#{yield}}"; end
  def rp() ""; end

  def br() '\\par{}'; end
  def hr
    "\
\\vspace{1zw plus .1zw minus .4zw}\n\n
\n\n\\noindent
\\hfil
\\rule{#{@t.textwidth_consider_column * 0.7}pt}{.01zw}
\\hfill\n\n"
  end

  def p() "\\vspace{1zw plus .1zw minus .4zw}\n\n#{yield}"; end

  def pre
    "\
\\begin{Verbatim}[fontsize=\\small, frame=leftline]
    #{yield}
\\end{Verbatim}\n"
  end

  def a
    a_url = ''
    @node.keys.each do |key|
      case key
      when 'href'
        a_url = @node[key]
      end
    end
    "\
\\begingroup\
\\catcode`\\_=11\
\\catcode`\\%=11\
\\catcode`\\#=11\
\\catcode`\\$=11\
\\catcode`\\&=11\
\\special{pdf:bann << /Subtype /Link /Border [0 0 0] /C [0 1 1] /A << /S /URI /URI (#{a_url}) >> >>}\\endgroup\
\\special{color push cmyk 0.75 0.75 0 0.44}\
    #{yield}\
\\special{color pop}\
\\special{pdf:eann}"
  end

  def img
    pixel_to_pt = -> pixel { pixel / 200.0 * 72.0 }
    filename = nil
    width = nil
    height = nil
    original_width = nil
    original_height = nil
    @node.keys.each do |key|
      value = @node[key]
      case key
      when 'src'
        filename = $dir_tmp + sprintf("/%05d.pdf", rand(100000))
        image = Magick::Image.read(value).first
        original_width = pixel_to_pt.(image.base_rows)
        original_height = pixel_to_pt.(image.base_columns)
        image.write('pdf:' + filename)
        puts filename
      when 'width'
        width = pixel_to_pt.(value) if value =~ /^[0-9].*\.[0-9].*$/
      when 'height'
        height = pixel_to_pt.(value) if value =~ /^[0-9].*\.[0-9].*$/
      end
    end

    width, height = Image.resize(
      *(Image.get_width_and_height(width, height, original_width, original_height)),
      @t.textheight,
      @t.textwidth)

    "\\hbox{\\yoko\\includegraphics[keepaspectratio,width=#{width}pt]{#{filename}}}"
  end

  def jisage
    num = 1
    attrs.each_slice(2) do |key, value|
      case key
      when 'num'
        num = value.to_f
      end
    end
    "\n{\n\\leftskip=#{num}zw\n#{yield}}"
  end
  def pagebreak() '\n\\clearpage\n'; end
  def rensuji() "\\rensuji{#{yield}}"; end
  def dialog_name
    "\
      \\noindent{}{\\begin{list}%
         {}%
         {\\setlength{\\topsep}{0zw}%
      \\setlength{\\labelsep}{-1zw}%
      \\setlength{\\itemsep}{0zw}%
      \\setlength{\\leftmargin}{3zw}%
      \\setlength{\\labelwidth}{2zw}%
      \\setlength{\\itemindent}{-2zw}}%
      \\item[{\\gt#{yield}\\hspace*{1zw}}]"
  end
  def dialog_value() "#{yield}\n\\end{list}}"; end

  def tex_escape! str
    # %, #,... to \%, \#,...
    str.gsub!(/\\/, '\\textbackslash ')
    str.gsub!(/([\%\#\$\&\_])/){"\\#{$1}"}
    str.gsub!(/([、。])/){"#{$1}\\hbox{}"}
    str
  end

  def to_kansuji! str
    str.tr!("1234567890%/", "一二三四五六七八九〇％／") if str =~ /[0-9\%]/
  end

  module Image
    def self.get_width_and_height width, height, original_width, original_height
      if width and height
        [width, height]
      elsif !width and !height
        [original_width, original_height]  
      else
        if width
          scale = width / original_width.to_f
          height = original_height * scale
        else
          scale = height / original_height.to_f
          width = original_width * scale
        end
        [width, height]
      end
    end

    def self.resize width, height, max_width, max_height
      width = width.to_f
      height = height.to_f
      max_width = max_width.to_f
      max_height = max_height.to_f
      if width > max_width
        scale = width / max_width
        width = max_width
        height /= scale
      end
      if height > max_height
        scale = height / max_height
        height = max_height
        width /= scale
      end
      [width, height]
    end
  end
end
