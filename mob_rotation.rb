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
  end
  
  def remove_mobster(mobster)
    File.open(@mob_file_name, 'w') do |file|
      @lines.each {|l| file << l unless l.strip == mobster }
    end
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

file_name = ARGV[0]
command = ARGV[1]

# start_time 
#time = Time.now
#last_rotation = File.mtime(file_name)
#rotation_time = last_rotation + 120

mob_rotator = MobRotator.new(file_name)
# time_to_rotate if time > rotation_time
mob_rotator.rotate if command == "rotate"
mob_rotator.show_mobsters()
