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
    @mecab.parse(text + " EOS") do |n|
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
      break if _a[num]['end'] == "EOS"
      t1 = _a[num]['end']
    end

    # EOSを削除して、結果出力
    new_text.gsub!(/EOS$/,'')
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
    @mecab.parse(text + " EOS") do |n|
      ary << n.surface
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
      _a = []
      @data.each do |hash|
        _a.push hash if hash['head'] == t1 && hash['middle'] == t2
      end 

      break if _a.size == 0
      num = rand(_a.size) # 乱数で次の文節を決定する
      new_text = new_text.eappend _a[num]['end']
      break if _a[num]['end'] == "EOS"
      t1 = _a[num]['middle']
      t2 = _a[num]['end']
    end

    # EOSを削除して、結果出力
    new_text.gsub!(/EOS$/,'')
  end

end


class String

  #
  # テキストから余分な文字を取り除く
  #
  def filter
    # エンコードをUTF-8 にして、改行とURLや#ハッシュダグや@メンションは消す
    self.gsub(/(\n|https?:\S+|from https?:\S+|#\w+|#|@\S+|^RT)/, "").gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').strip
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
