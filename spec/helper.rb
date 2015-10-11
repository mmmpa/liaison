require 'pathname'

Dir[
  Pathname.new("#{__dir__}") + '../app/app.rb',
  Pathname.new("#{__dir__}") + './supports/**/*.rb'
].each(&method(:require))

Logger.work!

