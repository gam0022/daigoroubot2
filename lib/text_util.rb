# coding: utf-8

# 単語配列を連結する。英数字同士はスペースで連結する
def join_as_words(words)
  text = words[0]

  words.each_cons(2) do |prev_cur|
    prev, cur = prev_cur

    if prev =~ /[\w\d]+/ && cur =~ /[\w\d]+/
      text += " " + cur
    else
      text += cur
    end
  end

  text
end

# URLや特殊記号(#,@)を取り除く
# パーセントエンコーディングをデコードする
def filter(text)
  text.gsub(/(\n|https?:\S+|from https?:\S+|#|＃|@|＠)/, "").
    gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
end
