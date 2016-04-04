<a href='https://pledgie.com/campaigns/26743'><img alt='Click here to lend your support to: Fernando&#x27;s Open Source Projects and make a donation at pledgie.com !' src='https://pledgie.com/campaigns/26743.png?skin_name=chrome' border='0' ></a>

quick-entities
==============

Quick-Entities is a simple implementation of services to create, read, update and delete any kind of entity.

It exposes REST services and saves the entities in a Mongo database.

A working example is deployed on Heroku: http://quick-entities.herokuapp.com/.

## Quick Setup

* Install <a href="https://www.ruby-lang.org/en/documentation/installation/">Ruby</a>, <a href="http://www.sinatrarb.com/">Sinatra</a> and <a href="http://docs.mongodb.org/manual/installation/">MongoDB</a>.

* <a href="http://docs.mongodb.org/manual/tutorial/install-mongodb-on-os-x/#run-mongodb">Run MongoDB</a>.

* Run the application: 
```
$ bundle install
$ ruby app.rb (or ruby app.rb -o 0.0.0.0 if you need to allow access from the network)
```

## Usage

###Post an entity

Execute a POST request to http://localhost:4567/fruits with the following JSON body:
```
{
	"id":"1",
	"name": "Apple",
	"color": "red"
}
```

Note: if you do not provide the id, an id will be generated for you.

###Get the entities

Execute a GET request to http://localhost:4567/fruits

###Filter the entities by an attribute

Execute a GET request to http://localhost:4567/fruits?color=red

###Get one specific entity

Execute a GET request to http://localhost:4567/fruits/1

###Update an entity

Execute a PUT request to http://localhost:4567/fruits/1 with the following JSON body:
```
{
	"id":"1",
	"name": "Orange",
	"color": "orange"
}
```

###Patch an entity

Execute a PATCH request to http://localhost:4567/fruits/1 with the following JSON body:
```
{
	"quantity": 10
}
```

###Delete the entity

Execute a DELETE request to http://localhost:4567/fruits/1

###Get all the collections

Execute a GET request to http://localhost:4567
