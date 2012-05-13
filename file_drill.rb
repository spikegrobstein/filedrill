require 'term/ansicolor'
include Term::ANSIColor

class FileDrill
  
  attr_accessor :files
  
  def initialize(*file_paths)
    @files = []
    
    file_paths.each { |file_path| @files << File.new(file_path) }
  end
  
  def rewind_files
    @files.each { |file| file.rewind }
  end
  
  def getc
    @files.collect { |f| f.getc }
  end
  
  def delta(file)
    file.rewind
    len = file.stat.size
    
    hex_buf = ''
    ascii_buf = ''
    
    data = file.readbytes(len)
    
    
    
    len.times do |i|
      c = file.getc
      
      if i > 0 and i % 16 == 0
        puts "#{hex_buf} | #{ascii_buf}"
        hex_buf = ''
        ascii_buf = ''
      end
      
      hex_buf << "%02x " % c
      ascii_buf << ((32..126).include?(c) ? c.chr : '.')
    end
    
    if (hex_buf.length)
      print hex_buf
      print ' ' * (16 * 3 - (len % 16) * 3)
      puts " | #{ascii_buf}"
    end
  end
  
  def compare(&block)
    rewind_files
    len = @files.collect { |f| f.stat.size }.min
        
    hex_buf = ''
    ascii_buf = ''
    
    len.times do |i|
      (a, b) = @files.collect { |f| f.getc }
      
      unless block.nil?
        a = block.call(a)
        b = block.call(b)
      end
      
      if i > 0 and i % 16 == 0
        puts "#{hex_buf} | #{ascii_buf}"
        hex_buf = ''
        ascii_buf = ''
      end
      
      if a < b
        hex_buf << "#{green}%02x #{reset}" % a
        ascii_buf << "#{green}#{(32..126).include?(a) ? a.chr : '.'}#{reset}"
      elsif a > b
        hex_buf << "#{red}%02x #{reset}" % a
        ascii_buf << "#{red}#{(32..126).include?(a) ? a.chr : '.'}#{reset}"
      else
        hex_buf << "%02x " % a
        ascii_buf << ((32..126).include?(a) ? a.chr : '.')
      end
    end
    
    if (hex_buf.length)
      print hex_buf
      print ' ' * (16 * 3 - (len % 16) * 3)
      puts " | #{ascii_buf}"
    end
  end
end