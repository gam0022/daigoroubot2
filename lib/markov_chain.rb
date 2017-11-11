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

  # URLや特殊記号(#,@)を取り除く
  # パーセントエンコーディングをデコードする
  def filter(text)
    text.gsub(/(\n|https?:\S+|from https?:\S+|#|@)/, "").
      gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
  end

  # 文章を学習する
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
  
  # 文章を生成する
  def talk()
    prefix = @heads.sample
    words = prefix[0...@n]

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
