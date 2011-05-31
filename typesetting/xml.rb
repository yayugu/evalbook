# coding: utf-8

require 'nokogiri'
require 'uri'
require 'RMagick'

class HTMLDoc < Nokogiri::XML::SAX::Document
  def initialize t
    @t = t
    @mode = [:normal]
    @zenkaku_kagikakko = false
    @force_kansuji = false
    super()
  end

  def start_element name, attrs = []
    case name
    when 'set'
      set_option attrs
    when 'title'
      @mode = :title
    when 'author'
      @t.body << "\n\n\\hfill "
    when 'br'
      @t.body << '\\par{}'
    when 'p'
      @t.body << "\\vspace{1zw plus .1zw minus .4zw}\n\n"
    when 'hr'
      @t.body << "
        \\vspace{1zw plus .1zw minus .4zw}\n\n
        \n\n\\noindent
        \\hfil
        \\rule{#{@t.textwidth_consider_column * 0.7}pt}{.01zw}
        \\hfill\n\n"
    when 'rb'
      @t.body << '\\kana{'
    when 'rt'
      @t.body << '{'
    when 'rp'
      @mode.push :ignore
    when 'a'
      @mode.push :a_link
      @t.body << begin_a(attrs)
    when 'h2'
      @t.body << '{\gtfamily\bfseries '
    when 'img'
      @t.body << tag_img(attrs)
    when 'pre'
      @t.body << '\\begin{Verbatim}[fontsize=\\small, frame=leftline]'
    when 'pagebreak'
      @t.body << '\n\\clearpage\n'
    when 'jisage'
      @t.body << begin_jisage(attrs)
    when 'dialog_name'
      @t.body << '
        \\noindent{}{\\begin{list}%
         {}%
         {\\setlength{\\topsep}{0zw}%
          \\setlength{\\labelsep}{-1zw}%
          \\setlength{\\itemsep}{0zw}%
          \\setlength{\\leftmargin}{3zw}%
          \\setlength{\\labelwidth}{2zw}
          \\setlength{\\itemindent}{-2zw}}%
        \\item[{\\gt '
    when 'dialog_value'
      @t.body << ''
    end
  end

  def end_element name
    case name
    when 'title'
      @mode.pop
    when 'author'
      @t.body << "\n\n"
    when 'rb'
      @t.body << '}'
    when 'rt'
      @t.body << '}'
    when 'rp'
      @mode.pop
    when 'a'
      @mode.pop
      @t.body << end_a
    when 'h2'
      @t.body << '}'
    when 'pre'
      @t.body << '\\end{Verbatim}'
    when 'jisage'
      @t.body << end_jisage
    when 'dialog_name'
      @t.body << '\\hspace*{1zw}}]'
    when 'dialog_value'
      @t.body << "\n\\end{list}}"
    end
  end

  def characters str
    case @mode.last
    when :ignore
      return
    when :title
      h = @t.fontsize / 2.0
      str.each_char do |char|
        @t.body << "\\raisebox{0pt}[#{h}pt][#{h}pt]{\\Huge\\mcfamily\\bfseries #{char}}\n"
      end
    #when :a_link
      #str.each_char do |char|
      #  @t.body << "\\hbox{\\yoko\\href{#{@a_url}}{\\nolinkurl{#{char}}}}"
      #end
    else
      to_kansuji!(str) if @force_kansuji
      tex_escape!(str)
      str.gsub! /「/, '{\makebox[1zw][r]{「}}' if @zenkaku_kagikakko
      @t.body << str
    end
  end
  
  def begin_a attrs
    url = ''
    attrs.each_slice(2) do |key, value|
      case key
      when 'href'
        @a_url = value
      end
    end
    <<-EOF
\\begingroup
\\catcode`\\_=11
\\catcode`\\%=11
\\catcode`\\#=11
\\catcode`\\$=11
\\catcode`\\&=11
\\special{pdf:bann << /Subtype /Link /Border [0 0 0] /C [0 1 1] /A << /S /URI /URI (#{@a_url}) >> >>}\\endgroup
\\special{color push cmyk 0.75 0.75 0 0.44}
    EOF
  end

  def end_a
    <<-EOF
\\special{color pop}
\\special{pdf:eann}
    EOF
  end


  def begin_jisage attrs
    num = 1
    attrs.each_slice(2) do |key, value|
      case key
      when 'num'
        num = value.to_f
      end
    end
    "\n{\n\\leftskip=#{num}zw\n"
  end

  def end_jisage
    "}"
  end

  def tag_img attrs
    filename = nil
    attrs.each_slice(2) do |key, value|
      case key
      when 'src'
        filename = $dir_tmp + sprintf("/%05d.pdf", rand(100000))
        image = Magick::Image.read(value).first
        image.write('pdf:' + filename)
        p filename
      end
    end
    "\\hbox{\\yoko\\includegraphics{#{filename}}}"
  end

  def set_option attrs
    attrs.each_slice(2) do |key, value|
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
  end

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
  
end

