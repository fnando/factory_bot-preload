require "spec_helper"

describe FactoryGirl::Preload do
  it "queues preloader block" do
    block = proc {}
    FactoryGirl.preload(&block)
    expect(FactoryGirl::Preload.preloaders).to include(block)
  end

  it "should lazy load all factories, loading only when used" do
    expect(FactoryGirl::Preload.record_ids['User'][:john]).to eq(1)
    expect(FactoryGirl::Preload.factories['User'][:john]).to be_nil

    user = users(:john)

    expect(FactoryGirl::Preload.factories['User'][:john]).to eq(user)
  end

  it "injects model methods" do
    expect { users(:john) }.to_not raise_error
  end

  it "returns :john factory for User model" do
    expect(users(:john)).to be_an(User)
  end

  it "returns :ruby factory for Skill model" do
    expect(skills(:ruby)).to be_a(Skill)
  end

  it "returns :my factory for Preload model" do
    expect(preloads(:my)).to be_a(Preload)
  end

  it "reuses existing factories" do
    expect(skills(:ruby).user).to eq(users(:john))
  end

  it "raises error for missing factories" do
    expect { users(:mary) }.to raise_error(%[Couldn't find :mary factory for "User" model])
  end

  it "raises error for missing clean type" do
    FactoryGirl::Preload.clean_with = :invalid
    expect { FactoryGirl::Preload.clean }.to raise_error(%[Couldn't find invalid clean type])
  end

  context "removes records" do
    it "with deletion" do
      expect(User.count).to eq(1)
      FactoryGirl::Preload.clean_with = :deletion
      FactoryGirl::Preload.clean
      expect(User.count).to eq(0)
    end

    it "with truncation" do
      expect(User.count).to eq(1)
      FactoryGirl::Preload.clean_with = :truncation
      FactoryGirl::Preload.clean
      expect(User.count).to eq(0)
    end
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
      expect(users(:john)).to be_frozen
    end

    it "updates invitation count" do
      users(:john).increment(:invitations)
      users(:john).save
      expect(users(:john).invitations).to eq(1)
    end

    it "reloads factory" do
      expect(users(:john).invitations).to eq(0)
      expect(users(:john)).not_to be_frozen
    end
  end

  it "includes factory girl helpers" do
    expect(self.class.included_modules).to include(FactoryGirl::Syntax::Methods)
  end
end
