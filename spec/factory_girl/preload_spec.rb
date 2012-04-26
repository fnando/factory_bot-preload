require "spec_helper"

describe FactoryGirl::Preload do
  include FactoryGirl::Preload::Helpers

  it "queues preloader block" do
    block = proc {}
    FactoryGirl.preload(&block)
    FactoryGirl::Preload.preloaders.should include(block)
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

  it "returns :my factory for Preload model" do
    preloads(:my).should be_a(Preload)
  end

  it "reuses existing factories" do
    skills(:ruby).user.should == users(:john)
  end

  it "raises error for missing factories" do
    expect { users(:mary) }.to raise_error(%[Couldn't find :mary factory for "User" model])
  end

  it "removes records" do
    User.count.should == 1
    FactoryGirl::Preload.clean
    User.count.should == 0
  end

  context "reloadable factories" do
    before :all do
      FactoryGirl::Preload.clean
      FactoryGirl::Preload.run
    end

    before :each do
      FactoryGirl::Preload.reload_factories
    end

    it "freezes object" do
      users(:john).destroy
      users(:john).should be_frozen
    end

    it "updates invitation count" do
      users(:john).increment(:invitations)
      users(:john).save
      users(:john).invitations.should == 1
    end

    it "reloads factory" do
      users(:john).invitations.should == 0
      users(:john).should_not be_frozen
    end
  end
end
