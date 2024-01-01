# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'spec_selector'
  spec.author = 'Trevor Almon'
  spec.files = Dir['{lib}/**/*'] + %w[license.md]
  spec.version = '0.2.0'
  spec.summary = 'A results viewer and filter utility for RSpec'
  spec.email = 'trevoralmon@gmail.com'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/TrevorA-TrevorA/spec_selector'
  spec.description = <<-DESC
  SpecSelector is an RSpec formatter that opens a utility
  menu in your terminal window when you run tests (rather
  than just printing static text). The utility allows you to
  select, view, filter, and rerun specific test results with
  simple key controls.
  DESC
  spec.required_ruby_version = '>= 2.5'
  spec.cert_chain = [File.expand_path('gem-public_cert.pem')]
  spec.signing_key = File.expand_path('~/.ssh/spec_selector/gem-private_key.pem') if $PROGRAM_NAME =~ /gem\z/
  spec.metadata = {
    'source_code_uri' => 'https://github.com/TrevorA-TrevorA/spec_selector',
    'homepage_uri' => 'https://github.com/TrevorA-TrevorA/spec_selector',
    'changelog_uri' => 'https://github.com/TrevorA-TrevorA/spec_selector/blob/master/CHANGELOG.md'
  }
end
