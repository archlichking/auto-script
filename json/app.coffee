express = require 'express'
routes = require './routes'
stylus = require 'stylus'
fs = require 'fs'

run_config = JSON.parse fs.readFileSync(__dirname + "/config.json") 

app = module.exports = express.createServer()

# Configuration

app.configure ()->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.static(__dirname + '/public')
  app.use stylus.middleware({src:__dirname + '/public'})
  app.use app.router

app.configure 'development', ()->
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure 'production', ()->
  app.use express.errorHandler()

# Routers

app.get '/config', (req, res)->
  res.send run_config

app.listen 3000

console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
