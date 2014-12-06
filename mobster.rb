class Mobster
  attr_reader :name, :email
  def initialize(name, email=nil)
    @name = name
    @email = email
  end

  def to_s
    @name
  end
end
