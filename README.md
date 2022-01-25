# factory_bot-preload

[![ruby-tests](https://github.com/fnando/factory_bot-preload/actions/workflows/ruby-tests.yml/badge.svg)](https://github.com/fnando/factory_bot-preload/actions/workflows/ruby-tests.yml)
[![Gem](https://img.shields.io/gem/v/factory_bot-preload.svg)](https://rubygems.org/gems/factory_bot-preload)
[![Gem](https://img.shields.io/gem/dt/factory_bot-preload.svg)](https://rubygems.org/gems/factory_bot-preload)

We all love Rails fixtures because they're fast, but we hate to deal with
YAML/CSV/SQL files. Here enters
[factory_bot](https://rubygems.org/gems/factory_bot) (FB).

Now, you can easily create records by using predefined factories. The problem is
that hitting the database everytime to create records is pretty slow. And
believe me, you'll feel the pain when you have lots of tests/specs.

So here enters Factory Bot Preload (FBP). You can define which factories will be
preloaded, so you don't have to recreate it every time (that will work for
99.37% of the time, according to statistics I just made up).

## Installation

    gem install factory_bot-preload

## Intructions

### Setup

Add both FB and FBP to your Gemfile:

```ruby
source "https://rubygems.org"

gem "rails"
gem "pg"

group :test, :development do
  gem "factory_bot"
  gem "factory_bot-preload", require: false
end
```

Notice that adding `require: false` is important; otherwise you won't be able to
run commands such as `rails db:test:prepare`.

### RSpec Setup

On your `spec/spec_helper.rb` file, make sure that transactional fixtures are
enabled. Here's is my file without all those RSpec comments:

```ruby
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

# First, load factory_bot/preload.
require "factory_bot/preload"

# Then load your factories
Dir[Rails.root.join("spec/support/factories/**/*.rb")].each do |file|
  require file
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.mock_with :rspec
end
```

You may want to configure the generated helper names. For instance, imagine you
have a namespace like `MyApp::Models::User`. That'd generate a helper method
like `myapp_models_user`. If you don't have conflicting names, you can strip
`myapp_models_` like this:

```ruby
FactoryBot::Preload.helper_name = lambda do |class_name, helper_name|
  helper_name.gsub(/^myapp_models_/, "")
end
```

### Minitest Setup

On your `test/test_helper.rb` file, make sure that transaction fixtures are
enabled. Here's what your file may look like:

```ruby
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    self.use_instantiated_fixtures = true
  end
end

# First, load factory_bot/preload.
require "factory_bot/preload"

# Then load your factories.
Dir["./test/support/factories/**/*.rb"].each do |file|
  require file
end

# Finally, setup minitest.
# Your factories won't behave correctly unless you
# call `FactoryBot::Preload.minitest` after loading them.
FactoryBot::Preload.minitest
```

### Usage

Create your factories and load it from your setup file (either
`test/test_helper.rb` or `spec/spec_helper.rb`) You may have something like
this:

```ruby
FactoryBot.define do
  factory :user do
    name "John Doe"
    sequence(:email) {|n| "john#{n}@example.org" }
    sequence(:username) {|n| "john#{n}" }
    password "test"
    password_confirmation "test"
  end

  factory :projects do
    name "My Project"
    association :user
  end
end
```

To define your preloadable factories, just use the `preload` method:

```ruby
FactoryBot.define do
  factory :user do
    name "John Doe"
    sequence(:email) {|n| "john#{n}@example.org" }
    sequence(:username) {|n| "john#{n}" }
    password "test"
    password_confirmation "test"
  end

  factory :projects do
    name "My Project"
    association :user
  end

  preload do
    factory(:john) { create(:user) }
    factory(:myapp) { create(:project, user: users(:john)) }
  end
end
```

You can also use preloaded factories on factory definitions.

```ruby
FactoryBot.define do
  factory :user do
    # ...
  end

  factory :projects do
    name "My Project"
    user { users(:john) }
  end

  preload do
    factory(:john) { create(:user) }
    factory(:myapp) { create(:project, user: users(:john)) }
  end
end
```

Like Rails fixtures, FBP will define methods for each model. You can use it on
your examples and alike.

```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "returns john's record" do
    assert_instance_of User, users(:john)
  end

  test "returns myapp's record" do
    assert_equal users(:john), projects(:myapp).user
  end
end
```

Or if you're using RSpec:

```ruby
require "spec_helper"

describe User do
  let(:user) { users(:john) }

  it "returns john's record" do
    users(:john).should be_an(User)
  end

  it "returns myapp's record" do
    projects(:myapp).user.should == users(:john)
  end
end
```

That's it!

## Maintainer

- [Nando Vieira](https://github.com/fnando)

## Contributors

- https://github.com/fnando/factory_bot-preload/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/fnando/factory_bot-preload/blob/main/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/fnando/factory_bot-preload/blob/main/LICENSE.md.

## Code of Conduct

Everyone interacting in the factory_bot-preload project's codebases, issue
trackers, chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/factory_bot-preload/blob/main/CODE_OF_CONDUCT.md).
