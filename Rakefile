require 'rake/extensiontask'
require 'rake/testtask'

Rake::TestTask.new

spec = Gem::Specification.load('html5-tokenizer.gemspec')
Rake::ExtensionTask.new('html5_tokenizer', spec) do |ext|
  ext.lib_dir = "lib/html5_tokenizer"
end

