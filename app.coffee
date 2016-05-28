debug = (require 'debug') 'app'
express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
path = require 'path'
http = require 'http'
request = require 'request'
jwt = require 'jsonwebtoken'

app = express()
#app.set 'view engine', 'pug'
#app.set 'views', path.join(__dirname, '../views')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: false })
app.use cookieParser()
app.use express.static(path.join(__dirname, '../public'))

sendMsg = (user_id, msg) ->
  jwtHeader =
    header:
      alg: 'HS256'
      typ: 'JWT'
      kid: 'app_5749c5c01ce6035c00bb09cb'
  jwtPayload =
    scope: 'app'
  jwtSecret = 'A3QkWUbW5vmB9PR5m2iYyPcS'

  jwt = jwt.sign jwtPayload, jwtSecret, jwtHeader

  options =
    method: 'POST'
    url:    "https://api.smooch.io/v1/appusers/#{user_id}/conversation/messages"
    headers:
      'content-type': 'application/json'
      'authorization': "Bearer #{jwt}"
    body: JSON.stringify { text: msg, role: "appMaker" }
  request options, (err, httpResponse, body) ->
    if err then debug err
    debug httpResponse
    debug body

# the actual POST webhook handler
app.post '/webhook', (req, res) ->
  debug req.body

  # test
  user_id = req.body.appUser._id
  user_name = req.body.appUser.givenName

  sendMsg user_id, "Hello #{user_name}"

  res.sendStatus 200

port = process.env.PORT || 3000
srv = http.createServer app
  .listen port, -> debug "Listening on http://*:#{port}"
