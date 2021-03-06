# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_yandex_market'
  s.version     = '0.0.1'
  s.summary     = 'Provides export products to Yandex Market Language format'
  # s.description = 'TODO: Add (optional) gem description here'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Ivan Youroff'
  s.email     = 'ivan.youroff@gmail.com'
  # s.homepage  = 'http://www.spreecommerce.com'

  s.files       = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.0.3'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'capybara', '~> 1.1.2'
  # s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  # s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'sqlite3'
end
