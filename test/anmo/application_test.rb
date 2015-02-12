require "minitest/pride"
require "minitest/autorun"
require "minitest/unit"
require "rack/test"
require "json"
require File.expand_path(File.join(File.dirname(__FILE__), "../../lib/anmo/application"))

module Anmo
  class ApplicationTest < MiniTest::Unit::TestCase
    include Rack::Test::Methods

    def app
      Application.new
    end

    def setup
      ApplicationDataStore.clear_objects
      ApplicationDataStore.clear_requests
    end

    def save_object(path, body, status, required_headers, method)
      options = {
        :path             => path,
        :body             => body,
        :status           => status,
        :required_headers => required_headers
      }
      options[:method] = method if method

      put "__CREATE_OBJECT__", options.to_json
    end

    def test_404s_if_object_does_not_exist
      get "/bla/bla/bla.json"
      assert_equal "Not Found", last_response.body
      assert last_response.not_found?
    end

    def test_stores_mock_data
      save_object "/this/is/the/path.object", "please save this", nil, nil, nil
      assert_equal 201, last_response.status

      get "/this/is/the/path.object"
      assert_equal "please save this", last_response.body
      assert last_response.ok?
    end

    def test_does_not_return_object_if_request_has_different_query_parameters
      save_object "/path/?hello=true", "please save this", nil, nil, nil
      get "/path/?hello=false"
      assert_equal 404, last_response.status
      assert_equal "Not Found", last_response.body
    end

    def test_returns_object_if_request_has_same_query_parameters
      save_object "/?hello=true&bla=bla", "please save this", nil, nil, nil
      get "/?hello=true&bla=bla"
      assert_equal 200, last_response.status
      assert_equal "please save this", last_response.body
    end

    def test_returns_object_if_request_has_query_parameters_in_different_order
      save_object "/?aaa=aaa&bbb=bbb", "please save this", nil, nil, nil
      get "/?bbb=bbb&aaa=aaa"
      assert_equal 200, last_response.status
      assert_equal "please save this", last_response.body
    end

    def test_stores_status_code
      save_object "/monkeys", nil, 123, nil, nil
      get "/monkeys"
      assert_equal 123, last_response.status
    end

    def test_similar_query_string
      save_object "/pulsar/assets?channel=foo.bar.baz.qux.quux.1", "Something", 200, nil, :get
      save_object "/pulsar/assets?channel=foo.bar.baz.qux.quux.2", "Something else", 200, nil, :get

      get "/pulsar/assets?channel=foo.bar.baz.qux.quux.1"

      assert_equal 200, last_response.status
    end

    def test_allows_deleting_all_objects
      save_object "/this/is/the/path.object", "please save this", nil, nil, nil

      get "/this/is/the/path.object"
      first_response = last_response

      post "__DELETE_ALL_OBJECTS__"
      assert_equal 200, last_response.status

      get "/this/is/the/path.object"
      second_response = last_response

      assert_equal "please save this", first_response.body
      assert_equal "Not Found", second_response.body
      assert_equal 404, second_response.status
    end

    def test_404s_if_request_does_not_have_required_headers
      save_object "/oh/hai", nil, nil, { "ruby" => "hipsters", "meh" => "bleh" }, nil
      get "/oh/hai"
      assert_equal 404, last_response.status
    end

    def test_returns_value_if_request_has_required_headers
      save_object "/oh/hai", "the content", nil, { "lol-ruby" => "hipsters", "meh" => "bleh" }, nil
      header "lol-ruby", "hipsters"
      header "meh", "bleh"
      get "/oh/hai"
      assert_equal 200, last_response.status
      assert_equal "the content", last_response.body
    end

    def test_404s_if_request_does_not_have_correct_method
      save_object "/meh", "content", nil, nil, :delete
      get "/meh"
      assert_equal 404, last_response.status
    end

    def test_returns_vaue_if_request_has_correct_method
      save_object "/meh", "content", nil, nil, :delete
      delete "/meh"
      assert_equal 200, last_response.status
    end

    def test_returns_the_last_added_object_first
      save_object "/oh/hai", "the first content", nil, nil, nil
      save_object "/oh/hai", "the second content", nil, nil, nil
      get "/oh/hai"
      assert_equal "the second content", last_response.body
    end

    def test_stores_all_requests
      get "/hello"
      get "/hai"
      get "/__REQUESTS__"
      json = JSON.parse(last_response.body)

      assert_equal 2, json.size
      assert_equal "/hello", json.first["PATH_INFO"]
      assert_equal "/hai", json.last["PATH_INFO"]
    end

    def test_does_not_store_create_or_delete_requests
      save_object "/oh/hai", "the first content", nil, nil, nil
      post "__DELETE_ALL_OBJECTS__"
      get "/__REQUESTS__"
      json = JSON.parse(last_response.body)
      assert_equal 0, json.size
    end

    def test_returns_requests_as_json
      get "/hello"
      get "/__REQUESTS__"
      json = JSON.parse(last_response.body)
      assert_equal 1, json.size
      assert_equal "/hello", json.first["PATH_INFO"]
    end

    def test_deletes_all_requests
      get "/hello"
      get "/__REQUESTS__"
      json = JSON.parse(last_response.body)
      assert_equal 1, json.size
      post "/__DELETE_ALL_REQUESTS__"
      get "/__REQUESTS__"
      json = JSON.parse(last_response.body)
      assert_equal 0, json.size
    end

    def test_returns_empty_list_of_stored_objects
      get "/__OBJECTS__"
      json = JSON.parse(last_response.body)
      assert_equal "application/json", last_response.content_type
      assert_equal 0, json.size
    end

    def test_lists_stored_objects
      save_object "/some/path", nil, nil, nil, nil

      get "/__OBJECTS__"

      json = JSON.parse(last_response.body)
      assert_equal 1, json.size
      assert_equal "/some/path", json.first["path"]
    end

    def test_shows_that_its_alive
      get "/__ALIVE__"
      assert last_response.ok?
      assert_equal "<h1>anmo is alive</h1>", last_response.body
    end

    def test_exposes_server_version
      get "/__VERSION__"
      assert_equal Anmo::VERSION, last_response.body
    end
  end
end
