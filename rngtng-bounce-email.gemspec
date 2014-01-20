# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name          = %q{rngtng-bounce-email}
  s.version       = File.read("VERSION").to_s
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Tobias Bielohlawek", "Agris Ameriks", "Pedro Visintin"]
  s.email         = %q{tobi@rngtng.com}
  s.homepage      = %q{http://github.com/mitio/bounce_email}
  s.summary       = %q{THIS GEM IS DEPRECATED, PLS SEE http://github.com/mitio/bounce_email FOR LATEST VERSION}
  s.description   = %q{THIS GEM IS DEPRECATED, PLS SEE http://github.com/mitio/bounce_email FOR LATEST VERSION}

  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  # s.require_paths = ["lib"]
  
  ["bounce_email"].each do |gem|
    s.add_dependency *gem.split(' ')
  end  
end

