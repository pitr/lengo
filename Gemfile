source :rubygems

gem 'rails', '~> 3.2.9'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'

  gem "less-rails", ">= 2.2.6"
  gem "twitter-bootstrap-rails", ">= 2.1.6"
  gem "therubyracer", ">= 0.10.2", :platform => :ruby
end
gem 'jquery-rails'

group :production do
  gem "unicorn"
end

## Models
gem "mysql2"
gem "devise"

## Views
gem "slim-rails"

gem 'rest-client'

group :development do
  gem "quiet_assets"
end

group :development, :test do
  gem "rspec-rails"
  gem "fabrication"
end

group :test do
  gem "database_cleaner"
end
