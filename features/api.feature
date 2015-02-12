Feature: API
  In order to test applications against stable APIs
  As a developer
  I want to be able to mock http endpoints

  Scenario: Launch a server
    When I execute the following code in a new thread
    """
    Anmo.launch_server
    """
    Then I see an anmo server on port 8787

  Scenario: Launch a server with a port
    When I execute the following code in a new thread
    """
    Anmo.launch_server 9393
    """
    Then I see an anmo server on port 9393

  Scenario: Create a request
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/lollll",
      :body             => "can't think of anything",
      :required_headers => {"meh" => "bleh", "blah" => "blah"}
    })
    """
    And I request the uri "http://localhost:8787/lollll" with the headers
    """
    {
      "meh": "bleh",
      "blah": "blah"
    }
    """
    Then I see the response body "can't think of anything"

  Scenario: Save object
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :body             => "some data"
    })
    """
    And I request the uri "http://localhost:8787/some/object"
    Then I see the response body "some data"

  Scenario: Request only returns object if it has correct query parameters
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/path?monkeys=12",
      :body             => "some data"
    })
    """
    When I request the uri "http://localhost:8787/path?monkeys=12"
    Then I see the response code 200
    And I see the response body "some data"

  Scenario: Save object with http status code
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :status           => 123
    })
    """
    And I request the uri "http://localhost:8787/some/object"
    Then I see the response code 123

  Scenario: Save object with specific method
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :body             => "some data",
      :method           => :put
    })
    """
    And I issue a put request to the uri "http://localhost:8787/some/object"
    Then I see the response body "some data"
    And I issue a get request to the uri "http://localhost:8787/some/object"
    Then I see the response code 404

  Scenario: Request without required headers 404s
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :required_headers => {:meh => "bleh", :durp => "derp"}
    })
    """
    And I request the uri "http://localhost:8787/some/object"
    Then I see the response code 404

  Scenario: Request with required headers
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :body             => "helloow",
      :required_headers => {:meh => "bleh", :durp => "derp"}
    })
    """
    And I request the uri "http://localhost:8787/some/object" with the headers
    """
    {
      "meh": "bleh",
      "durp": "derp"
    }
    """
    Then I see the response body "helloow"
    And I see the response code 200

  Scenario: Delete all saved objects
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :body             => "some data"
    })
    """
    And I execute the code
    """
    Anmo.delete_all
    """
    And I request the uri "http://localhost:8787/some/object"
    Then I see the response code 404

  Scenario: Store all requests
    Given an anmo server
    When I request the uri "http://localhost:8787/some/object"
    Then that request should be stored

  Scenario: Delete all requests
    Given an anmo server
    When I request the uri "http://localhost:8787/some/object"
    And I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.delete_all_requests
    """
    Then there should be no stored requests

  Scenario: List all saved objects
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    Anmo.create_request({
      :path             => "/some/object",
      :body             => "some data"
    })

    @result = Anmo.stored_objects
    """
    Then I should see the value
    """
    [
      {"path" => "/some/object", "body" => "some data"}
    ]
    """

  Scenario: Anmo knows if a server is not running
    When I execute the code
    """
    Anmo.server = "http://localhost:8459"
    @result = Anmo.running?
    """
    Then I see that the anmo server is not running

  Scenario: Anmo knows if a server is running
    Given an anmo server
    When I execute the code
    """
    Anmo.server = "http://localhost:8787"
    @result = Anmo.running?
    """
    Then I see that the anmo server is running

  Scenario: Anmo knows what version the server is running
    Given an anmo server
    When I execute the code
    """
    Anmo.server_version
    """
    Then I see the anmo version
