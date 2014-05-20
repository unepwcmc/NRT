# Server

## app.coffee

Application entry point. Includes required modules and starts the server

## route_bindings.coffee

Binds the server paths (e.g. '/indicators/') to the controllers in the controllers folder

## controllers/

Contains the 'actions' in the application, grouped into modules by their
responsibility. These are mapped to paths by route_bindings.coffee

## models/

Mongoose schemas, and model instantiation.

# Client

A [BackboneDiorama](https://github.com/th3james/BackboneDiorama/) application
