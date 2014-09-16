require_relative '../mob_rotation'
require "fileutils"

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
