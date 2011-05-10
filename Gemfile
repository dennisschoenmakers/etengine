source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.0.7'
gem 'jquery-rails'
gem 'haml', '~>3.1.1'
gem 'sass', '~>3.1.1'

gem 'authlogic', :git => 'git://github.com/odorcicd/authlogic.git', :branch => 'rails3'
gem 'bluecloth'
gem 'formtastic'
gem 'http_status_exceptions', :git => 'git://github.com/japetheape/http_status_exceptions.git' 
gem 'jammit'
gem 'paper_trail', '>= 1.6.4'
gem 'ruby-graphviz', :require => "graphviz"
gem 'treetop', '1.4.8'
gem 'default_value_for'
gem 'paperclip', '>= 2.3.8'
gem 'acts_as_list'

# javascript
gem 'sprockets'
gem 'sprockets-rails'
gem 'rack-sprockets'
gem 'yui-compressor'

# supporting gems
gem 'hoptoad_notifier', '2.4.2'

# system gems
gem 'thinking-sphinx', '>=2.0.1'
gem 'mysql2'
gem 'memcache-client'

# Optional gems that were commented in environment.rb
gem 'rubyzip', '0.9.4'
gem "ruby-openid", :require => "openid" # AWAY

group :development do
  gem 'yard', '0.5.4'
end

group :test, :development do
  gem "rspec-rails", "~> 2.1.0"
  gem 'ruby-debug19'
  gem 'watchr'
end

group :test do
  gem 'nokogiri' #AWAY
  gem 'factory_girl', '>= 1.2.3'
  gem 'webrat'
  gem 'libxml-ruby' # AWAY
  gem 'simplecov', :require => false
end


