require 'rspec'

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start
end

require_relative File.join(%w(.. lib picobot))
