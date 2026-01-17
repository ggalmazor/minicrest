# frozen_string_literal: true

require_relative 'lib/minicrest/version'

Gem::Specification.new do |spec|
  spec.name = 'minicrest'
  spec.version = Minicrest::VERSION
  spec.authors = ['Guillermo Gutierrez Almazor']
  spec.email = ['guillermo@ggalmazor.com']

  spec.summary = 'Hamcrest-style composable matchers for Minitest'
  spec.description = <<~DESC
    Minicrest provides Hamcrest-style composable matchers for Minitest with
    expressive, readable assertions and detailed failure messages. Matchers
    can be combined using logical operators to create complex matching conditions.
  DESC
  spec.homepage = 'https://github.com/ggalmazor/minicrest'
  spec.license = 'AGPL-3.0-only'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .idea docs/])
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'minitest', '~> 5.0'
end
