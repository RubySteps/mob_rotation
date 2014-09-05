require_relative 'mob_rotation'

describe do
  it "prints out the rotation order" do
    `echo 'Bob' > rotation_test.txt`
    `echo 'Phoebe' >> rotation_test.txt`
    `ruby mob_rotation.rb rotation_test.txt > results.txt`
    output = File.readlines('results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Mobster Bob","Mobster Phoebe"])
  end

  it "changes the order of rotation" do
    `echo 'Bob' > rotation_test.txt`
    `echo 'Phoebe' >> rotation_test.txt`
    `ruby mob_rotation.rb rotation_test.txt rotate > results.txt`
    output = File.readlines('results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Mobster Phoebe","Mobster Bob"])    
  end
end

class Output
  attr_accessor :mobsters

  def write(argument)
    @mobsters ||= []
    @mobsters << argument
  end
end

describe do
  it "should print out all the mobsters in the text file" do
    foo = "test.txt"

    File.open(foo, "w") do |file|
      file << "Bob\n" << "Phoebe"
    end

    mob_rotator = MobRotator.new(foo) #arrange
    $stdout = output = Output.new
    mob_rotator.show_mobsters() #act
    expect(output.mobsters.join).to eq("Mobster Bob\nMobster Phoebe\n") #assert
  end
end
