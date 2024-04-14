# frozen_string_literal: true

require_relative 'lib/active_storage/memory/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_storage-memory'
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

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.test_files = Dir["spec/**/*"]

  spec.add_dependency 'rails', '~> 7.0', '>= 7.0.0'
  spec.add_development_dependency 'rspec-rails', '~> 6.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
