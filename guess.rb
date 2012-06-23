$:.push('.')
require 'semicolon-master'

app = SemicolonMaster.new

file = ARGV.first

dest = app.guess_semicolon(file)
open('output.pl', 'w'){ |f|
  f.write dest
}
puts "wrote to output.pl"

