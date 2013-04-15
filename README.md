# Rms

Connect and Operate Rakuten RMS.

This Library is Mecahanize extentions.

## Installation

Add this line to your application's Gemfile:

    gem 'rms'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rms

## Usage

require 'rubygems'

require "rms"

auth = ["first_auth_uid" , "first_auth_pwd" ,"second_auth_uid" ,"second_auth_pwd"]

session = Rms::Connection.new(*auth)

session.open


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
