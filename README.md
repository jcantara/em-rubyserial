# DEPRECATED - Em::Rubyserial

Deprecating this project because I have not maintained it in a long time, and do not have the time or need to do so any longer.

EventMachine serial port functionality that should work on all* ruby flavors (including MRI, jruby; and various operating systems including linux, windows, and apple)

(* for some values of all)

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

[![Build Status](https://travis-ci.org/jcantara/em-rubyserial.svg?branch=master)](https://travis-ci.org/jcantara/em-rubyserial)

Uses the following gem for serial port connectivity:
https://github.com/hybridgroup/rubyserial

Essentially copies this gem:
https://github.com/railsbob/em-serialport

but replaces the serialport gem with the rubyserial gem, and does some file descriptor handling.

There is currently as of this writing no license on the em-serialport gem, so hopefully this amount of attribution is satisfactory. 

[CHANGELOG](https://github.com/jcantara/em-rubyserial/blob/master/CHANGELOG.md)

## Installation

Add this line to your application's Gemfile:

    gem 'em-rubyserial'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install em-rubyserial

## Usage

    EM.run do
      serial = EventMachine.open_serial('/dev/ttyS2', 9600, 8)
      serial.send_data "foo"

      serial.on_data do |data|
        puts data
      end
    end

## Contributing

1. Fork it ( https://github.com/jcantara/em-rubyserial/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
