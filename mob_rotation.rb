require 'time'

class MobRotator
  def initialize(mob_file_name)
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

  def add_mobster(mobster)
    File.open(@mob_file_name, 'a') do |file|
      file << mobster
    end
    @lines << mobster 
  end
 
  def remove_mobster(mobster)
    File.open(@mob_file_name, 'w') do |file|
      @lines.each_with_index do |l, i| 
        file << l unless l.strip == mobster
       @lines[i] = nil if l.strip == mobster
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
