# coding: utf-8

require 'nokogiri'
require 'uri'
require 'RMagick'

class TransformHTMLToTex
  def self.tag name, &block
    define_method('tag_' + name.to_s, block)
  end

  def initialize t=nil
    @t = t
    @zenkaku_kagikakko = false
    @force_kansuji = false
    @bungaku_style = false
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
        @recur = proc{self.parse node.children}
        self.__send__('tag_' + node.name.downcase)
      rescue NoMethodError
        self.parse node.children
      end
    else
      raise "Cannnot parse. Unknown Node: #{node.class.inspect}"
    end
  end

  def recur
    @recur.call
  end

  def text str
    to_kansuji!(str) if @force_kansuji
    tex_escape!(str) unless @bungaku_style
    str.gsub! /「/, '{\makebox[1zw][r]{「}}' if @zenkaku_kagikakko
    if @hyperlink
      a_text str
    else 
      str
    end
  end

  tag :set do
    @node.keys.each do |key|
      value = @node[key]
      case key
      when 'lineskip'
        @t.lineskip_zw = value.to_f
      when 'zenkaku_kagikakko'
        @zenkaku_kagikakko = (value == 'true')
      when 'force_kansuji'
        @force_kansuji = (value == 'true')
      when 'bungaku_style'
        @bungaku_style = (value == 'true')
      when 'parindent'
        @t.parindent_zw = value.to_f
      end
    end
    ''
  end

  tag :title do
    @t.title = @node.content

    #h = @t.fontsize / 2.0
    #@node.content.each_char.map do |char|
    #  "\\raisebox{0pt}[#{h}pt][#{h}pt]{\\huge\\mcfamily\\bfseries #{char}}\n"
    #end.join('')
    ''
  end
  tag(:author) do 
    @t.author = @node.content
    ''
  end

  tag(:rb) {"\\kana{#{recur}}"}
  tag(:rt) {"{#{recur}}"}
  tag(:rp) {""}

  tag(:br) {'\\par{}'}
  tag :hr do
    "\
\\vspace{1zw plus .1zw minus .4zw}\n\n
\n\n\\noindent
\\hfil
\\rule{#{@t.textwidth_consider_column * 0.7}pt}{.01zw}
\\hfill\n\n"
  end

  tag(:p) {"\\vspace{1zw plus .1zw minus .4zw}\n\n#{recur}"}

  tag :pre do
    "\
\\begin{Verbatim}[fontsize=\\small, frame=leftline]
    #{recur}
\\end{Verbatim}\n"
  end

  tag :font do
    size = 0
    @node.keys.each do |key|
      case key
      when 'size'
        size = @node[key].to_i
        p size
      end
    end
    if (-4...5) === size
      p 'hre'
      tex_size = %w[tiny scriptsize footnotesize small normalsize large Large LARGE huge Huge]
      "{\\#{tex_size[size + 4]} #{recur}}"
    else
      recur
    end
  end

  tag(:h2) do 
    if @bungaku_style
      recur
    else
      "\\vspace{1zw plus 1zw minus 1zw}{\\Large\\gtfamily\\bfseries #{recur}}"
    end
  end
  tag(:h3) do 
    if @bungaku_style
      recur
    else
      "\\vspace{1zw plus 1zw minus 1zw}{\\large\\gtfamily\\bfseries #{recur}}"
    end
  end
  tag(:h4) do 
    if @bungaku_style
      recur
    else
      "{\\gtfamily\\bfseries #{recur}}"
    end
  end


  tag :a do
    @a_url = ''
    @node.keys.each do |key|
      case key
      when 'href'
        @a_url = @node[key]
      end
    end
    @hyperlink = true
    ret = recur
    @hyperlink = false
    ret
  end

  def a_img width, height
    "\
\\begingroup\
\\catcode`\\_=11\
\\catcode`\\%=11\
\\catcode`\\#=11\
\\catcode`\\$=11\
\\catcode`\\&=11\
\\special{pdf:ann width #{width}pt height #{height}pt \
<< /Subtype /Link /A << /S /URI /URI (#{@a_url}) >> >>}\\endgroup \
    "
  end

  def a_text text
    "\
\\begingroup\
\\catcode`\\_=11\
\\catcode`\\%=11\
\\catcode`\\#=11\
\\catcode`\\$=11\
\\catcode`\\&=11\
\\special{pdf:bann << /Subtype /Link /Border [0 0 0] /C [0 1 1] /A << /S /URI /URI (#{@a_url}) >> >>}\\endgroup \
\\special{color push cmyk 0.75 0.75 0 0.44}\
    #{text}\
\\special{color pop}\
\\special{pdf:eann}"
  end

  tag :img do
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
        original_width = pixel_to_pt.(image.base_columns)
        original_height = pixel_to_pt.(image.base_rows)
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

    "\
\\hbox{\\yoko#{a_img(width, height) if @hyperlink}\
\\includegraphics[keepaspectratio,width=#{width}pt]{#{filename}}}\
    "
  end

  tag :jisage do
    num = 1
    @node.keys.each do |key|
      case key
      when 'num'
        num = @node[key].to_f
      end
    end
    "\n{\n\\leftskip=#{num}zw\n#{recur}}"
  end
  tag(:pagebreak) {"\n\\clearpage\n"}
  tag(:rensuji) {"\\rensuji{#{recur}}"}
  tag(:note) {"\\footnote{#{recur}}"}

  tag :dialog_name do
    "\
      \\noindent{}{\\begin{list}%
         {}%
         {\\setlength{\\topsep}{0zw}%
      \\setlength{\\labelsep}{-1zw}%
      \\setlength{\\itemsep}{0zw}%
      \\setlength{\\leftmargin}{3zw}%
      \\setlength{\\labelwidth}{2zw}%
      \\setlength{\\itemindent}{-2zw}}%
      \\item[{\\gt#{recur}\\hspace*{1zw}}]"
  end
  tag(:dialog_value) {"#{recur}\n\\end{list}}"}

  tag(:ignore) { '' }

  tag(:utf) { "\\UTF{#{@node.content}}" }

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
