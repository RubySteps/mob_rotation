require "fileutils"
require "timeout"
require "mob_rotation"

describe "mob_rotation command line tool" do
  let(:temp_rotation_db) { "/tmp/rotation_test.txt" }

  before do
    `rm -rf ./tmp/test_project`
    `mkdir -p ./tmp/test_project`
    `git init ./tmp/test_project`
  end

  def remove_temp_rotation_db
    FileUtils.rm(temp_rotation_db) if File.exist?(temp_rotation_db)
  end

  def add_name_and_email_to_temp_db(name, email = nil)
    s = email ? " <#{email}>" : ""
    `echo "#{name} #{s}" >> #{temp_rotation_db}`
  end

  before do
    remove_temp_rotation_db

    add_name_and_email_to_temp_db("Bob")
    add_name_and_email_to_temp_db("Phoebe")
  end

  def run_rotate(command = nil, env = nil)
    run_rotate_with_specified_redirect(command, env, "> /tmp/results.txt")
  end

  def run_rotate_with_specified_redirect(command = nil, env = nil, redirect = nil)
    # TODO: we have no idea why this is necessary, and don't like it
    @our_output = nil

    `MOB_GIT_DIR='./tmp/test_project/.git' DB_FILE='#{temp_rotation_db}' #{env} #{RbConfig.ruby} #{File.join(Dir.pwd, "bin/mob_rotation")}  #{command} #{redirect}`
  end

  def our_output
    @our_output ||= File.readlines("/tmp/results.txt").collect(&:strip)
      .reject(&:empty?)
  end

  context "command: ruby mob_rotation" do
    it "defaults to 'rotate.txt' when no database file is specified" do
      if backup = File.exist?("./rotate.txt")
        FileUtils.mv("./rotate.txt", "./rotate.txt.backup")
      end
      FileUtils.cp(temp_rotation_db, "./rotate.txt")
      `#{RbConfig.ruby} #{File.join(Dir.pwd, "bin/mob_rotation")} > /tmp/results.txt`
      begin
        expect(our_output).to include("Driver Bob", "Navigator Phoebe")
      ensure
        FileUtils.mv("./rotate.txt.backup", "./rotate.txt") if backup
      end
    end

    it "prints out the rotation order" do
      run_rotate
      expect(our_output).to include("Driver Bob", "Navigator Phoebe")
    end

    it "prints out rotation order in colors if COLOR=true" do
      run_rotate "show", "COLOR=true"
      expect(our_output).to include("\e[0;32;49mDriver Bob\e[0m", "\e[0;34;49mNavigator Phoebe\e[0m")
    end

    it "prints out rotation order as tableised view" do
      add_name_and_email_to_temp_db("Joe")
      run_rotate "show", "TABLE=true"
      expect(our_output).to include("Driver    Bob",
                                    "Navigator Phoebe",
                                    "Mobster   Joe")
    end
  end

  context "command: ruby mob_rotation help" do
    it "prints out help" do
      run_rotate("help")
      expected = ["Available commands are:",
                  "show",
                  "help",
                  "rotate",
                  "random",
                  "add <name1> [name2]",
                  "remove <name1> [name2]",
                  "run_with_timer [seconds]"
                 ]

      expect(our_output).to eq(expected)
    end
  end

  context "command: ruby mob_rotation arbitrary" do
    it "prints out help on an unknown command" do
      run_rotate("arbitrary")
      expected = ["Unknown command arbitrary",
                  "Available commands are:"
                 ]

      expect(our_output).to include(*expected)
    end
  end

  context "command: ruby mob_rotation random" do
    it "Identifies list as randomized" do
      run_rotate("random 1")

      expect(our_output).to include("Randomized Output")
      expect(our_output).to include("Driver Bob", "Navigator Phoebe")
    end

    it "produces a different order with a different seed" do
      run_rotate("random 0")

      expect(our_output).to include("Driver Phoebe", "Navigator Bob")
    end

    it "saves the rotation order" do
      run_rotate("random 0")
      run_rotate

      expect(our_output).to include("Driver Phoebe", "Navigator Bob")
    end

    it "updates the git username" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db("Bob Example", "bob@example.com")
      add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")

      run_rotate("random 0")

      git_username = `git --git-dir=./tmp/test_project/.git config user.name`
        .strip
      expect(git_username).to eq("Phoebe Example")
    end
  end

  context "command: ruby mob_rotation rotate" do
    it "changes the order of rotation" do
      run_rotate("rotate")
      expect(our_output).to include("Driver Phoebe", "Navigator Bob")
    end

    describe "git stuff" do
      it "includes the email addresses in rotation output" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")
        add_name_and_email_to_temp_db("Bob Example", "bob@example.com")
        add_name_and_email_to_temp_db("Joe Example", "joe@example.com")
        run_rotate("rotate")

        expect(our_output).to include(
          "Driver Bob Example <bob@example.com>",
          "Navigator Joe Example <joe@example.com>",
          "Mobster Phoebe Example <phoebe@example.com>"
        )
      end

      it "outputs the new git username when running rotate" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example")

        run_rotate("rotate")

        expect(our_output).to include(
          "git username: Phoebe Example",
          "Driver Phoebe Example"
        )
      end

      it "outputs the new git email when running rotate" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")

        run_rotate "rotate"

        expect(our_output).to include("git user email: phoebe@example.com")

        add_name_and_email_to_temp_db(
          "David Example",
          "david-example@example.com"
        )

        run_rotate("rotate")

        expect(our_output).to include(
          "git user email: david-example@example.com"
        )
      end

      it "outputs the new git email when rotating a list of multiple users" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")
        add_name_and_email_to_temp_db("David Example", "david@example.com")

        run_rotate("rotate")

        expect(our_output).to include("git user email: david@example.com")
      end

      it "updates the git user.name config when running rotate" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")

        run_rotate("rotate")

        git_username = `git --git-dir=./tmp/test_project/.git config user.name`
          .strip
        expect(git_username).to eq("Phoebe Example")
      end

      it "updates the git user.email config when running rotate" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")

        run_rotate("rotate")

        git_email = `git --git-dir=./tmp/test_project/.git config user.email`
          .strip
        expect(git_email).to eq("phoebe@example.com")
      end

      it "updates the email in the mobsters database when rotating" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")
        add_name_and_email_to_temp_db("Bob Example" "bob@example.com")
        add_name_and_email_to_temp_db("Joe Example", "joe@example.com")

        run_rotate("rotate")
        run_rotate("rotate")

        git_email = `git --git-dir=./tmp/test_project/.git config user.email`
          .strip
        expect(git_email).to eq("joe@example.com")
      end

      it "falls back to a default email address when the driver has none" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")
        add_name_and_email_to_temp_db("Bob Example")

        run_rotate("rotate")

        git_email = `git --git-dir=./tmp/test_project/.git config user.email`
          .strip
        expect(git_email).to eq("mob@rubysteps.com")
      end

      it "updates the email in the mobsters database when rotating, even when someone's missing an email address" do
        remove_temp_rotation_db
        add_name_and_email_to_temp_db("Phoebe Example", "phoebe@example.com")
        add_name_and_email_to_temp_db("Bob Example")
        add_name_and_email_to_temp_db("Joe Example", "joe@example.com")

        run_rotate("rotate")
        run_rotate("rotate")

        git_email = `git --git-dir=./tmp/test_project/.git config user.email`
          .strip
        expect(git_email).to eq("joe@example.com")
      end
    end
  end

  context "command: ruby mob_rotation add one_name [two three]" do
    it "adds one mobster to the mob list" do
      run_rotate("add Joe")
      expect(our_output).to include(
        "Driver Bob",
        "Navigator Phoebe",
        "Mobster Joe"
      )
    end

    it "adds multiple mobsters at once" do
      run_rotate("add Phil Steve")
      expect(our_output).to include("Mobster Phil", "Mobster Steve")
    end

    it "new name cannot match existing name" do
      run_rotate("add Ralph")
      run_rotate("add Ralph")

      expect(our_output).to include("user name 'Ralph' already exists")
      expect(our_output.select { |l| l.include?("Ralph") }.size).to eq(2)
    end
  end

  context "command: ruby mob_rotation remove one_name [two three]" do
    it "removes one mobster from the mob list" do
      run_rotate("remove Bob")
      expect(our_output).to include("Driver Phoebe")
    end

    it "removes multiple mobsters at once" do
      # TODO: Doesn't test what it claims to test.
      run_rotate("add Phil")
      run_rotate("remove Bob Phoebe")
      expect(our_output).to include("Driver Phil")
    end
  end

  context "command: ruby mob_rotation run_with_timer N" do
    it "it runs for a specific amount of time" do
      ts = Time.now
      run_rotate("run_with_timer 3")
      tf = Time.now
      threshold = 3.0 + MobRotation::Rotation.minimum_sleep_between_beeps * MobRotation::Rotation.number_of_beeps
      expect(tf - ts).to be_within(1).of(threshold)
      expect(our_output).to include("Time to rotate")
    end

    it "waits until time runs out before stating 'Time to Rotate'" do
      expect {
        Timeout.timeout(1) { run_rotate("run_with_timer 5") }
      }.to raise_error(Timeout::Error)
      expect(our_output).to eq([])
    end

    it "notifies with a beep" do
      stdout_output = run_rotate_with_specified_redirect("run_with_timer")
      expect(stdout_output).to include("\a")
    end

    it "runs for a specified amount of time and then notifies with a beep" do
      ts = Time.now
      stdout_output = run_rotate_with_specified_redirect("run_with_timer 2")
      tf = Time.now
      expect(tf - ts).to be_within(1).of(2.0 + MobRotation::Rotation.minimum_sleep_between_beeps * MobRotation::Rotation.number_of_beeps)
      expect(stdout_output).to include("Time to rotate")
      expect(stdout_output).to include("\a")
    end
  end
end
