# -*- encoding: utf-8 -*-
lib = File.expand_path('lib', File.dirname(__FILE__))
$:.unshift lib unless $:.include?(lib)

require 'xpath/version'

Gem::Specification.new do |s|
  s.name = "xpath"
  s.rubyforge_project = "xpath"
  s.version = XPath::VERSION

  s.authors = ["Jonas Nicklas"]
  s.email = ["jonas.nicklas@gmail.com"]
  s.description = "XPath is a Ruby DSL for generating XPath expressions"

  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md)
  s.extra_rdoc_files = ["README.md"]

  s.homepage = "http://github.com/jnicklas/xpath"
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.6"
  s.summary = "Generate XPath expressions from Ruby"

  s.add_dependency("nokogiri", ["~> 1.3"])

  s.add_development_dependency("rspec", ["~> 2.0"])
  s.add_development_dependency("yard", [">= 0.5.8"])
  s.add_development_dependency("rake")

  if File.exist?("gem-private_key.pem")
    s.signing_key = 'gem-private_key.pem'
  end
  s.cert_chain = ['gem-public_cert.pem']
end
