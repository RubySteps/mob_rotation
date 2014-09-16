require_relative '../mob_rotation'
require "fileutils"

describe do
  it "prints out the rotation order" do
    `echo 'Bob' > rotation_test.txt`
    `echo 'Phoebe' >> rotation_test.txt`
    `ruby ../mob_rotation.rb rotation_test.txt > results.txt`
    output = File.readlines('results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Driver Bob","Navigator Phoebe"])
  end

  it "changes the order of rotation" do
    `echo 'Bob' > rotation_test.txt`
    `echo 'Phoebe' >> rotation_test.txt`
    `ruby ../mob_rotation.rb rotation_test.txt rotate > results.txt`
    output = File.readlines('results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Driver Phoebe","Navigator Bob"])
  end
end
