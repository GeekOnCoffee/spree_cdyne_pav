# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_cdyne_pav'
  s.version     = '1.1.2.rc1'
  s.summary     = 'Spree integration with Cdyne Address Verification'
  s.description = 'Spree integration with Cdyne Address Verification, a commercial service'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'Andrew Hooker'
  s.email     = 'andrew@spreecommerce.com'
  s.homepage  = 'http://www.spreecommerce.com'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.1.0.beta'
  s.add_dependency 'active_record_query_trace'

  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
end
