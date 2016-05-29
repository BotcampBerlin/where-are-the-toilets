debug = (require 'debug') 'app'
express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
path = require 'path'
http = require 'http'
Wit = require './wit'

app = express()
#app.set 'view engine', 'pug'
#app.set 'views', path.join(__dirname, '../views')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })
app.use cookieParser()
app.use express.static(path.join(__dirname, '../public'))



# Smooch webhook for appUser messages
app.post '/message', (req, res) ->
  debug req.body

  user_id = req.body.appUser._id
  user_name = req.body.appUser.givenName
  msg = req.body.messages[0].text;

  Wit.parseMessage user_id, user_name, msg
  res.sendStatus 200

# Smooch webhook for appUser postbacks
app.post '/postback', (req, res) ->
  debug req.body
  res.sendStatus 200

port = process.env.PORT || 3000
srv = http.createServer app
  .listen port, -> debug "Listening on http://*:#{port}"
