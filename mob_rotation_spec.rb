require_relative 'mob_rotation'
require "fileutils"

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

  describe "#add_mobster" do
    let(:mob_rotator) { MobRotator.new(foo) }
    let(:foo) { "test.txt" }

    it "adds a mobster to the file" do

      mob_rotator.add_mobster 'Jackie'
      mob_rotator.add_mobster 'Phil'
      expect(File.read(foo)).to include('Jackie')
      expect(File.read(foo)).to include('Phil')
    end
  end
  
  describe "#remove_mobster" do
    let(:mob_rotator) { MobRotator.new(foo) }
    let(:foo) { "test_remove.txt" }
    
    before do
      FileUtils.rm_f(foo)
      File.open(foo, "w") do |file|
        file << "Bob\n" << "Phoebe\n" << "Joe"
      end
    end

    it "removes a mobster from the file" do
      mob_rotator.remove_mobster "Bob"
      expect(File.read(foo)).not_to include('Bob')

    end
  end    
end

# adding remove mobster feature ----
# naming the acteptance---
# add timer feature---
# refactor to dependency injection --
# seperating implementation from the script --
# connect the app with ruby lobby api * -
# add new api via CLI-
# introducing helper_spec(moving)-

# do we keep features that are done or move to changelog?
# focus on refactoring vs adding features?
# adding directory structure

# DONE show mobster should display who navigates and who is driver ****
# DONE method to add
# remove mobsters ***
# remove dependency to / with file ***
# DONE give the describe block a name **
# operating on standard out... would it be worth it to refactor? **
# DONE change it statement... don't know what the subject is *

# --------

# store more mata data in db file(rotation time...)
# write specs for next method rotate?
# how important is it really?
# could change spec to add more meaning
# removing time_to_rotate
