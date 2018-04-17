uristring = ENV['QUICK_ENTITIES_MONGODB_URI'] || 'mongodb://localhost:27017/test'
client = Mongo::Client.new(uristring)
DB = client.database

def create_entity (coll, json)
  json['id'] = json['id'].to_s
  coll.insert_one(json)
end

def find_by_id (coll, id)
  coll.find( {'id' => id.to_s}, { 'projection' => { '_id': 0 } } ).to_a[0]
end

def drop_collection_if_empty (coll)
  if (coll.count == 0)
    coll.drop
  end
end

def delete_db_collection_names (collection_names)
  collection_names.delete_if{ |collection_name| is_db_collection_name(collection_name) }
end

def is_db_collection_name (collection_name)
  collection_name.strip.start_with?("system.")
end