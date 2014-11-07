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

  def add_name_and_email_to_temp_db(name)
    `echo "#{name}" >> #{temp_rotation_db}`
  end    

  before do
    remove_temp_rotation_db

    add_name_and_email_to_temp_db 'Bob'
    add_name_and_email_to_temp_db 'Phoebe'
  end

  def run_rotate(command = nil)
    @output = nil

    `MOB_GIT_DIR='./tmp/test_project/.git' ruby /home/rubysteps/mob_rotation/mob_rotation #{temp_rotation_db} #{command}  > /tmp/results.txt`
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
    '<database txt file> remove <name1> [name2]']

    expect(output).to eq(expected)
  end

  it "prints out help on an unknown command" do
    run_rotate 'chicken'
    expected = ['Unknown command chicken', 
    'Available commands are:',
    '<database txt file> help',
    '<database txt file> rotate', 
    '<database txt file> add <name1> [name2]',
    '<database txt file> remove <name1> [name2]']

    expect(output).to eq(expected)
  end

  it "changes the order of rotation" do
    run_rotate 'rotate'
    expect(output).to include("Driver Phoebe","Navigator Bob")
  end

  describe "git stuff" do

    it "hides the email address from rotation output" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example <phoebe@example.com>'

      run_rotate 'rotate'

      expect(output).to include("Driver Phoebe Example")
    end

    it "outputs the new git username when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example <phoebe@example.com>'

      run_rotate 'rotate'

      expect(output).to include('git username: Phoebe Example', "Driver Phoebe Example")
    end

    it "outputs the new git email when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example <phoebe@example.com>'

      run_rotate 'rotate'

      expect(output).to include('git user email: phoebe@example.com')

      add_name_and_email_to_temp_db 'David Example <david-example@example.com>'

      run_rotate 'rotate'

      expect(output).to include('git user email: david-example@example.com')
    end

    it "outputs the new git email when rotating a list of multiple users" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example <phoebe@example.com>'
      add_name_and_email_to_temp_db 'David Example <david@example.com>'

      run_rotate 'rotate'

      expect(output).to include('git user email: david@example.com')
      
    end

    it "updates the git user.name config when running rotate" do
      remove_temp_rotation_db
      add_name_and_email_to_temp_db 'Phoebe Example <phoebe@example.com>'

      run_rotate 'rotate'

      git_username = `git --git-dir=./tmp/test_project/.git config user.name`.strip
      expect(git_username).to eq('Phoebe Example')
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
end
