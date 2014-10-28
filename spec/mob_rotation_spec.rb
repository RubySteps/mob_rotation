require_relative '../mob_rotation'
require "fileutils"



describe do
  let(:temp_rotation_db) { '/tmp/rotation_test.txt' }

  def remove_temp_rotation_db
    FileUtils.rm temp_rotation_db
  end

  def add_name_to_temp_db(name)
    `echo "#{name}" >> #{temp_rotation_db}`
  end    

  before do
    remove_temp_rotation_db

    add_name_to_temp_db 'Bob'
    add_name_to_temp_db 'Phoebe'
  end

  def run_rotate(command = nil)
    `ruby /home/rubysteps/mob_rotation/mob_rotation #{temp_rotation_db} #{command}  > /tmp/results.txt` 
  end

  let(:output) { File.readlines('/tmp/results.txt').map(&:strip).reject(&:empty?) }

  it "allows the database file to be specified"

  it "defaults to 'rotate.txt' when no database file is specified" do
    if backup = File.exists?('./rotate.txt')
      FileUtils.mv('./rotate.txt', './rotate.txt.backup')
    end
    FileUtils.cp(temp_rotation_db, './rotate.txt')
    `ruby /home/rubysteps/mob_rotation/mob_rotation > /tmp/results.txt` 
    begin
      expect(output).to eq(["Driver Bob","Navigator Phoebe"])
    ensure
      FileUtils.mv('./rotate.txt.backup', './rotate.txt') if backup    
    end
  end

  it "prints out the rotation order when no command given" do
    run_rotate
    expect(output).to eq(["Driver Bob","Navigator Phoebe"])
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
    expect(output).to eq(["Driver Phoebe","Navigator Bob"])
  end

  it "hides the email address from rotation output" do
    remove_temp_rotation_db
    add_name_to_temp_db 'Phoebe Example <phoebe@example.com>'

    run_rotate 'rotate'

    expect(output).to eq(["Driver Phoebe Example"])
  end

  it "blah blah" do
    pending

    git_username = `git config user.name`
    git_email = `git config user.email`

    expect(git_username).to eq('Phoebe Example')
    expect(git_email).to eq('phoebe@example.com')
  end
  
  it "adds mobsters to the mob list" do
    run_rotate 'add Joe'
    expect(output).to eq(["Driver Bob", "Navigator Phoebe", "Mobster Joe"])
  end

  it "adds multiple mobsters at once" do
    run_rotate 'add Phil Steve'
    expect(output).to include(*["Mobster Phil", "Mobster Steve"])
  end
  
  it "removes multiple mobsters at once" do
    run_rotate 'add Phil'
    run_rotate 'remove Bob Phoebe'
    expect(output).to eq(["Driver Phil"])
  end
  
  it "removes mobsters from the mob list" do
    run_rotate 'remove Bob'
    expect(output).to eq(["Driver Phoebe"])
  end 

  it "it runs for a specific amount of time" do
    ts = Time.now
    run_rotate 'run_with_timer 3'
    tf = Time.now
    expect(tf - ts).to be_within(1).of(3.0)
    expect(output).to eq(["Time to rotate"])
  end

  it "waits until time runs out before stating 'Time to Rotate'" do
    expect {
      Timeout::timeout(1) { run_rotate 'run_with_timer 5' }
    }.to raise_error(Timeout::Error)
    expect(output).to eq([])
  end
end
