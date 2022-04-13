# frozen_string_literal: true

lib = File.expand_path('lib', File.dirname(__FILE__))
$:.unshift lib unless $:.include?(lib)
require 'xpath/version'

Gem::Specification.new do |s|
  s.name = 'xpath'
  s.version = XPath::VERSION
  s.required_ruby_version = '>= 2.5'

  s.authors = ['Jonas Nicklas']
  s.email = ['jonas.nicklas@gmail.com']
  s.description = 'XPath is a Ruby DSL for generating XPath expressions'
  s.license = 'MIT'

  s.files = Dir.glob('lib/**/*') + %w[README.md] + %w[LICENSE]

  s.homepage = 'https://github.com/teamcapybara/xpath'
  s.summary = 'Generate XPath expressions from Ruby'

  s.add_dependency('nokogiri', ['~> 1.8'])

  s.add_development_dependency('pry')
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', ['~> 3.0'])
  s.add_development_dependency('yard', ['>= 0.5.8'])

  s.signing_key = 'gem-private_key.pem' if File.exist?('gem-private_key.pem')
  s.cert_chain = ['gem-public_cert.pem']
end
