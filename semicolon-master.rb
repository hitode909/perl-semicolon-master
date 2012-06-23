# -*- coding: utf-8 -*-
require 'mongo'
require 'shellwords'

class SemicolonMaster
  def initialize
    @tupples = []
  end

  def db
    @db
  end

  def learn_file(file)
    source = open(file).read

    tupples = source.scan(/([^;])(;)?\n\s*(\S)/).map{ |newline|
      (last_char, semicolon, first_char) = *newline
      SemicolonMaster::Tupple.new.tap {|tupple|
        tupple.last_char = last_char
        tupple.first_char = first_char
        tupple.has_semicolon = !! semicolon
      }
    }

    SemicolonMaster::Database.save(tupples)
  end

  def guess_semicolon(file)
    lines = make_lines(file)
    compile!(lines)
    lines_to_s(lines)
  end

  def make_lines(file)
    source = open(file).read

    lines = source.split(/\n/).select{ |line| line.length > 0 }.map{ |line|
      SemicolonMaster::Line.new(line)
    }

    lines.inject(){ |last_line, line|
      last_line.introduce_next_line(line)
      line
    }
    lines.last.notify_last_line
    lines
  end

  # コンパイルできるまでセミコロンつけたり外したりする
  def compile!(lines)
    count = 0
    max = 2**lines.length
    lines_index = lines.sort{ |a, b|
      (a.rate - 0.5).abs <=> (b.rate - 0.5).abs
    }
    loop {
      lines_index.each_with_index.map{|line, num|
        line.flip_count = count[num] == 1 ? 1 : 0
      }
      warn "#{count} / #{max}"
      if can_compile(lines)
        warn "success at #{count} times"
        return
      end
      raise 'failed' if count > max
      count+= 1
    }
  end

  def can_compile(lines)
    source = lines_to_s(lines)
    open('/tmp/semicolon-master.pl', 'w'){ |f|
      f.write source
    }
    system("perl -wc /tmp/semicolon-master.pl")
    $? == 0
  end

  def lines_to_s(lines)
    lines.map{ |line| line.to_source }.join("\n")
  end
end

class SemicolonMaster::Line
  attr_accessor :line, :rate, :flip_count, :char
  def initialize(line)
    @line = line

    @rate = 0.5
    @flip_count = 0
    @char = ';'
  end

  def char
    chars = @rate >= 0.5 ? [';', ''] : ['', ';']

    chars[@flip_count % 2]
  end

  def flip!
    @flip_count += 1
  end

  def to_source
    @line + char
  end

  def first
    @line.strip[0]
  end

  def last
    @line.strip[-1]
  end

  # 次の行から，この行にセミコロンがある確率を計算
  def introduce_next_line(next_line)
    @rate = SemicolonMaster::Database.semicolon_rate(self.last, next_line.first)
  end

  # 最後の行です
  def notify_last_line
    @rate = 1.0
  end
end


class SemicolonMaster::Database

  # save array of tupple
  def self.save(tupples)

    tupples.each{ |tupple|
      collection.update(
        { :pair => tupple.key },
        { :$inc => { tupple.value => 1}},
        { :upsert => true}
      )
    }
  end

  # 0 ~ 1
  def self.semicolon_rate(a, b)
    return 0.5 if a.nil? or b.nil?
    guess = self.collection.find_one({
        :pair => a + b
      })

    if guess
      yes = guess['true'] || 0
      no = guess['false'] || 0
      yes.to_f / (yes + no)
    else
      0.5
    end
  end

  private

  def self.collection
    self.database.collection('tupple')
  end
  def self.database
    @@collection ||= Mongo::Connection.new('localhost', 27017).db("perl-semicolon-master")
  end
end

class SemicolonMaster::Tupple
  attr_accessor :last_char, :first_char, :has_semicolon

  def key
    @last_char + @first_char
  end

  def value
    @has_semicolon ? :true : :false
  end
end
