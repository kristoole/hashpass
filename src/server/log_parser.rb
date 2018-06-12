##
# Searches for a keyword in a log
# returns the value to the right of search_word
#
def read_log(search_word, selection_index, filename)
  p tail = `tail -n 24 logs/#{filename}`#.split(" ")
  return 'EMPTY' if tail.empty?
  return if tail.length < 13
  # word_index = tail.index(search_word) || 0
  # selection = word_index + selection_index
  # tail[selection]
  p line = tail.split("\n").grep(/#{search_word}/)[0]#.split('.. ')
  p line.to_s.split('.: ')[1]
end
