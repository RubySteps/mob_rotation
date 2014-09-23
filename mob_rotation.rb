require 'time'

class MobRotator
  def initialize(mob_file_name)
    FileUtils.touch(mob_file_name) unless File.exist?(mob_file_name)
    @mobsters = File.readlines(mob_file_name).reject {|l| l.strip.empty? }
    @mob_file_name = mob_file_name
  end

  def write(text)
    puts text
  end

  def show_mobsters()
    @mobsters.each_with_index do |person, index|
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
      @mobsters << mobster
    end
  end

  def remove_mobster(mobster)
    File.open(@mob_file_name, 'w') do |file|
      @mobsters.each_with_index do |l, i|
        file << l unless valid_mobster(l, mobster)
        @mobsters[i] = nil if valid_mobster(l, mobster)
      end
    end
    @mobsters.compact!
  end
  
  def remove_mobsters(*mobsters)
    mobsters.each do |mobster|
      remove_mobster(mobster)
    end
  end

  def rotate
    @mobsters << @mobsters.shift
    
    File.open(@mob_file_name, 'w') do |file|
      @mobsters.each {|l| file << l }
    end
  end

  
  def time_to_rotate
    puts "Time to rotate!"
  end
  
  private
  
  def valid_mobster(line, mobster)
    line && line.strip == mobster
  end
end

class Timer
 def self.timer(arg)
   arg
 end
end
