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

  def remove_mobster(given_mobster)
    @mobsters.each_with_index do |mobster, i|
      @mobsters.delete(mobster) if found_mobster(mobster, given_mobster) 
    end
    sync!
  end
  
  def remove_mobsters(*mobsters)
    mobsters.each do |mobster|
      remove_mobster(mobster)
    end
  end

  def show_help()
    puts ['Available commands are:',
    '<database txt file> help',
    '<database txt file> rotate', 
    '<database txt file> add <name1> [name2]',
    '<database txt file> remove <name1> [name2]']
  end

  def inform_lovely_user(command)
    puts "Unknown command #{command}"
    show_help
  end

  def rotate
    @mobsters << @mobsters.shift
    sync!
  end

  
  def time_to_rotate
    puts "Time to rotate!"
  end
  
  private
  
  def sync!
    File.open(@mob_file_name, 'w') do |file|
      @mobsters.each { |m| file << m}
    end
  end

  
  def found_mobster(line, mobster)
    line && line.strip == mobster
  end
end

class Timer
 def self.timer(arg)
   arg
 end
end
