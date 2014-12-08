require 'spec_helper'

describe FooFighter do
  it "raises an error when a class defines `#foo`" do
    expect {
      class TestClass
        extend FooFighter

        def foo
          "shouldn't work"
        end
      end
    }.to raise_error(/no foo for you/)
  end

  it "removes a method named `#foo`" do
    begin
      class TestClass2
        extend FooFighter

        def foo
          "shouldn't work"
        end
      end
    rescue => e
      # no-op
    ensure
      expect(TestClass2.instance_methods - Object.methods).to_not include(:foo)
    end
  end
end
