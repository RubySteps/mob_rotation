require_relative '../mob_rotation'
require "fileutils"

describe do
  it "prints out the rotation order" do
    `echo 'Bob' > /tmp/rotation_test.txt`
    `echo 'Phoebe' >> /tmp/rotation_test.txt`
    `ruby /home/rubysteps/mob_rotation/mob_rotation /tmp/rotation_test.txt > /tmp/results.txt`
    output = File.readlines('/tmp/results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Driver Bob","Navigator Phoebe"])
  end

  it "changes the order of rotation" do
    `echo 'Bob' > /tmp/rotation_test.txt`
    `echo 'Phoebe' >> /tmp/rotation_test.txt`
    `ruby /home/rubysteps/mob_rotation/mob_rotation /tmp/rotation_test.txt rotate > /tmp/results.txt`
    output = File.readlines('/tmp/results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Driver Phoebe","Navigator Bob"])
  end
end
