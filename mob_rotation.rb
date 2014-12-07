require 'time'
require_relative 'mobster'
require_relative 'database'

class MobRotation
  def initialize(database, git_dir)
    @git_dir = git_dir
    @database = database

    @real_mobsters = @database.sanitized_entries_in do | entry |
      mobster = build_mobster entry
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

  def command_router(command, mobster_names)
    command_mappings = {
      nil => lambda { |command, *mobster_names|
        show_mobsters
      },
      "rotate" => lambda { |command, *mobster_names|
        rotate
        show_mobsters
      },
      "random" => lambda { |command, *mobster_names|
        random(ARGV[2])
        show_mobsters
      },
      "add" => lambda { |command, *mobster_names|
        add_mobster(*mobster_names)
        show_mobsters
      },
      "remove" => lambda { |command, *mobster_names|
        remove_mobsters(*mobster_names)
        show_mobsters
      },
      "help" => lambda { |command, *mobster_names|
        show_help
      },
      "run_with_timer" => lambda { |command, *mobster_names|
        countdown_to_rotate(ARGV[2].to_i)
      }
    }

    command_mappings.fetch(command) {
      lambda { |command, *mobster_names|
        inform_lovely_user(command)
      }
    }.call(command, *mobster_names)
  end

  def show_mobsters()
    @real_mobsters.each_with_index do |person, index|
      case index
      when 0
        write "git username: #{person.name}"
        write "git user email: #{person.email}"
        format_mobster("Driver", person)
      when 1
        format_mobster("Navigator", person)
      else
        format_mobster("Mobster", person)
      end
    end
  end

  def format_mobster(role, person)
    if person.email.to_s.empty?
      write "#{role} #{person.name}"
    else
      write "#{role} #{person.name.strip} <#{person.email.strip}>"
    end
  end

  def add_mobster(*mobsters_to_add)
    mobsters_to_add.map(&:to_s).map(&:strip).each do |mobster_to_add|
      raise if mobster_to_add.empty?

      if @real_mobsters.map(&:name).include?(mobster_to_add)
        write "user name '#{mobster_to_add}' already exists"
        next
      end

      @real_mobsters << Mobster.new(mobster_to_add)
    end

    sync
  end

  def remove_mobster(given_mobster)
    @real_mobsters.each_with_index do |mobster, i|
      if found_mobster(mobster, given_mobster)
        @real_mobsters.delete_at(i)
      end
    end
    sync
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

  def rotate_mobsters(&rotation_algorithm)
    rotation_algorithm.call

    git_config_update
    sync
  end

  def rotate
    puts ""

    rotate_mobsters do
      @real_mobsters << @real_mobsters.shift
    end
  end

  def random(seed=nil)
    puts "Randomized Output"

    rotate_mobsters do
      srand(seed.to_i) if seed
      @real_mobsters.shuffle!
    end
  end

  def extract_next_mobster_email
    email = @real_mobsters.first.email.to_s.strip
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

  def git_config_update
    #FIX yo that rescue nil is bogus
    system "git --git-dir=#{@git_dir} config user.name '#{@real_mobsters.first.name}'" rescue nil
    system "git --git-dir=#{@git_dir} config user.email '#{extract_next_mobster_email}'" rescue nil
  end

  def sync
    @database.write(@real_mobsters)
  end

  def found_mobster(line, mobster)
    line.to_s.strip == mobster.to_s
  end

  def extract_name_from(entry)
    entry_to_array = entry.split('')
    entry_to_array.take_while { |c| c != '<' }.join('')
  end
end

