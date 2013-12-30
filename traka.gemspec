$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "traka/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "traka"
  s.version     = Traka::VERSION
  s.authors     = ["Andrew Buntine"]
  s.email       = ["info@andrewbuntine.com"]
  s.homepage    = "http://github.com/buntine/traka"
  s.summary     = "Rails 3+ plugin for simple tracking of changes to resources over time."
  s.description = "Rails 3+ plugin for simple tracking of changes to resources over time."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"

  s.add_development_dependency "sqlite3"
end
