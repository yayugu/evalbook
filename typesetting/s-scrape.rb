# まおゆうの整形

KCODE = 'u'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

doc = open("s-xml2.xml").read

# 文中改行の削除
doc.gsub! /\s*?\<br( \/)*?>\s*?\n　/, ''
doc.gsub! /\s*?\n　/, ''

# 名前「せりふ」 形式の文のパース、タグ付け
doc.gsub!(/^(\<p\>)(.*?)(「.*?)\</,
          '\\1<dialog_name>\\2</dialog_name><dialog_value>\\3</dialog_value><')
doc.gsub!(/(br(?: \/)?>)\s?\n(.*?)(「.*?)\</,
          '\\1<dialog_name>\\2</dialog_name><dialog_value>\\3</dialog_value><')

doc = Nokogiri::HTML(doc)

opt = Nokogiri::XML::Node::new('set', doc)
opt['lineskip'] = 1.3.to_s
opt['zenkaku_kagikakko'] = true.to_s
opt['force_kansuji'] = true.to_s
doc.at('/html').children[0].add_previous_sibling opt

# 不要文章の削除
doc.search('h3').remove
doc.search('h1').remove

# レス間に水平線を挿入
doc.css('div.mainRes').each do |node|
  node.add_next_sibling Nokogiri::XML::Node::new('hr', doc)
end

open('s-xml22.xml', 'w').write doc.to_html






