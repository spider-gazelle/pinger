require "spec"
require "../src/pinger"

def travis_guard(description, &block)
  if ENV["TRAVIS"]?
    pending(description) { block.call }
  else
    it(description) { block.call }
  end
end
