#!/usr/bin/ruby

require 'pathname'
require(Pathname.new(__dir__) + "../app/app.rb")

LiaisonApplication.execute
