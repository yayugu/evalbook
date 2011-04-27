# coding: utf-8
require 'erubis'
require 'xml.rb'
require 'ybook.rb'

def do_command(dirname, command)
  result = nil
  Dir.chdir(dirname) do
    result = system(command)
    unless result
      puts "Error: command failed (#{command})"
      raise Exception
    end
  end
  puts command.to_s
  Dir.chdir($pwd)
  return result
end

def typeset(t, text)
  parser = Nokogiri::HTML::SAX::Parser.new(HTMLDoc.new(t)).parse(text)
  filename = "ag-" + sprintf("%05d", rand(100000))
  template = open($dir_typesetting + '/layout.erb', 'r').read
  open("#{$dir_tmp}/#{filename}.tex", 'w'){|fp| fp.write(Erubis::Eruby.new(template).result(binding))}
  open("#{$dir_tmp}/#{filename}.sh", 'w'){|fp| fp.write(<<-"EOF")}
      platex -interaction=nonstopmode #{$dir_tmp}/#{filename}.tex
      dvipdfmx -p #{t.width}pt,#{t.height}pt #{$dir_tmp}/#{filename}.dvi
      mv #{filename}.pdf #{$dir_public_tmp}
      #rm #{filename}.tex #{filename}.dvi
  EOF
  do_command($dir_tmp, "sh #{filename}.sh")
  filename
end

