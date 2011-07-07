require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task default: :test

task :fontmap do
  require 'erubis'
  erb = Erubis::Eruby.new(open('./sty/dvipdfmxFontMap.erb').read)

  # not embed fonts
  gothic = 'GothicBBB-Medium'
  gothic_bold = 'GothicBBB-Medium,Bold'
  gothic_exbold = 'GothicBBB-Medium,Bold'
  marugothic = 'GothicBBB-Medium'
  mincho = 'Ryumin-Light'
  mincho_bold = 'Ryumin-Light,Bold'
  open('./sty/notembed.map', 'w').write erb.result(binding)

  # embed fonts
end


