require 'time'

class MobRotator
  def initialize(mob_file_name)
    @lines = File.readlines(mob_file_name).reject {|l| l.strip.empty? }
    @mob_file_name = mob_file_name
  end
  def show_mobsters()
    @lines.each do |person|
      puts "Mobster #{person}"
    end
  end
  
  def rotate(rotation_time)
    @lines << @lines.shift if rotation_time
    
    File.open(@mob_file_name, 'w') do |file|
      @lines.each {|l| file << l }
    end
  end
  
  def time_to_rotate
    puts "Time to rotate!"
  end
  
end
file_name = ARGV[0]
command = ARGV[1]

# start_time 
time = Time.now
last_rotation = File.mtime(file_name)
rotation_time = last_rotation + 120

mob_rotator = MobRotator.new(file_name)
# time_to_rotate if time > rotation_time
mob_rotator.rotate(rotation_time) if command == "rotate"
mob_rotator.show_mobsters()
