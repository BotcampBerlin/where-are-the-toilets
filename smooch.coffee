debug = (require 'debug') 'smooch'
request = require 'request'
jwt = require 'jsonwebtoken'

module.exports = Smooch =
  # Send message out via Smooch
  sendMessage: (user_id, msg) ->
    debug "sendMessage '#{msg}' to #{user_id}"
    jwtHeader =
      header:
        alg: 'HS256'
        typ: 'JWT'
        kid: process.env.JWT_KID
    jwtPayload =
      scope: 'app'
    jwtSecret = process.env.JWT_SECRET

    jwtSig = jwt.sign jwtPayload, jwtSecret, jwtHeader

    #debug jwtSig

    options =
      method: 'POST'
      url:    "https://api.smooch.io/v1/appusers/#{user_id}/conversation/messages"
      headers:
        'content-type': 'application/json'
        'authorization': "Bearer #{jwtSig}"
      body: JSON.stringify {
        text: msg
        role: "appMaker"
      }
    request options, (err, httpResponse, body) ->
      if err then debug err
