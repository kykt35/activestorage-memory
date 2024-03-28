# frozen_string_literal: true

require_relative 'lib/active_storage/memory/version'

Gem::Specification.new do |spec|
  spec.name          = 'activestorage-memory'
  spec.version       = ActiveStorage::Memory::VERSION
  spec.authors       = ['kykt35']
  spec.email         = ['kykt35@gmail.com']

  spec.summary       = 'Rails ActiveStorage in-memory service adopter.'
  spec.homepage      = 'https://github.com/kykt35/activestorage-memory'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kykt35/activestorage-memory'
  spec.metadata['changelog_uri'] = 'https://github.com/kykt35/activestorage-memory'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency 'rails', '~> 7.0', '>= 7.0.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
