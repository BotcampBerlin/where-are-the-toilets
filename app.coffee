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

# Send message out via Smooch
sendMsg = (user_id, msg) ->
  jwtHeader =
    header:
      alg: 'HS256'
      typ: 'JWT'
      kid: process.env.JWT_KID
  jwtPayload =
    scope: 'app'
  jwtSecret = process.env.JWT_SECRET

  jwtSig = jwt.sign jwtPayload, jwtSecret, jwtHeader

  options =
    method: 'POST'
    url:    "https://api.smooch.io/v1/appusers/#{user_id}/conversation/messages"
    headers:
      'content-type': 'application/json'
      'authorization': "Bearer #{jwtSig}"
    body: JSON.stringify { text: msg, role: "appMaker" }
  request options, (err, httpResponse, body) ->
    if err then debug err
    #debug httpResponse
    #debug body

# Smooch webhook for appUser messages
app.post '/message', (req, res) ->
  debug req.body

  # test
  user_id = req.body.appUser._id
  user_name = req.body.appUser.givenName

  sendMsg user_id, "Hello #{user_name}"

  res.sendStatus 200

# Smooch webhook for appUser postbacks
app.post '/postback', (req, res) ->
  debug req.body
  res.sendStatus 200

port = process.env.PORT || 3000
srv = http.createServer app
  .listen port, -> debug "Listening on http://*:#{port}"
