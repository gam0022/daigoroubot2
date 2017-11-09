# coding: utf-8

ENV['MECAB_PATH'] = '/usr/lib/libmecab.so.2'
require 'natto'

#
# 直前の1単語によるマルコフ連鎖
#

class Summary

  def initialize()
    @data = []
    @mecab = Natto::MeCab.new
    @heads = []
  end

  def learn(text)
    # mecabで形態素解析して、 参照テーブルを作る
    ary = []
    @mecab.parse(text) do |n|
      ary << n.surface
    end

    @heads.push ({'head' => ary[0]})
    ary.each_cons(2) do |a| 
      @data.push h = {'head' => a[0], 'end' => a[1]}
    end
  end

  def talk()
    # マルコフ連鎖で要約
    head = @heads.sample
    t1 = head['head']
    new_text = t1
    while true
      _a = []
      @data.each do |hash|
        _a.push hash if hash['head'] == t1
      end 

      break if _a.size == 0
      num = rand(_a.size) # 乱数で次の文節を決定する
      new_text = new_text.eappend _a[num]['end']
      break if _a[num]['end'] == ""
      t1 = _a[num]['end']
    end

    new_text
  end

end


#
# 直前の2単語によるマルコフ連鎖
#

class Summary2

  def initialize()
    @data = []
    @mecab = Natto::MeCab.new
    @heads = []
  end

  def learn(text)
    # mecabで形態素解析して、 参照テーブルを作る
    ary = []
    @mecab.parse(text) do |n|
      ary << n.surface
      puts "#{n.surface}\t#{n.feature}"
    end

    @heads.push ({'head' => ary[0], 'middle' => ary[1]})
    ary.each_cons(3) do |a| 
      @data.push h = {'head' => a[0], 'middle' => a[1], 'end' => a[2]}
    end
  end

  def talk()
    # マルコフ連鎖で要約
    head = @heads.sample
    t1 = head['head']
    t2 = head['middle']
    new_text = t1.eappend t2  
    while true
      choices = []
      @data.each do |node|
        choices.push node if node['head'] == t1 && node['middle'] == t2
      end 

      break if choices.size == 0
      selection = choices.sample
      new_text = new_text.eappend selection['end']
      break if selection['end'] == ""
      t1 = selection['middle']
      t2 = selection['end']
    end

    new_text
  end

end


class String

  #
  # テキストから余分な文字を取り除く
  #
  def filter
    # エンコードをUTF-8 にして、改行とURLや#ハッシュダグや@メンションは消す
    self.gsub(/(\n|https?:\S+|from https?:\S+|#)/, "").gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').strip
  end

  #
  # 英単語の場合、スペースをはさんで結合
  #
  def eappend(text)
    a = self.scrub("")
    b = text.scrub("")
    (b =~ /^\w+$/ && !a.empty?) ? "#{a} #{b}" : a + b
  end

end
