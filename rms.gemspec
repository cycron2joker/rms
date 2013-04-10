# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rms/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Cycron Joker"]
  gem.email         = ["cycron2joker@gmail.com"]
  gem.description   = %q{for connect and operation to rms}
  gem.summary       = %q{rms operation library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rms"
  gem.require_paths = ["lib"]
  gem.version       = Rms::VERSION

	# dependency
#	gem.add_dependency('rspec' ,'>= 2.9.0')
	gem.add_dependency('mechanize', '>= 1.0.0')

end
