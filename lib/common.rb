# coding: utf-8

# 単語配列を連結する。英数字同士はスペースで連結する
def join_as_words(words)
  text = ""

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
