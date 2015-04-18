ENV['RACK_ENV'] = 'test'

require './app.rb'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_00_create_entity
  	post '/tests', {:id => "1", :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
  	
  	assert_equal 204, last_response.status
  end

  def test_01_create_already_existing_entity
  	post '/tests', {:id => "1", :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
  	
  	assert_bad_request_already_exists(last_response)
  end

  def test_02_create_already_existing_entity_using_number_id
    post '/tests', {:id => 1, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    
    assert_bad_request_already_exists(last_response)
  end

  def assert_bad_request_already_exists (last_response)
    assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "id_already_exists", json['id']
  end

  def test_03_create_entity_without_id
  	post '/tests', {:test => "test"}.to_json, "CONTENT_TYPE" => "application/json"
  	
  	assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "id_required", json['id']
  end

  def test_04_get_existing_entity
  	get '/tests/1'
 
  	assert_equal 200, last_response.status
  	json = JSON.parse(last_response.body)
	  assert_equal "1", json['id']
  end

  def test_05_get_all_entities_contains_existing_entity
  	get '/tests'
  	
  	assert_equal 200, last_response.status
  	json_array = JSON.parse(last_response.body)
  	assert_equal "1", json_array[0]['id']
  end

  def test_06_get_unexisting_entity
  	get '/tests/123'
 
  	assert_equal 404, last_response.status
  end

  def test_07_delete_existing_entity
  	delete '/tests/1'
  	
  	assert_equal 204, last_response.status
  end

  def test_08_delete_unexisting_entity
  	delete '/tests/1'
  	
  	assert_equal 404, last_response.status
  end

  def test_09_create_entity_using_number_id
    post '/tests', {:id => 2, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 204, last_response.status

    get '/tests/2'
    assert_equal 200, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "2", json['id']

    delete '/tests/2'
    assert_equal 204, last_response.status
  end

  def test_10_update_entity
    post '/tests', {:id => 3, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 204, last_response.status
    
    put '/tests/3', {:id => 3, :test => "updated-test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 204, last_response.status

    get '/tests/3'
    assert_equal 200, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "3", json['id']
    assert_equal "updated-test", json['test']

    delete '/tests/3'
    assert_equal 204, last_response.status
  end

  def test_11_create_entity_with_invalid_entities_name
    post '/system.test', {:id => 3, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 400, last_response.status
  end

end