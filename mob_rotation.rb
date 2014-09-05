require 'time'

file_name = ARGV[0]
command = ARGV[1]

lines = File.readlines(file_name).reject {|l| l.strip.empty? }

# start_time 
time = Time.now
last_rotation = File.mtime(file_name)
rotation_time = last_rotation + 120

def show_mobsters(lines)
  lines.each do |person|
    puts "Mobster #{person}"
  end
end

def rotate(lines, rotation_time, file_name)
  lines << lines.shift if rotation_time
  
  File.open(file_name, 'w') do |file|
    lines.each {|l| file << l }
  end
end

def time_to_rotate
  puts "Time to rotate!"
end

# time_to_rotate if time > rotation_time
rotate(lines, rotation_time, file_name) if command == "rotate"
show_mobsters(lines)
