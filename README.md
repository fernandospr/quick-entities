<a href='https://pledgie.com/campaigns/26743'><img alt='Click here to lend your support to: Fernando&#x27;s Open Source Projects and make a donation at pledgie.com !' src='https://pledgie.com/campaigns/26743.png?skin_name=chrome' border='0' ></a>

quick-entities
==============

Quick-Entities is a simple implementation of services to create, read, update and delete any kind of entity.


## Quick Setup

* Install Ruby, Sinatra and Mongo.

* Start mongo.

* Run the application: 
```
$ ruby app.rb
```

## Usage

###Post an entity

Execute a POST request to http://localhost:4567/fruits with the following JSON body:
```
{
	"id":1,
	"name": "Apple"
}
```

###Get the entities

Execute a GET request to http://localhost:4567/fruits

###Get one specific entity

Execute a GET request to http://localhost:4567/fruits/1

###Update an entity

Not yet implemented!

###Delete the entity

Execute a DELETE request to http://localhost:4567/fruits/1

###Get all the collections

Execute a GET request to http://localhost:4567
