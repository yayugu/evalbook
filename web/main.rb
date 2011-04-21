$KCODE = 'u'
require 'yaml/store'
require 'rubygems'
require 'haml'
require 'sinatra'

$LOAD_PATH.push "../typesetting"
require 'xml.rb'
require 'ybook.rb'


helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def base_url
    default_port = (request.scheme == "http") ? 80 : 443
    port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
    "#{request.scheme}://#{request.host}#{port}"
  end

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
    open("#{$dir_tmp}/#{filename}.tex", 'w'){|fp| fp.write(ERB.new(template).result(binding))}
    open("#{$dir_tmp}/#{filename}.sh", 'w'){|fp| fp.write(<<-"EOF")}
      platex -interaction=nonstopmode #{$dir_tmp}/#{filename}.tex
      dvipdfmx -p #{t.width}pt,#{t.height}pt #{$dir_tmp}/#{filename}.dvi
      mv #{filename}.pdf ../public/tmp
      rm #{filename}.tex #{filename}.dvi
      EOF
    do_command($dir_tmp, "sh #{filename}.sh")
    filename
  end

  $pwd = Dir.pwd
  $dir_typesetting =  File.expand_path "../typesetting"
  $dir_tmp = File.expand_path "./tmp"
end

configure do
  $db = YAML::Store.new('./data.yaml')
  $db.transaction do
    $db[:book] = {} if $db[:book] == nil
  end
  enable :sessions
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/' do
  $db.transaction do
    haml :index
  end
end

get '/makeTransform' do
  haml :make_transform
end

get '/make' do
  @title = ''
  @text = ''
  haml :make
end

get '/make/:title' do |title|
  @title = title
  $db.transaction do
    @text = $db[:book][title]
  end
  haml :make
end

post '/make_post' do
  $db.transaction do
    $db[:book][params[:title]] = params[:text].gsub(/\r\n/, "\n")
  end
  redirect base_url
end

get '/view/:title' do |title|
  @title = title
  haml :view
end

post '/view-post' do
  title = params[:title]

  t = ErbTemplate.new
  t.display_size = t.in_to_pt params[:display_inch].to_f
  t.fontsize = params[:fontsize].to_f
  if params[:angle] == 'tate'
    t.pixel_x = params[:pixel_shorter].to_f
    t.pixel_y = params[:pixel_longer].to_f
  else
    t.pixel_x = params[:pixel_longer].to_f
    t.pixel_y = params[:pixel_shorter].to_f
  end
  t.pixel_y -= params[:pixel_statusbar_height].to_f

  t.wabun_bairitsu = 0.9375
  t.lineskip_zw = 1.75
  t.parindent_zw = 1
  t.body = ''

  text = nil
  $db.transaction do
    text = $db[:book][title]
  end

  filename = typeset(t, text)

  "success <a href=#{base_url}/tmp/#{filename}.pdf>PDF</a>"
end


