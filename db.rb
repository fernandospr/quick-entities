if ENV['MONGOHQ_URL']
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
else
  DB = Mongo::Connection.new.db("test")
end

def create_entity (coll, json)
  json['id'] = json['id'].to_s
  coll.save(json)
end

def find_by_id (coll, id)
  coll.find( {'id' => id.to_s}, { fields: {_id:0} } ).to_a[0]
end

def drop_collection_if_empty (coll)
  if (coll.count == 0)
    coll.drop
  end
end

def filter_db_collection_names (collection_names)
  collection_names.delete_if{ |collection_name| is_db_collection_name(collection_name) }
end

def is_db_collection_name (collection_name)
  collection_name.strip.start_with?("system.")
end

def filter_non_user_collection_names (collection_names, user)
  if (!user.to_s.empty?)
    collection_names.delete_if{ |collection_name| !is_user_collection_name_with_user(collection_name, user) }
  end
end

def is_user_collection_name_with_user (collection_name, user)
  collection_name.strip.start_with?("user." + user)
end