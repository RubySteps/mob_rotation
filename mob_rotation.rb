require 'time'
require_relative 'mobster'
require_relative 'database'

class MobRotation
  def initialize(database, git_dir)
    @git_dir = git_dir
    @database = database
    @real_mobsters = []

    @mobsters = @database.sanitized_entries_in do | entry |
      mobster = build_mobster entry
      @real_mobsters << mobster
      mobster.to_s
    end

    @emails = @database.sanitized_entries_in do |entry|
      extract_email_from(entry)
    end
  end

  def build_mobster(entry)
    name = extract_name_from(entry)
    email = extract_email_from(entry)
    Mobster.new(name, email)
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
        write "git username: #{person.to_s}"
        write "git user email: #{@emails[index]}"
        format_mobster("Driver", person.to_s, @emails[index])
      when 1
        format_mobster("Navigator", person.to_s, @emails[index])
      else
        format_mobster("Mobster", person.to_s, @emails[index])
      end
    end
  end

  def format_mobster(role, person, email)
    if email.to_s.empty?
      write "#{role} #{person.to_s}"
    else
      write "#{role} #{person.to_s.strip} <#{email.strip}>"
    end
  end

  def add_mobster(*mobsters)
    mobsters.map(&:to_s).map(&:strip).each do |mobster|
      raise if mobster.empty?

      if @mobsters.include?(mobster)
        write "user name '#{mobster}' already exists"
        next
      end

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
    '<database txt file> remove <name1> [name2]',
    '<database txt file> run_with_timer [seconds]'
    ]
  end

  def self.annoying_and_probably_not_accidental_beep(n=MobRotation.number_of_beeps)
    n.times { print("\a") || sleep(MobRotation.minimum_sleep_between_beeps) }
  end

  def countdown_to_rotate(seconds=300)
    sleep(seconds)
    puts "Time to rotate"
    MobRotation.annoying_and_probably_not_accidental_beep
  end

  def inform_lovely_user(command)
    puts "Unknown command #{command}"
    show_help
  end

  def rotate
    @mobsters << @mobsters.shift
    @emails << @emails.shift
    # Hacky BS because of weird test output redirection
    system "git --git-dir=#{@git_dir} config user.name '#{@mobsters.first.to_s.strip}'" rescue nil
    system "git --git-dir=#{@git_dir} config user.email '#{extract_next_mobster_email}'" rescue nil
    sync!
  end

  def extract_next_mobster_email
    email = @emails.first.strip
    email.empty? ? "mob@rubysteps.com" : email
  end

  def time_to_rotate
    puts "Time to rotate!"
  end

  def self.minimum_sleep_between_beeps
    0.2
  end

  def self.number_of_beeps
    5
  end

  private

  def sync!
    @database.write(@mobsters, @emails)
  end

  def found_mobster(line, mobster)
    line.to_s.strip == mobster.to_s
  end

  def extract_name_from(entry)
    entry_to_array = entry.split('')
    entry_to_array.take_while { |c| c != '<' }.join('')
  end
end

