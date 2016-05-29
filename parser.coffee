# API.AI parser

debug = (require 'debug') 'parser'
apiai = require 'apiai'
request = require 'request'
Smooch = require './smooch'

queryHost = 'https://serene-fortress-65061.herokuapp.com'

app = apiai process.env.APIAI_APP_TOKEN

sendGetRequest = (user_id, url) ->
  debug "GET: #{url}"
  request queryHost + url, (err, response, body) ->
    if err or response.statusCode is not 200
      if err then debug err
      debug response
      return
    body = JSON.parse body
    debug body
    if body.text?
      Smooch.sendMessage user_id, body.text

sendPostRequest = (user_id, url, body) ->
  debug "POST: #{url}"
  options =
    method: 'POST'
    url:    queryHost + url
    headers:
      'content-type': 'application/json'
    body: JSON.stringify body
  request options, (err, response, body) ->
    if err or response.statusCode is not 200
      if err then debug err
      debug response
      return
    debug body
    if body
      body = JSON.parse body
      if body.text?
        Smooch.sendMessage user_id, body.text
    else
      Smooch.sendMessage user_id, "OK, you're checked in."

queryData = (user_id, user_name, argument) ->
  debug argument.action
  switch argument.action
    when 'checkin.stage'
      url = "/check-in/#{user_id}"
      body =
        userName: user_name
        location: argument.parameters.location
      sendPostRequest user_id, url, body
    when 'checkin.band'
      url = "/check-in/#{user_id}"
      body =
        userName: user_name
        band: argument.parameters.band
      sendPostRequest user_id, url, body
    when 'query.bandSchedule'
      url = '/search?eventName=' + argument.parameters.band
      sendGetRequest user_id, url
    when 'query.schedule'
      url = '/timetable'
      sendGetRequest user_id, url
    when 'query.daySchedule'
      url = '/search?eventTime=' + argument.parameters.time
      sendGetRequest user_id, url
    #when 'query.upcomingScheduleForLocation'
      # TODO
    #when 'query.dayScheduleForLocation'
      # TODO
    when 'query.userLocation'
      url = '/check-ins?username=' + argument.parameters.username
      sendGetRequest user_id, url
    when 'query.groupLocations'
      url = '/check-ins'
      sendGetRequest user_id, url
    when 'query.location'
      url = '/search?location=' + argument.parameters.location
      sendGetRequest user_id, url
    when 'reportProblem'
      Smooch.sendMessage user_id, 'Do you want to report a problem? Yes/No'
      # if yes, apologize and log it
      # Smooch.sendMessage user_id,  'We\'re sorry and will try to fix this asap!'
      fs.appendFile 'reports.log', argument.resolvedQuery + '\n'
    when 'help'
      Smooch.sendMessage user_id, 'Do you want to report a problem or contact the support staff?'
    else
      Smooch.sendMessage user_id, 'We\'re sorry we couldn\'t understand your request.\nDo you want to report a problem or contact the support staff?'

module.exports =
  parseMessage: (user_id, user_name, msg) ->
    req = app.textRequest msg
    req.on 'response', (response) ->
      debug response
      if response.result.actionIncomplete
        debug 'Prompt: ' + response.result.fulfillment.speech
      else
        queryData user_id, user_name, response.result

    req.on 'error', (error) ->
      debug error

    req.end()
