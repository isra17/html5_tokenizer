Gem::Specification.new do |s|
  s.name    = "html5-tokenizer"
  s.version = "0.0.1"
  s.summary = "Ruby bind for Hubbub's tokenizer"
  s.author  = "Israel Halle <isra017@gmail.com>"

  s.files = Dir.glob("ext/**/*.{c,rb}") +
            Dir.glob("lib/**/*.rb")

  s.extensions << "ext/html5_tokenizer/extconf.rb"

  s.add_development_dependency "rake-compiler"
end

