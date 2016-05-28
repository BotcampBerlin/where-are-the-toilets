express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
path = require 'path'
http = require 'http'
debug = (require 'debug') 'app'

app = express()
#app.set 'view engine', 'pug'
#app.set 'views', path.join(__dirname, '../views')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })
app.use cookieParser()
app.use express.static(path.join(__dirname, '../public'))

# the actual POST webhook handler
app.post '/webhook', (req, res) ->
  debug req.body
  res.send 200

port = process.env.PORT || 3000
srv = http.createServer app
  .listen port, -> debug "Listening on http://*:#{port}"

