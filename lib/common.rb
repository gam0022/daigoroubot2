def join_as_words(words)
  text = ""

  prev = ""
  words.each do |word|
    if prev =~ /[\w\d]+/ && word =~ /[\w\d]+/
      text += " " + word
    else
      text += word
    end
    prev = word
  end

  text
end
