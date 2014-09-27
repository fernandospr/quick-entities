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
  	post '/tests', {:id => "1", :test => "test"}.to_json, "CONTENT_TYPE" => "application/json"
  	
  	assert_equal 204, last_response.status
  end

  def test_01_create_already_existing_entity
  	post '/tests', {:id => "1", :test => "test"}.to_json, "CONTENT_TYPE" => "application/json"
  	
  	assert_equal 400, last_response.status
  	assert last_response.body.include? "id already exists"
  end

  def test_02_create_entity_without_id
  	post '/tests', {:test => "test"}.to_json, "CONTENT_TYPE" => "application/json"
  	
  	assert_equal 400, last_response.status
  	assert last_response.body.include? "id required"
  end

  def test_03_get_existing_entity
  	get '/tests/1'
 
  	assert_equal 200, last_response.status
  	json = JSON.parse(last_response.body)
	assert_equal "1", json['id']
  end

  def test_04_get_all_entities_contains_existing_entity
  	get '/tests'
  	
  	assert_equal 200, last_response.status
  	json_array = JSON.parse(last_response.body)
  	assert_equal "1", json_array[0]['id']
  end

  def test_05_get_unexisting_entity
  	get '/tests/123'
 
  	assert_equal 404, last_response.status
  end

  def test_06_delete_existing_entity
  	delete '/tests/1'
  	
  	assert_equal 204, last_response.status
  end

  def test_07_delete_unexisting_entity
  	delete '/tests/1'
  	
  	assert_equal 404, last_response.status
  end

end