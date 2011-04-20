$KCODE = 'u'
require 'strscan'
require 'pp'

class YbookML
  def initialize(text, t)
    @text = text
    @s = StringScanner.new(text)
    @res = nil
    @t = t
  end

  def parse
    @res ||= begin
      @res = []
      while m = parse_command || parse_furigana || parse_toten || parse_kuten || plain
        @res << m
      end
      @res
    end
  end

  def parse_command
    if @s.scan(/\*([a-zA-Z\_\-]+?)\[(.*?)\]\[(.*?)\]/)
      [:command, {:name => @s[1], :value => [@s[2], @s[3]]}]
    elsif @s.scan(/\*([a-zA-Z\_\-]+?)\[(.*?)\]/)
      [:command, {:name => @s[1], :value => @s[2]}]
    end
  end

  def parse_furigana
    if @s.scan(/(.)\[([^\[\]]*?)\]\[(.)\]/)
      [:command, {:name => 'furigana', :value => [@s[1], @s[2], @s[3]]}]
    elsif @s.scan(/(.)\[(.*?)\]/)
      [:command, {:name => 'furigana', :value => [@s[1], @s[2], '1']}]
    end
  end

  def parse_toten
    if @s.scan(/、/)
      [:toten, '']
    end
  end

  def parse_kuten
    if @s.scan(/。/)
      [:kuten, '']
    end
  end

  def plain
    if @s.scan(/./m)
      [:plain, @s[0]]
    end
  end

  def command_furigana(kanji, kana, rule = 1)
    "\\kana[#{rule}]{#{kanji}}{#{kana}}"
  end

  def command_title(text)
    "{\\huge #{text}} \\\\"
  end

  def command_author(text)
    "\\hfill #{text}\\\\"
  end

  def command_image(value)
    name = value[0]
    size = value[1]
    if size == 'page'
      if @t.column == "twocolumn"
        "
         \\noindent\\includegraphics[width=\\textheight,%
                                     height=#{@t.textwidth_consider_column}pt,%
                                     keepaspectratio,angle=90]{#{name}}%
        "
      else
        "
         \\hfil%
         \\includegraphics[width=\\textheight,height=#{@t.textwidth_consider_column}pt,%
                           keepaspectratio,angle=90]{#{name}}%
         \\hfill
        "
      end
    else
      p @t.cm_to_pt(size.to_f)
      if @t.cm_to_pt(size.to_f) > @t.textheight
        "
         \\hfil%
         \\includegraphics[width=\\textheight,height=#{@t.textwidth_consider_column}pt,%
                           keepaspectratio, angle=90]{#{name}}%
         \\hfill
        "
      else
        "
         \\hfil%
         \\includegraphics[width=#{size}cm,keepaspectratio,angle=90]{#{name}}%
         \\hfill
        "
      end
    end
  end

  def commnad_tcy(text)
    "\\rensuji{#{text}}"
  end

  def translate_to_tex
    res = ''
    parse.each do |st|
      key, value = *st
      res << case key
      when :command
        case value[:name]
        when 'furigana'
          command_furigana(*value[:value])
        when 'title'
          command_title(value[:value])
        when 'author'
          command_author(value[:value])
        when 'image'
          command_image(value[:value])
        when 'tcy'
          commnad_tcy(value[:value])
        end
      when :toten
        "\\、"
      when :kuten
        "\\。"
      when :plain
        value
      end
    end
    res
  end
end


#text = open('sample-ybookml.txt', 'r').read
#YbookML.new(text).translate_to_tex

