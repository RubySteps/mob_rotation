require "fileutils"
require "mob_rotation"

class Output
  attr_accessor :mobsters

  def write(argument)
    @mobsters ||= []
    @mobsters << argument
  end
end

module FooFighter
  def method_added(m)
    return unless m.to_s == "foo"
    remove_method(m)
    fail("no foo for you")
  end
end
