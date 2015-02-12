require "anmo/version"
require "anmo/application"
require "thin"
require "httparty"
require "json"

module Anmo
  def self.server
    @server ||= "http://localhost:#{@port}"
  end

  class << self
    attr_writer :server
  end

  def self.server_version
    HTTParty.get(anmo_url("__VERSION__")).body
  end

  def self.launch_server(port = 8787)
    @port = port
    Thin::Server.start("0.0.0.0", port, Anmo::Application.new)
  end

  def self.create_request(options)
    HTTParty.post(anmo_url("__CREATE_OBJECT__"), :body => options.to_json, :headers => { "Content-Type" => "application/json" })
  end

  def self.delete_all
    HTTParty.post(anmo_url("__DELETE_ALL_OBJECTS__"))
  end

  def self.requests
    json = HTTParty.get(anmo_url("__REQUESTS__"))
    JSON.parse(json.body)
  end

  def self.delete_all_requests
    HTTParty.post(anmo_url("__DELETE_ALL_REQUESTS__"))
  end

  def self.stored_objects
    json = HTTParty.get(anmo_url("__OBJECTS__"))
    JSON.parse(json.body)
  end

  def self.running?
    HTTParty.get(anmo_url("__ALIVE__")).code == 200 rescue false
  end

  private

  def self.anmo_url(path)
    "#{server}/#{path}"
    # URI.join(server, path).to_s
  end
end
