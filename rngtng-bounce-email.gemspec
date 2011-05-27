# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name          = %q{rngtng-bounce-email}
  s.version       = File.read("VERSION").to_s
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Tobias Bielohlawek", "Agris Ameriks", "Pedro Visintin"]
  s.email         = %q{tobi@rngtng.com}
  s.homepage      = %q{http://github.com/rngtng/bounce-email}
  s.summary       = %q{Detect kind of bounced email}
  s.description   = %q{fork of whatcould/bounce-email incl. patches from wakiki, peterpunk & rngtng}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  ["mail"].each do |gem|
    s.add_dependency *gem.split(' ')
  end  
end

