Gem::Specification.new do |spec|
  spec.name = 'spec_selector'
  spec.author = 'Trevor Almon'
  spec.files = Dir['{lib,spec}/**/*'] + %w[README.md license.md]
  spec.version = '1.0.0'
  spec.summary = 'A results viewer and filter utility for RSpec'
  spec.email = 'trevoralmon@gmail.com'
  spec.license = 'MIT'
  spec.description = <<-DESC
  SpecSelector is an RSpec formatter that opens a utility menu in your 
  terminal window. The menu displays the example results 
  tree as a list, and allows you to navigate, select, view, filter, and rerun 
  example results with simple key controls. For instance, simply press T to view 
  to the top failed test result. Press F to rerun RSpec with only the tests that failed.
  DESC
  spec.metadata = {
    'source_code_uri' => 'https://github.com/TrevorA-TrevorA/spec_selector'
  }
end