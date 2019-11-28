# factory_bot-preload

[![Travis-CI](https://travis-ci.org/fnando/factory_bot-preload.svg)](https://travis-ci.org/fnando/factory_bot-preload)
[![Code Climate](https://codeclimate.com/github/fnando/factory_bot-preload/badges/gpa.svg)](https://codeclimate.com/github/fnando/factory_bot-preload)
[![Test Coverage](https://codeclimate.com/github/fnando/factory_bot-preload/badges/coverage.svg)](https://codeclimate.com/github/fnando/factory_bot-preload/coverage)
[![Gem](https://img.shields.io/gem/v/factory_bot-preload.svg)](https://rubygems.org/gems/factory_bot-preload)
[![Gem](https://img.shields.io/gem/dt/factory_bot-preload.svg)](https://rubygems.org/gems/factory_bot-preload)

We all love Rails fixtures because they're fast, but we hate to deal with YAML/CSV/SQL files. Here enters [factory_bot](https://rubygems.org/gems/factory_bot) (FB).

Now, you can easily create records by using predefined factories. The problem is that hitting the database everytime to create records is pretty slow. And believe me, you'll feel the pain when you have lots of tests/specs.

So here enters Factory Bot Preload (FBP). You can define which factories will be preloaded, so you don't have to recreate it every time (that will work for 99.37% of the time, according to statistics I just made up).

## Installation

    gem install factory_bot-preload

## Intructions

### Installation

Add both FB and FBP to your Gemfile:

```ruby
source "https://rubygems.org"

gem "rails"
gem "pg"

group :test, :development do
  gem "factory_bot"
  gem "factory_bot-preload"
end
```

### RSpec Setup

On your `spec/spec_helper.rb` file, make sure that transactional fixtures are enabled. Here's is my file without all those RSpec comments:

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

### Minitest Setup

On your `test/test_helper.rb` file, make sure that transaction fixtures are enabled. Here's what your file may look like:

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

Create your factories and load it from your setup file (either `test/test_helper.rb` or `spec/spec_helper.rb`) You may have something like this:

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

Like Rails fixtures, FBP will define methods for each model. You can use it on your examples and alike.

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

* Nando Vieira (http://nandovieira.com)

## License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
