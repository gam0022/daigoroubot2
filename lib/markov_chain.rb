# coding: utf-8

ENV['MECAB_PATH'] = '/usr/lib/libmecab.so.2'
require 'natto'

require_relative 'common'

class MarkovChain
  def initialize(n)
    @n = n
    @mecab = Natto::MeCab.new
    @heads = []
    @chains = []
  end

  # テキストから余分な文字を取り除く
  def filter(text)
    # エンコードをUTF-8 にして、改行とURLや#ハッシュダグや@メンションは消す
    text.gsub(/(\n|https?:\S+|from https?:\S+|#)/, "").gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>').strip
  end
  
  def learn(text)
    text = filter(text)

    words = []
    @mecab.parse(text) do |node|
      puts "#{node.surface}\t#{node.feature}"
      words << node.surface
    end

    @heads << words[0...@n]

    words.each_cons(@n + 1) do |chain| 
      @chains << chain
    end
  end
  
  def talk()
    head = @heads.sample
    prefix = head

    words = []
    (0...@n).each do |i|
      words << prefix[i]
    end

    while true
      choices = @chains.select {|chain| prefix == chain[0...@n]}
      break if choices.size == 0

      selection = choices.sample
      break if selection[@n] == ""

      words << selection[@n]
      prefix = selection[1..@n]
    end

    join_as_words(words)
  end
end
