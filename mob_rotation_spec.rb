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

module FooFighter
  def method_added(m)
    raise "no foo for you" if m.to_s == "foo"
  end
end

describe MobRotator do
  extend FooFighter

  describe "#show_mobsters" do

    let(:mob_rotator) { MobRotator.new(file_name) }
    let(:file_name) { "test.txt" }
    let(:output) { Output.new }

    before do
      File.open(file_name, "w") do |file|
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
    let(:mob_rotator) { MobRotator.new(file_name) }
    let(:file_name) { "test.txt" }

    it "adds a mobster to the file" do

      mob_rotator.add_mobster 'Jackie'
      mob_rotator.add_mobster 'Phil'
      expect(File.read(file_name)).to include('Jackie')
      expect(File.read(file_name)).to include('Phil')
    end
  end
  
  describe "#remove_mobster" do
    let(:mob_rotator) { MobRotator.new(file_name) }
    let(:file_name) { "test_remove.txt" }
    
    before do
      FileUtils.rm_f(file_name)
      File.open(file_name, "w") do |file|
        file << "Bob\n" << "Phoebe\n" << "Joe"
      end
    end

    it "removes a mobster from the file" do
      mob_rotator.remove_mobster "Bob"
      expect(File.read(file_name)).not_to include('Bob')

    end
  end    
end

describe Timer do
  describe "#timer" do
    it "Times a mob rotation" do
      expect(Timer.timer(7)).to eq(7)
      
    end
  end
end
  

# Time.now() == 7min ->timeisup!

# naming acceptance ... again!~~~
# No Readme file ~~~
# End goal of the app ~~~
# add a timer feature ~~~
# is this going to stay a CLI, gem, rails app feature? Forward direction? ~~

# introduce helper spec~
# separate implementation from script~
# organizing cli vs unit specs ~
# Common structure for running tests
# our 'clean state' isnt that clean. Lots of duplicate files from before



# DONE adding remove mobster feature ----
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
