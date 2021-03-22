s = "solid 12pt black 12em 0.4em red cyan;"

s = ' ' .. s .. ' '
pattern = '%s%d+%.?%d*%a+'

for text in string.gmatch(s, pattern) do
  print(text)
end
