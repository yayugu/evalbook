# 青空文庫の整形

KCODE = 'u'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

doc = open("s-xml3.xml").read
doc = Nokogiri::HTML(doc)

# オプション設定
opt = Nokogiri::XML::Node::new('set', doc)
opt['parindent'] = 0.to_s # 行頭に全角スペースがあるので行頭インデント幅を0に
doc.at('/html').children[0].add_previous_sibling opt

# 不要な項目を削除
doc.search('h1').remove
doc.search('h2').remove
doc.search('title').remove

# タイトル設定
title = doc.css('meta[name="DC.Title"]')[0]
title.name = 'title'
title.content = title['content']

# 作者設定
author = doc.css('meta[name="DC.Creator"]')[0]
author.name = 'author'
author.content = author['content']

doc.search('h3').each{|node| node.content = "　　" + node.content}
doc.search('h4').each{|node| node.content = "　　　　　" + node.content}


open('s-xml33.xml', 'w').write doc.to_html






