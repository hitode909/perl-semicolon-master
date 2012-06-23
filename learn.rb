$:.push('.')
require 'semicolon-master'

app = SemicolonMaster.new

ARGV.each{ |dir|
  Dir.chdir(File.expand_path(dir))
  Dir.glob('**/**.pm').each{ |file|
    begin
      warn file
      app.learn_file(file)
    rescue => error
      warn file
      warn error
    end
  }
}
