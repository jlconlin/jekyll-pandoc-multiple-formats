# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-pandoc-multiple-formats'
  spec.version       = '1.0.0'
  spec.authors       = %w[fauno]
  spec.email         = %w[fauno@endefensadelsl.org]

  spec.summary       = 'Generates ready to print books, ebooks from a Jekyll site'
  spec.description   = 'Publishes posts as books, ebooks, and many formats supported by Pandoc from a Jekyll site'
  spec.homepage      = "https://0xacab.org/edsl/#{spec.name}"
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata = {
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/-/blob/master/CHANGELOG.md",
    'documentation_uri' => "https://rubydoc.info/gems/#{spec.name}"
  }

  spec.files         = Dir['lib/**/*']
  spec.require_paths = %w[lib]

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE']
  spec.rdoc_options += [
    '--title', "#{spec.name} - #{spec.summary}",
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.add_dependency 'jekyll', '> 4', '< 5'
  spec.add_dependency 'pdf_info', '~> 0.5.0'
  spec.add_dependency 'paru', '~> 0.4.0'

  spec.add_development_dependency 'rake', '~> 13.0.0'
  spec.add_development_dependency 'minitest', '~> 5.15.0'
  spec.add_development_dependency 'shoulda', '~> 4.0.0'
  spec.add_development_dependency 'pry', '~> 0.14.0'
  spec.add_development_dependency 'rubocop', '~> 1.25.0'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.17.0'
end
