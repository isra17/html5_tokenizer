require 'html5_tokenizer'
require 'benchmark'

begin
  require 'nokogiri'
  skip_nokogiri = false
rescue LoadError
  skip_nokogiri = true
end

html = File.read('./benchmark.html')

TIMES = 10.times

class UrlScanner < Html5Tokenizer::Scanner
  attr_accessor :urls
  def initialize(*args)
    super(*args)
    self.urls = []
  end

  def handle_start_tag(tag)
    if tag.name == 'img'
      _, src = tag.attributes.find {|k,v| k.downcase == 'src'}
      self.urls << src unless src.nil?
    end
  end
end

def bench_scanner(html)
  TIMES.each do
    scanner = UrlScanner.new(html)
    scanner.run
    scanner.urls
  end
end

def bench_tokenizer(html)
  TIMES.each do
    tokenizer = Html5Tokenizer::Tokenizer.new
    tokenizer.insert(html)
    tokenizer.eof
    tokenizer.run {|t|}
  end
end

def bench_nokogiri(html)
  TIMES.each do
    urls = []
    doc = Nokogiri::HTML.fragment(html)
    doc.css('img').each do |tag|
      urls << tag.attributes['src'].value
    end
    urls
  end
end

def bench_rewriter(html)
  TIMES.each do
    rewriter = Html5Tokenizer::Rewriter.new(html)
    rewriter.rewrite
  end
end

def bench_to_html(html)
  TIMES.each do
    doc = Nokogiri::HTML.fragment(html)
    doc.to_html
  end
end

Benchmark.bmbm do |b|
  b.report('scanner') { bench_scanner(html) }
  b.report('tokenizer') { bench_tokenizer(html) }
  b.report('nokogiri') { bench_nokogiri(html) } unless skip_nokogiri
end

Benchmark.bmbm do |b|
  b.report('rewriter') { bench_rewriter(html) }
  b.report('to_html') { bench_to_html(html) } unless skip_nokogiri
end
