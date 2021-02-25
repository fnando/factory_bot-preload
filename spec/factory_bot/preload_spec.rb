# frozen_string_literal: true

require "spec_helper"

describe FactoryBot::Preload do
  it "queues preloader block" do
    block = proc { }
    FactoryBot.preload(&block)
    expect(FactoryBot::Preload.preloaders).to include(block)
  end

  it "should lazy load all factories, loading only when used" do
    expect(FactoryBot::Preload.record_ids["User"][:john]).to eq(1)
    expect(FactoryBot::Preload.fixtures_per_test["User-john"]).to be_nil

    user = users(:john)
    user.email = "super@gmail.com"

    expect(users(:john).object_id).to eq(user.object_id)
    expect(FactoryBot::Preload.fixtures_per_test["User-john"]).not_to be_nil
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
    expect { users(:mary) }.to raise_error(%[Couldn't find :mary fixture for "User" model])
  end

  it "ignores reserved table names when creating helpers" do
    mod = Module.new do
      include FactoryBot::Preload::Helpers
    end

    instance = Object.new.extend(mod)

    expect(instance).not_to respond_to(:active_record_internal_metadata)
    expect(instance).not_to respond_to(:active_record_schema_migrations)
    expect(instance).not_to respond_to(:primary_schema_migrations)
  end

  example "association uses preloaded record" do
    expect(build(:skill).user).to eq(users(:john))
  end

  it "removes records with truncation" do
    expect(User.count).to eq(1)
    FactoryBot::Preload.clean
    expect(User.count).to eq(0)
  end

  context "reloadable factories" do
    before :all do
      FactoryBot::Preload.clean
      FactoryBot::Preload.run
    end

    before :each do
      FactoryBot::Preload.reload_factories
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

  it "includes factory_bot helpers" do
    expect(self.class.included_modules).to include(FactoryBot::Syntax::Methods)
  end

  it "includes helpers into factory_bot" do
    expect(FactoryBot::SyntaxRunner.included_modules).to include(FactoryBot::Preload::Helpers)
  end
end
