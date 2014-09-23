require_relative '../mob_rotation'
require "fileutils"



describe do
  before do
    `echo 'Bob' > /tmp/rotation_test.txt`
    `echo 'Phoebe' >> /tmp/rotation_test.txt`
  end

  def run_rotate(command = nil)
    `ruby /home/rubysteps/mob_rotation/mob_rotation /tmp/rotation_test.txt #{command}  > /tmp/results.txt` 
  end

  let(:output) { File.readlines('/tmp/results.txt').map(&:strip).reject(&:empty?) }

  it "prints out the rotation order" do
    run_rotate
    expect(output).to eq(["Driver Bob","Navigator Phoebe"])
  end

  it "changes the order of rotation" do
    run_rotate 'rotate'
    expect(output).to eq(["Driver Phoebe","Navigator Bob"])
  end
  
  it "adds mobsters to the mob list" do
    run_rotate 'add Joe'
    expect(output).to eq(["Driver Bob", "Navigator Phoebe", "Mobster Joe"])
  end

  it "adds multiple mobsters at once" do
    run_rotate 'add Phil Steve'
    expect(output).to include(*["Mobster Phil", "Mobster Steve"])
  end
  
  it "removes multiple mobstars at once" do
    run_rotate 'add Phil'
    run_rotate 'remove Bob Phoebe'
    expect(output).to eq(["Driver Phil"])
  end
  
  it "removes mobsters from the mob list" do
    run_rotate 'remove Bob'
    expect(output).to eq(["Driver Phoebe"])
  end 
end
