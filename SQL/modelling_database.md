Look into [Objection.js](https://vincit.github.io/objection.js/) and [Knex js](http://knexjs.org/) for ORM capabilities in Javascript  
Look into entity relationship diagram and how to build those

## [Model a SQL Database](https://www.youtube.com/watch?v=JNagbi_QvIU)

Entity - the description of some thing in your database  
Record - is a single instance of an entity

Every Record will have:
* CreatedAt - datetime  
* UpdatedAt - datetime
* DeletedAt - datetime
* Archived - boolean  
The archived means that the row will not be explicitly deleted, we will still keep the record and the archived boolean value will be true, and the date when deleted query was run will be kept in the DeletedAt column - Soft deletes

Numeric primary keys are the most easiest and performant databases around. It is built into the SQL databases. In order to prevent the primary keys to be easily guessable we could use a __uuid__. __Id keys__ that increment in predictable way give lot of advantages for efficient indexing, sharding etc, and makes paging results easy

Best practice to actually have a separate date table to use as a primary key and then a date is used as a foreign key on every other table with itemdate, userdate, etc intermediary tables.

