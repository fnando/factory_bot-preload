require "test_helper"

class PreloadTest < ActiveSupport::TestCase
  setup do
    FactoryBot::Preload.clean_with = :truncation
  end

  test "queues preloader block" do
    block = proc { }
    FactoryBot.preload(&block)
    assert_includes FactoryBot::Preload.preloaders, block
  end

  test "lazy load all factories, loading only when used" do
    assert_equal 1, FactoryBot::Preload.record_ids["User"][:john]
    assert_nil FactoryBot::Preload.factories["User"][:john]

    user = users(:john)

    assert_equal user, FactoryBot::Preload.factories["User"][:john]
  end

  test "injects model methods" do
    # this shouldn't raise an exception
    users(:john)
  end

  test "returns :john factory for User model" do
    assert_instance_of User, users(:john)
  end

  test "returns :ruby factory for Skill model" do
    assert_instance_of Skill, skills(:ruby)
  end

  test "returns :my factory for Preload model" do
    assert_instance_of Preload, preloads(:my)
  end

  test "reuses existing factories" do
    assert_equal users(:john), skills(:ruby).user
  end

  test "raises error for missing factories" do
    assert_raises(%[Couldn't find :mary factory for "User" model]) do
      users(:mary)
    end
  end

  test "raises error for missing clean type" do
    FactoryBot::Preload.clean_with = :invalid
    assert_raises(%[Couldn't find invalid clean type]) { FactoryBot::Preload.clean }
  end

  test "association uses preloaded record" do
    assert_equal users(:john), build(:skill).user
  end

  test "removes records with :deletion" do
    assert_equal 1, User.count
    FactoryBot::Preload.clean_with = :deletion
    FactoryBot::Preload.clean
    assert_equal 0, User.count
  end

  test "removes records with :truncation" do
    assert_equal 1, User.count
    FactoryBot::Preload.clean_with = :truncation
    FactoryBot::Preload.clean
    assert_equal 0, User.count
  end

  test "includes factory_bot helpers" do
    assert_includes self.class.included_modules, FactoryBot::Syntax::Methods
  end

  test "includes helpers into factory_bot" do
    assert_includes FactoryBot::SyntaxRunner.included_modules, FactoryBot::Preload::Helpers
  end

  test "freezes object" do
    users(:john).destroy
    assert users(:john).frozen?
  end

  test "updates invitation count" do
    users(:john).increment(:invitations)
    users(:john).save

    assert_equal 1, users(:john).invitations
  end

  test "reloads factory" do
    assert_equal 0, users(:john).invitations
    refute users(:john).frozen?
  end
end
