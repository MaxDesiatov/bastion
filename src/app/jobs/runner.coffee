# cli colors
colors = require 'colors'
git = require './git'
server = require './server'
exec = require('child_process').exec
jobs = require '../models/jobs'
fs = require 'fs'

parseSequence = (input) ->
  length = input.length
  return cmd: input[length - 1], args: input.substring 2, length - 1

tokenize = (input, result = []) ->
  return [''] if input == ''

  input.replace /(\u001B\[.*?([@-~]))|([^\u001B]+)/g, (m) ->
    result.push m[0] == '\u001B' and parseSequence(m) or m

  return result


COLORS =
  0: '', 1: 'bold', 4: 'underscore', 5: 'blink',
  30: 'fg-black', 31: 'fg-red', 32: 'fg-green', 33: 'fg-yellow',
  34: 'fg-blue', 35: 'fg-magenta', 36: 'fg-cyan', 37: 'fg-white'
  40: 'bg-black', 41: 'bg-red', 42: 'bg-green', 43: 'bg-yellow',
  44: 'bg-blue', 45: 'bg-magenta', 46: 'bg-cyan', 47: 'bg-white'

html = (input) ->
  result = input.map (v) ->
    if typeof v == 'string'
      return v
    else if v.cmd == 'm'
      cls = v.args.split(';').map((v) -> COLORS[parseInt v]).join(' ')
      # FIXME: add support for colours
      # return "</span><span class=\"#{cls}\">"
      return ''
    else
      return ''

  return "#{result.join('')}"


runner = module.exports =
    build: ->
        runNextJob()

runNextJob = ->
  return false if jobs.current?
  jobs.next ->
    git.pull ->
      runTask (success) ->
        jobs.currentComplete success, ->
          runNextJob()

runTask = (next) ->
  str = "Executing '#{git.runner}'"
  logDiff = service: {}
  logDiff.service[new Date().getTime()] = str
  jobs.updateLog jobs.current, logDiff, ->
    exec git.runner, maxBuffer: 1024*1024, (error, stdout, stderr) ->
      if error?
        updateLog error, true, ->
            updateLog stdout, true, ->
                updateLog stderr, true, ->
                  fs.exists git.failure, (exists) ->
                    if exists
                      runFile git.failure, next, false
                    else
                      next false
      else
        updateLog stdout, false, ->
          fs.exists git.success, (exists) ->
            if exists
              runFile git.success, next, true
            else
              next true

runFile = (file, next, args=null) ->
  str = "Executing #{file}"
  logDiff = service: {}
  logDiff.service[new Date().getTime()] = str
  jobs.updateLog jobs.current, logDiff, ->
    console.log str.grey
    exec file, (error, stdout, stderr) ->
      if error?
        updateLog error, true, ->
          updateLog stdout, true, ->
            updateLog stderr, true, ->
                next(args)
      else
        updateLog stdout, true, ->
          next(args)

updateLog = (buffer, isError, done) ->
  content = html tokenize buffer.toString()
  logDiff = {}
  if isError
      logDiff.error = {}
      logDiff.error[new Date().getTime()] = content
      console.log "#{content}".red
  else
      logDiff.output = {}
      logDiff.output[new Date().getTime()] = content
      console.log content
  jobs.updateLog jobs.current, logDiff, done
