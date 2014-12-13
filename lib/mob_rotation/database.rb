require "fileutils"

module MobRotation
  class Database
    def sanitized_entries_in
      each_database_entry(@filename) do |entry|
        yield(entry.to_s.strip)
      end
    end

    def initialize(filename)
      @filename = filename
      FileUtils.touch(filename) unless File.exist?(filename)
    end

    def write(mobsters)
      File.open(@filename, "w") do |file|
        mobsters.each do |mobster|
          file << format_mobster(mobster.name, mobster.email) << "\n"
        end
      end
    end

    def format_mobster(name, email)
      name + (" <#{email}>" if email && !email.empty?).to_s
    end

    def each_database_entry(filename)
      File.readlines(filename).collect { |entry| yield(entry) }
    end
  end
end
