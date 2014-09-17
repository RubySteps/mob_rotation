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
end
