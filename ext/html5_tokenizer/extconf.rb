require 'mkmf'
require 'pry'

find_executable('make')

vendors_dir = File.join($srcdir, '../../vendor')
vendors = ['libhubbub', 'libparserutils']
vendors.each do |vendor|
  vendor_dir = File.join(vendors_dir, vendor)
  target = File.join(vendor_dir, "#{vendor}.a")
  Dir.chdir(vendor_dir) do
    `make`
  end
  `cp #{target} .`
end

find_header('parserutils/parserutils.h', File.join(vendors_dir, 'libparserutils/include'))
find_header('hubbub/hubbub.h', File.join(vendors_dir, 'libhubbub/include'))

have_library('hubbub')
have_library('parserutils')

have_library('iconv')

extension_name = 'html5_tokenizer'
dir_config(extension_name)
create_makefile(extension_name)

