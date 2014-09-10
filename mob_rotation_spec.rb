require_relative 'mob_rotation'

describe do
  it "prints out the rotation order" do
    `echo 'Bob' > rotation_test.txt`
    `echo 'Phoebe' >> rotation_test.txt`
    `ruby mob_rotation.rb rotation_test.txt > results.txt`
    output = File.readlines('results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Driver Bob","Navigator Phoebe"])
  end

  it "changes the order of rotation" do
    `echo 'Bob' > rotation_test.txt`
    `echo 'Phoebe' >> rotation_test.txt`
    `ruby mob_rotation.rb rotation_test.txt rotate > results.txt`
    output = File.readlines('results.txt').map(&:strip).reject(&:empty?)
    
    expect(output).to eq(["Driver Phoebe","Navigator Bob"])
  end
end

class Output
  attr_accessor :mobsters

  def write(argument)
    @mobsters ||= []
    @mobsters << argument
  end
end

describe MobRotator do
  describe "#show_mobsters" do
    let(:mob_rotator) { MobRotator.new(foo) }
    let(:foo) { "test.txt" }
    let(:output) { Output.new }

    before do
      File.open(foo, "w") do |file|
        file << "Bob\n" << "Phoebe\n" << "Joe"
      end

      $stdout = output

      mob_rotator.show_mobsters()
    end

    it "print out all the mobsters in the text file" do
      expect(output.mobsters.join).to include("Mobster Joe")
    end

    it "prints out driver" do
      expect(output.mobsters.join).to include("Driver Bob")
    end

    it "prints out navigator" do
      expect(output.mobsters.join).to include("Navigator Phoebe")
    end
  end
end

# DONE show mobster should display who navigates and who is driver ****
# method to add / remove mobsters ***
# remove dependency to / with file ***
# DONE give the describe block a name **
# operating on standard out... would it be worth it to refactor? **
# DONE change it statement... don't know what the subject is *
# connect the app with ruby lobby api *

# --------

# store more mata data in db file(rotation time...)
# write specs for next method rotate?
# how important is it really?
# could change spec to add more meaning
# refactor to dependency injection
# removing time_to_rotate
# add timer feature
