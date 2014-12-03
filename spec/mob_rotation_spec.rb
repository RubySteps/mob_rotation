require_relative '../mob_rotation'
require "fileutils"

describe do
  let(:temp_rotation_db) { '/tmp/rotation_test.txt' }

  before do
    `mkdir -p ./tmp/test_project`
    `git init ./tmp/test_project`
  end

  def remove_temp_rotation_db
    FileUtils.rm(temp_rotation_db) if File.exist?(temp_rotation_db)
  end

  def add_name_and_email_to_temp_db(name, email=nil)
    s = email ? " <#{email}>" : ""
    `echo "#{name} #{s}" >> #{temp_rotation_db}`
  end

  before do
    remove_temp_rotation_db

    add_name_and_email_to_temp_db 'Bob'
    add_name_and_email_to_temp_db 'Phoebe'
  end

  def run_rotate(command = nil)
    run_rotate_with_specified_redirect(command, '> /tmp/results.txt')
  end

  def run_rotate_with_specified_redirect(command = nil, redirect = nil)
    # TODO we have no idea why this is necessary, and don't like it
    @output = nil

    `MOB_GIT_DIR='./tmp/test_project/.git' ruby /home/rubysteps/mob_rotation/mob_rotation #{temp_rotation_db} #{command} #{redirect}`
  end

  def output
    @output ||= File.readlines('/tmp/results.txt').map(&:strip).reject(&:empty?)
  end

  it "allows the database file to be specified"

  it "defaults to 'rotate.txt' when no database file is specified" do
    if backup = File.exists?('./rotate.txt')
      FileUtils.mv('./rotate.txt', './rotate.txt.backup')
    end
    FileUtils.cp(temp_rotation_db, './rotate.txt')
    `ruby /home/rubysteps/mob_rotation/mob_rotation > /tmp/results.txt`
    begin
      expect(output).to include("Driver Bob","Navigator Phoebe")
    ensure
      FileUtils.mv('./rotate.txt.backup', './rotate.txt') if backup
    end
  end

  it "prints out the rotation order when no command given" do
    run_rotate
    expect(output).to include("Driver Bob","Navigator Phoebe")
  end

  it "prints out help" do
    run_rotate 'help'
    expected = ['Available commands are:',
    '<database txt file> help',
    '<database txt file> rotate',
    '<database txt file> add <name1> [name2]',
    '<database txt file> remove <name1> [name2]',
    '<database txt file> run_with_timer [seconds]'
    ]

    expect(output).to eq(expected)
  end

  it "prints out help on an unknown command" do
    run_rotate 'chicken'
    expected = ['Unknown command chicken',
    'Available commands are:',
    '<database txt file> help',
    '<database txt file> rotate',
    '<database txt file> add <name1> [name2]',
    '<database txt file> remove <name1> [name2]',
    '<database txt file> run_with_timer [seconds]'
    ]

    expect(output).to eq(expected)
  end

  it "changes the order of rotation" do
    run_rotate 'rotate'
    expect(output).to include("Driver Phoebe","Navigator Bob")
  end

  describe "git stuff" do

    it "hides the email address from rotation output" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'

      run_rotate 'rotate'

      expect(output).to include("Driver Phoebe Example")
    end

    it "outputs the new git username when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'

      run_rotate 'rotate'

      expect(output).to include('git username: Phoebe Example', "Driver Phoebe Example")
    end

    it "outputs the new git email when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'

      run_rotate 'rotate'

      expect(output).to include('git user email: phoebe@example.com')

      add_name_and_email_to_temp_db 'David Example', 'david-example@example.com'

      run_rotate 'rotate'

      expect(output).to include('git user email: david-example@example.com')
    end

    it "outputs the new git email when rotating a list of multiple users" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'
      add_name_and_email_to_temp_db 'David Example', 'david@example.com'

      run_rotate 'rotate'

      expect(output).to include('git user email: david@example.com')
    end

    it "updates the git user.name config when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'

      run_rotate 'rotate'

      git_username = `git --git-dir=./tmp/test_project/.git config user.name`.strip
      expect(git_username).to eq('Phoebe Example')
    end

    it "updates the git user.email config when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'

      run_rotate 'rotate'

      git_email = `git --git-dir=./tmp/test_project/.git config user.email`.strip
      expect(git_email).to eq('phoebe@example.com')
    end

    it "updates the email in the mobsters database when rotating" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'
      add_name_and_email_to_temp_db 'Bob Example' 'bob@example.com'
      add_name_and_email_to_temp_db 'Joe Example', 'joe@example.com'

      run_rotate 'rotate'
      run_rotate 'rotate'

      git_email = `git --git-dir=./tmp/test_project/.git config user.email`.strip
      expect(git_email).to eq('joe@example.com')
    end

    it "falls back to a default email address when the driver has none" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'
      add_name_and_email_to_temp_db 'Bob Example'

      run_rotate 'rotate'

      git_email = `git --git-dir=./tmp/test_project/.git config user.email`.strip
      expect(git_email).to eq(default_driver_email_address = 'mob@rubysteps.com')
    end

    it "updates the email in the mobsters database when rotating, even when someone's missing an email address" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example', 'phoebe@example.com'
      add_name_and_email_to_temp_db 'Bob Example'
      add_name_and_email_to_temp_db 'Joe Example', 'joe@example.com'

      run_rotate 'rotate'
      run_rotate 'rotate'

      git_email = `git --git-dir=./tmp/test_project/.git config user.email`.strip
      expect(git_email).to eq('joe@example.com')
    end

  end

  it "adds mobsters to the mob list" do
    run_rotate 'add Joe'
    expect(output).to include("Driver Bob", "Navigator Phoebe", "Mobster Joe")
  end

  it "adds multiple mobsters at once" do
    run_rotate 'add Phil Steve'
    expect(output).to include("Mobster Phil", "Mobster Steve")
  end

  it "removes multiple mobsters at once" do
    run_rotate 'add Phil'
    run_rotate 'remove Bob Phoebe'
    expect(output).to include("Driver Phil")
  end

  it "removes mobsters from the mob list" do
    run_rotate 'remove Bob'
    expect(output).to include("Driver Phoebe")
  end

  it "it runs for a specific amount of time" do
    ts = Time.now
    run_rotate 'run_with_timer 3'
    tf = Time.now
    expect(tf - ts).to be_within(1).of(3.0)
    expect(output).to include("Time to rotate")
  end

  it "waits until time runs out before stating 'Time to Rotate'" do
    expect {
      Timeout::timeout(1) { run_rotate 'run_with_timer 5' }
    }.to raise_error(Timeout::Error)
    expect(output).to eq([])
  end

  describe "beeping" do
    before do
      class WeOverrodeOutputAndUsedItALot
        include RSpec::Matchers
      end
    end

    it "prints an 'audible' beep character" do
      expect { MobRotation.beep }.to WeOverrodeOutputAndUsedItALot.new.output("\a").to_stdout
    end

    it "notifies with a beep" do
      stdout_output = run_rotate_with_specified_redirect 'run_with_timer_and_beep'
      expect(stdout_output).to include("\a")
    end

    it "runs for a specified amount of time and then notifies with a beep" do
      ts = Time.now
      stdout_output = run_rotate_with_specified_redirect 'run_with_timer_and_beep 2'
      tf = Time.now
      expect(tf - ts).to be_within(1).of(2.0)
      expect(stdout_output).to include("Time to rotate")
      expect(stdout_output).to include("\a")
    end

    xit "waits until time runs out before stating 'Time to Rotate'"
    xit "runs the timer when rotating"
  end
end
