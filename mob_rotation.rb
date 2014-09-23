require 'time'

class MobRotator
  def initialize(mob_file_name)
    FileUtils.touch(mob_file_name) unless File.exist?(mob_file_name)
    @lines = File.readlines(mob_file_name).reject {|l| l.strip.empty? }
    @mob_file_name = mob_file_name
  end

  def write(text)
    puts text
  end

  def show_mobsters()
    @lines.each_with_index do |person, index|
      case index
      when 0
        write "Driver #{person}"
      when 1
        write "Navigator #{person}"
      else
        write "Mobster #{person}"
      end
    end
  end

  def add_mobster(*mobsters)
    File.open(@mob_file_name, 'a') do |file|
      mobsters.each do |mobster|
        file << mobster+"\n"
      end
    end
    mobsters.each do |mobster|
      @lines << mobster
    end
  end
 
  def remove_mobster(*mobsters)
    File.open(@mob_file_name, 'w') do |file|
      mobsters.each do |mobster|
        @lines.each_with_index do |l, i| 
          file << l unless l && l.strip == mobster
          @lines[i] = nil if l &&  l.strip == mobster
        end
      end
    end
    @lines.compact!
  end

  def rotate
    @lines << @lines.shift
    
    File.open(@mob_file_name, 'w') do |file|
      @lines.each {|l| file << l }
    end
  end

  
  def time_to_rotate
    puts "Time to rotate!"
  end
  
end

class Timer
 def self.timer(arg)
   arg
 end
end
