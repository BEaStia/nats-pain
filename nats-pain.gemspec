
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nats/pain/version"

Gem::Specification.new do |spec|
  spec.name          = "nats-pain"
  spec.version       = Nats::Pain::VERSION
  spec.authors       = ["Igor Pavlov"]
  spec.email         = ["gophan1992@gmail.com"]

  spec.summary       = %q{This is a small subsystem extraced from Iconjob projects to OSS.}
  spec.description   = %q{It is a system that uses connection_pool, nats, nats-streaming in on system to guarantee that everything works fine}
  spec.homepage      = "https://github.com/beastia/nats-pain"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/beastia/nats-pain"
    spec.metadata["changelog_uri"] = "https://github.com/BEaStia/nats-pain/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency 'nats-pure', '~> 0.5.0'
  spec.add_dependency 'nats-streaming', '~> 0.2.2'
  spec.add_dependency 'connection_pool', '>= 2'
end
