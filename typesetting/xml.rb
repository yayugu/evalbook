# coding: utf-8

require 'nokogiri'

class HTMLDoc < Nokogiri::XML::SAX::Document
  def initialize t
    @t = t
    @mode = :normal
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
      @mode = :ignore
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
      @mode = :normal
    when 'author'
      @t.body << "\n\n"
    when 'rb'
      @t.body << '}'
    when 'rt'
      @t.body << '}'
    when 'rp'
      @mode = :normal
    when 'jisage'
      @t.body << end_jisage
    when 'dialog_name'
      @t.body << '\hspace*{1zw}}]'
    when 'dialog_value'
      @t.body << "\n\\end{list}}"
    end
  end

  def characters str
    case @mode
    when :ignore
      return
    when :title
      h = @t.fontsize / 2.0
      str.each_char do |char|
        @t.body << "\\raisebox{0pt}[#{h}pt][#{h}pt]{\\Huge\\mcfamily\\bfseries #{char}}\n"
      end
    else
      to_kansuji!(str) if @force_kansuji
      tex_escape!(str)
      str.gsub! /「/, '{\makebox[1zw][r]{「}}' if @zenkaku_kagikakko
      @t.body << str
    end
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
    str.gsub!(/([\%\#\$\&\_])/){"\\#{$1}"}
    str.gsub!(/([、。])/){"#{$1}\\hbox{}"}
    str
  end

  def to_kansuji! str
    str.tr!("1234567890%/", "一二三四五六七八九〇％／") if str =~ /[0-9\%]/
  end
  
end

