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
  	post '/tests', {:id => "1", :test => "test", :value => 8, :example => "15"}.to_json, "CONTENT-TYPE" => "application/json"
  	
  	assert_equal 200, last_response.status
  end

  def test_01_create_already_existing_entity
  	post '/tests', {:id => "1", :test => "test", :value => 8, :example => "15"}.to_json, "CONTENT-TYPE" => "application/json"
  	
  	assert_bad_request_already_exists(last_response)
  end

  def test_02_create_already_existing_entity_using_number_id
    post '/tests', {:id => 1, :test => "test", :value => 8, :example => "15"}.to_json, "CONTENT-TYPE" => "application/json"
    
    assert_bad_request_already_exists(last_response)
  end

  def test_03_create_entity_without_id
  	post '/tests', {:test => "test", :value => 8, :example => "15"}.to_json, "CONTENT_TYPE" => "application/json"
  	
  	assert_equal 200, last_response.status
    json = JSON.parse(last_response.body)
    assert_not_nil json['id']

    delete '/tests/' + json['id']
  end

  def test_04_get_existing_entity
  	get '/tests/1'
 
  	assert_equal 200, last_response.status
  	json = JSON.parse(last_response.body)
	  assert_equal "1", json['id']
  end

  def test_05_filter_existing_entities
    get '/tests?test=test'
    
    assert_equal 200, last_response.status
    json_array = JSON.parse(last_response.body)
    assert json_array.length > 0
  end

  def test_06_filter_unexisting_entities_1
    get '/tests?unexisting_field=value'
    
    assert_equal 200, last_response.status
    json_array = JSON.parse(last_response.body)
    assert_equal 0, json_array.length
  end

  def test_07_filter_unexisting_entities_2
    get '/tests?test=anotherTest'
    
    assert_equal 200, last_response.status
    json_array = JSON.parse(last_response.body)
    assert_equal 0, json_array.length
  end

  def test_08_filter_existing_entities_by_number_1
    get '/tests?value=8'
    
    assert_equal 200, last_response.status
    json_array = JSON.parse(last_response.body)
    assert json_array.length > 0
  end

  def test_09_filter_existing_entities_by_number_2
    get '/tests?value=10'
    
    assert_equal 200, last_response.status
    json_array = JSON.parse(last_response.body)
    assert_equal 0, json_array.length
  end

  def test_10_filter_existing_entities_by_number_3
    get '/tests?example=15'
    
    assert_equal 200, last_response.status
    json_array = JSON.parse(last_response.body)
    assert json_array.length > 0
  end

  def test_11_get_all_entities_contains_existing_entity
  	get '/tests'
  	
  	assert_equal 200, last_response.status
  	json_array = JSON.parse(last_response.body)
  	assert_equal "1", json_array[0]['id']
  end

  def test_12_get_unexisting_entity
  	get '/tests/123'
 
  	assert_equal 404, last_response.status
  end

  def test_13_delete_existing_entity
  	delete '/tests/1'
  	
  	assert_equal 204, last_response.status
  end

  def test_14_delete_unexisting_entity
  	delete '/tests/1'
  	
  	assert_equal 404, last_response.status
  end

  def test_15_create_entity_using_number_id
    post '/tests', {:id => 2, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 200, last_response.status

    get '/tests/2'
    assert_equal 200, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "2", json['id']

    delete '/tests/2'
    assert_equal 204, last_response.status
  end

  def test_16_update_entity
    post '/tests', {:id => 3, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 200, last_response.status
    
    put '/tests/3', {:id => 3, :test => "updated-test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 200, last_response.status

    get '/tests/3'
    assert_equal 200, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "3", json['id']
    assert_equal "updated-test", json['test']

    delete '/tests/3'
    assert_equal 204, last_response.status
  end

  def test_17_update_entity_with_id_of_existing_entity
    post '/tests', {:id => 1, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 200, last_response.status
    
    post '/tests', {:id => 2, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 200, last_response.status

    put '/tests/2', {:id => 1, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 400, last_response.status

    delete '/tests/1'
    assert_equal 204, last_response.status

    delete '/tests/2'
    assert_equal 204, last_response.status
  end

  def test_18_create_entity_with_invalid_entities_name
    post '/system.test', {:id => 3, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 400, last_response.status
  end

  def test_19_no_internal_collections
    get '/'
 
    assert_equal 200, last_response.status
    json = JSON.parse(last_response.body)
    assert !json.any? {|collection| collection.strip.start_with?("system.")}, "Should not return internal collections"
  end

  def test_20_patch_entity
    post '/tests', {:id => 1, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"

    patch 'tests/1', {:name => "test-name"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_equal 200, last_response.status

    get '/tests/1'
    json = JSON.parse(last_response.body)
    assert_equal "1", json['id']
    assert_equal "test", json['test']
    assert_equal "test-name", json['name']

    delete '/tests/1'
  end

  def test_21_patch_entity_with_id_of_existing_entity
    post '/tests', {:id => 1, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    post '/tests', {:id => 2, :test => "test"}.to_json, "CONTENT-TYPE" => "application/json"
    
    patch 'tests/1', {:id => 2, :name => "test-name"}.to_json, "CONTENT-TYPE" => "application/json"
    assert_bad_request_already_exists(last_response)

    delete '/tests/1'
    delete '/tests/2'
  end

  # Helpers
  def assert_bad_request_already_exists (last_response)
    assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "id_already_exists", json['id']
  end

end