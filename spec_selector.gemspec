Gem::Specification.new do |spec|
  spec.name = 'spec_selector'
  spec.author = 'Trevor Almon'
  spec.files = Dir['{lib,spec}/**/*'] + %w[README.md license.md]
  spec.version = '0.1.0'
  spec.summary = 'A results viewer and filter utility for RSpec'
  spec.email = 'trevoralmon@gmail.com'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/TrevorA-TrevorA/spec_selector'
  spec.description = <<-DESC
  SpecSelector is an RSpec formatter than opens a utility menu 
  in your terminal window when you run tests (rather than just 
  printing static text). The utility allows you to select, view, 
  filter, and rerun specific test results with simple key controls.
  DESC
  spec.metadata = {
    'source_code_uri' => 'https://github.com/TrevorA-TrevorA/spec_selector',
    'homepage_uri' => 'https://github.com/TrevorA-TrevorA/spec_selector'
  }
end