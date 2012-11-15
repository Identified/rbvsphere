$:.push File.expand_path("../lib", __FILE__)


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rbvmomi"
  s.version     = "0.0.1"
  s.authors     = ["Identified"]
  s.email       = ["phil@identified.com"]
  s.homepage    = "http://www.identified.com"
  s.summary     = "Convenient wrapper around the vSphere SDK."
  s.description = "Convenient wrapper around the vSphere SDK."

  s.files = Dir["{lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency "rbvmomi"
end