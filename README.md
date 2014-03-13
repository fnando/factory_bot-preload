# factory_girl-preload

We all love Rails fixtures because they're fast, but we hate to deal with YAML/CSV/SQL files. Here enters Factory Girl (FG).

Now, you can easily create records by using predefined factories. The problem is that hitting the database everytime to create records is pretty slow. And believe me, you'll feel the pain when you have lots of specs.

So here enters Factory Girl Preload (FGP). You can define which factories will be preloaded, so you don't have to recreate it every time (that will work for 99.37% of the time, according to statistics I just made up).

## Installation

    gem install factory_girl-preload

## Usage

I'm focusing Rails 3 + RSpec 2 stack, so I can't really guarantee that it will work on other setups. Here's how you get started:

Add both FG and FGP to your Gemfile:

```ruby
source "https://rubygems.org"

gem "rails"
gem "mysql2", "~> 0.2.7"

group :test, :development do
  gem "rspec-rails"
  gem "factory_girl"
  gem "factory_girl-preload"
end
```

On `spec/spec_helper.rb` file, make sure that transactional fixtures are enabled. Here's is my file without all those RSpec comments:

```ruby
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.mock_with :rspec
end
```

Create your factories on `spec/support/factories.rb`. You may have something like this:

```ruby
FactoryGirl.define do
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
FactoryGirl.define do
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
    factory(:john) { Factory(:user) }
    factory(:myapp) { Factory(:project, user: users(:john)) }
  end
end
```

Like Rails fixtures, FGP will define methods for each model. You can use it on your examples and alike.

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

Easy and, probably, faster!

== Maintainer

* Nando Vieira (http://nandovieira.com.br)

== License

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
