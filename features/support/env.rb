require "rack"
require "rack/test"
require "httparty"

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../../lib")))
require "anmo"
require "anmo/application"

World(Rack::Test::Methods)

def app
  Anmo::Application.new
end
