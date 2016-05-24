# Libmspack

This is Ruby wrapper for [libmspack](http://www.cabextract.org.uk/libmspack/) library.

Compressing and decompressing some loosely related Microsoft compression formats, CAB, CHM, HLP, LIT, KWAJ and SZDD.


## Installation

Add this line to your application's Gemfile:

    gem 'libmspack'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libmspack

### Dependencies

gems:

* `ffi` (required)
* `ffi-compiler2` (required for compiling libmspack)

## Usage

```ruby
require 'libmspack'

decompressor = LibMsPack::CabDecompressor.new
cab = decompressor.search('data.cab')
puts cab.files.filename
decompressor.close(cab)
decompressor.destroy
```


## Code status

[![Build Status](https://travis-ci.org/davispuh/ruby-libmspack.png?branch=master)](https://travis-ci.org/davispuh/ruby-libmspack)
[![Dependency Status](https://gemnasium.com/davispuh/ruby-libmspack.png)](https://gemnasium.com/davispuh/ruby-libmspack)
[![Code Climate](https://codeclimate.com/github/davispuh/ruby-libmspack.png)](https://codeclimate.com/github/davispuh/ruby-libmspack)


## Unlicense

![Copyright-Free](http://unlicense.org/pd-icon.png)

All text, documentation, code and files in this repository are in public domain (including this text, README).

It means you can copy, modify, distribute and include in your own work/code, even for commercial purposes, all without asking permission.

[About Unlicense](http://unlicense.org/)
 
### BUT

libmspack library itself is licensed with the [GNU LGPL](http://www.gnu.org/licenses/lgpl.txt)
 
## Contributing

Feel free to improve anything.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


**Warning**: By sending pull request to this repository you dedicate any and all copyright interest in pull request (code files and all other) to the public domain. (files will be in public domain even if pull request doesn't get merged)

Also before sending pull request you acknowledge that you own all copyrights or have authorization to dedicate them to public domain.

If you don't want to dedicate code to public domain or if you're not allowed to (eg. you don't own required copyrights) then DON'T send pull request.
