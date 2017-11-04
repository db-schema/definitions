lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_schema/definitions/version'

Gem::Specification.new do |spec|
  spec.name          = 'db_schema-definitions'
  spec.version       = DbSchema::Definitions::VERSION
  spec.authors       = ['Vsevolod Romashov']
  spec.email         = ['7@7vn.ru']

  spec.summary       = 'Database object definitions for DbSchema'
  spec.homepage      = 'https://github.com/db-schema/definitions'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r(^spec/)) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r(^exe/)) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'awesome_print', '~> 1.7'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'terminal-notifier'
  spec.add_development_dependency 'terminal-notifier-guard'
end
