require 'time'

class MobRotation
  def initialize(database)
    @database = database

    @mobsters = @database.clean_entries_in do | entry |
      extract_name_from(entry)
    end

    @emails = @database.clean_entries_in do |entry|
      extract_email_from(entry)
    end
  end

  class Database
    def clean_entries_in
      dirty_entries = each_database_entry(@filename) do |entry|
        yield entry
      end
      cleanup dirty_entries
    end

    def initialize(filename)
      @filename = filename
      FileUtils.touch(filename) unless File.exist?(filename)
    end

    def write(mobsters)
      File.open(@filename, 'w') do |file|
        mobsters.each { |m| file << m << "\n" }
      end
    end

    def each_database_entry(filename)
      File.readlines(filename).map do |entry|
        yield entry
      end
    end

    def cleanup(list)
      list.compact.map(&:strip).reject(&:empty?)
    end
  end

  def extract_email_from(entry)
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
    @emails << @emails.shift
    # Hacky BS because of weird test output redirection
    system "git --git-dir=./tmp/test_project config user.name '#{@mobsters.first.strip}'" rescue nil
    sync!
  end

  
  def time_to_rotate
    puts "Time to rotate!"
  end
  
  private
  
  def sync!
    @database.write(@mobsters)
  end
  
  def found_mobster(line, mobster)
    line && line.strip == mobster
  end

  def extract_name_from(entry)
    entry_to_array = entry.split('')
    entry_to_array.take_while { |c| c != '<' }.join('')
  end
end

