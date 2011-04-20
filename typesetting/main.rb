require 'xml.rb'
require 'ybook.rb'

t = ErbTemplate.new
t.display_size = t.in_to_pt 9.7; t.pixel_x = 1004; t.pixel_y = 768
t.display_size = t.in_to_pt 3.5; t.pixel_x = 320; t.pixel_y = 460
#t.display_size = t.in_to_pt 6.5; t.pixel_x = 320; t.pixel_y = 460

t.fontsize = 12 
t.wabun_bairitsu = 0.9375
t.lineskip_zw = 1.75
t.parindent_zw = 1
t.body = ''

parser = Nokogiri::HTML::SAX::Parser.new(HTMLDoc.new(t))
parser.parse(File.read(ARGV[0]))
#puts t.body
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

