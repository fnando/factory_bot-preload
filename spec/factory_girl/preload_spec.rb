require "spec_helper"

describe Factory::Preload do
  include Factory::Preload::Helpers

  it "queues preloader block" do
    block = proc {}
    Factory.preload(&block)
    Factory::Preload.preloaders.should include(block)
  end

  it "injects model methods" do
    expect { users(:john) }.to_not raise_error
  end

  it "returns :john factory for User model" do
    users(:john).should be_an(User)
  end

  it "returns :ruby factory for Skill model" do
    skills(:ruby).should be_a(Skill)
  end

  it "reuses existing factories" do
    skills(:ruby).user.should == users(:john)
  end

  it "raises error for missing factories" do
    expect { users(:mary) }.to raise_error(%[Couldn't find :mary factory for "User" model])
  end

  it "removes records" do
    User.count.should == 1
    Factory::Preload.clean
    User.count.should == 0
  end

  context "reloadable factories" do
    before :all do
      Factory::Preload.clean
      Factory::Preload.run
    end

    before :each do
      Factory::Preload.reload_factories
    end

    it "updates invitation count" do
      users(:john).increment(:invitations)
      users(:john).save
      users(:john).invitations.should == 1
    end

    it "reloads factory" do
      users(:john).invitations.should == 0
    end
  end
end
