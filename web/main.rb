# coding: utf-8
require 'bundler/setup'
require 'open-uri'
require 'active_support/core_ext'
require 'haml'
require 'sinatra'

$LOAD_PATH.push "../typesetting"
require 'typesetting.rb'

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def base_url
    default_port = (request.scheme == "http") ? 80 : 443
    port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
    "#{request.scheme}://#{request.host}#{port}"
  end

  def valid?(params)
    [:display_inch, :pixel_longer, :pixel_shorter].each{|param| return false if params[param].blank?}
  end

  def fill_params(params = {})
    @p = {}
    {
      source_url: '',
      display_inch: '',
      pixel_longer: '',
      pixel_shorter: '',
      pixel_statusbar_height: '0',
      fontsize: 10,
      fontembed: true,
      auto_dect_environment: true,
      direct_download: false
    }.each do |key, value|
      @p[key] = params[key].presence || value
    end
  end


  $pwd = Dir.pwd
  $dir_typesetting =  File.expand_path "../typesetting"
  $dir_sty = File.expand_path "../sty"
  $dir_tmp = File.expand_path "../tmp"
  $dir_public_tmp = File.expand_path "./public/tmp"
  Dir.mkdir($dir_public_tmp) unless File.exist?($dir_public_tmp)
end

configure do
  enable :sessions
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/' do
  haml :index
end

get '/view' do
  fill_params params
  haml :view
end

get '/view-get' do
  unless valid?(params)
    raise "error"
  end

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
  t.parindent_zw = 0
  t.body = ''

  text = open(params[:source_url]).read
  filename = typeset(t, text)

  if params[:redirect]
    redirect "#{base_url}/tmp/#{filename}.pdf"
  else
    "#{base_url}/tmp/#{filename}.pdf"
  end

end


