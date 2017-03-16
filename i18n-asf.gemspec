# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "i18n-asf"
  s.version     = "0.0.4"
  s.authors     = ["David Demaree"]
  s.email       = ["ddemaree@adobe.com"]
  s.homepage    = "https://typekit.com/"
  s.summary     = %q{Ruby I18n backend capable of reading Adobe Strings Format (ASF) XML files}
  s.description = %q{See above.}

  s.rubyforge_project = "i18n-asf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "nokogiri"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fivemat"
  s.add_development_dependency "putsinator"
  s.add_development_dependency "awesome_print"
end
