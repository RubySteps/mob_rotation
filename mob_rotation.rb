require 'time'

class MobRotation
  def initialize(mob_file_name)
    FileUtils.touch(mob_file_name) unless File.exist?(mob_file_name)
    @mobsters = File.readlines(mob_file_name).map do |entry|
      extract_name_from(entry)
    end.map(&:strip).reject(&:empty?)

    @emails = File.readlines(mob_file_name).map do |entry|
      MobRotation.extract_email_from(entry)
    end.compact.map(&:strip).reject(&:empty?)

    @mob_file_name = mob_file_name
  end

  def self.extract_email_from(entry)
    if entry =~ /\<(.*)\>/
      $1
    end
  end

  def write(text)
    puts text
  end

  def show_mobsters()
    @mobsters.each_with_index do |person, index|
      case index
      when 0
        write "git username: #{person}"
        write "git user email: #{@emails[index]}"
        write "Driver #{person}"
      when 1
        write "Navigator #{person}"
      else
        write "Mobster #{person}"
      end
    end
  end

  def add_mobster(*mobsters)
    mobsters.each do |mobster|
      @mobsters << mobster
    end

    sync!
  end

  def remove_mobster(given_mobster)
    @mobsters.each do |mobster|
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

  def run_timer(seconds)
    sleep(seconds)
    puts "Time to rotate"
  end

  def inform_lovely_user(command)
    puts "Unknown command #{command}"
    show_help
  end

  def rotate
    @mobsters << @mobsters.shift
    system "git config user.name '#{@mobsters.first.strip}'" rescue nil
    sync!
  end

  
  def time_to_rotate
    puts "Time to rotate!"
  end
  
  private
  
  def sync!
    File.open(@mob_file_name, 'w') do |file|
      @mobsters.each { |m| file << m << "\n" }
    end
  end
  
  def found_mobster(line, mobster)
    line && line.strip == mobster
  end

  def extract_name_from(entry)
    entry_to_array = entry.split('')
    entry_to_array.take_while { |c| c != '<' }.join('')
  end
end

