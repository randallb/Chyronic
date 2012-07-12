net = require "net"

connected = undefined
client = new net.Socket()

expectations = []
nextExpectId = 0

client.on "error", (err) ->
  console.log err

client.on 'data', (data) ->
  # should be an event that this emits.
  console.log "chyron: #{data.toString()}"



raw = (command) ->
  client.write(command + "\\\\\r\n")
  console.log "sending: #{command}"

expect = (string, callback) ->
  expectId = nextExpectId
  nextExpectId++

  expectations[expectId]


exports.connect = (ip, callback) ->
  console.log "connecting to Chyron at #{ip}"
  client.connect 23, ip, ->
    console.log "connected."
    client.on "data", (data) ->
      console.log data.toString()


exports.raw = raw

exports.readMessage = (message) ->
  raw "V\\5\\3\\1\\0\\#{message}\\0"

exports.writeTemplateMessage = (source, destination, templateDataArray) ->
  templateData = ""
  for item in templateDataArray
    templateData += "\\#{item}"
  raw "W\\#{destination}\\#{source}#{templateData}"

counter = 1
exports.continuousUpdate = () ->
  raw "U\\@Election\\N\\Candidate 1 Text\\5\\R\\D\\#{counter}"
  raw "U\\@Election\\N\\Candidate 2 Text\\9\\R\\D\\#{counter}"
  counter++
  setTimeout exports.continuousUpdate, 1

exports.playCanvasToAir = () ->
  raw "V\\6\\1\\1"

exports.updateOnAirMessage = (message, templateDataArray, buffer) ->
  buffer ?= 1
  templateData = ""
  for item in templateDataArray
    templateData += "\\#{item}"
  raw "V\\5\\13\\1\\#{buffer}\\#{message}\\1#{templateData}"

exports.disconnect = () ->
  # todo

exports.connected = connected
