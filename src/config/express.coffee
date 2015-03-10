###
# 系统的express配置
# author: YuanXiangDong
# date: 2015-02-27
###

express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'
timeout = require "connect-timeout"
morgan = require 'morgan'
session = require 'express-session'
compress = require 'compress'

path = require "path"
#view_helper = require "../utils/view_helper"
debuglog = require("debug")("weixin-web::config::express")

module.exports = (app, config) ->

  app.set('showStackError', true)

  app.use express.static("#{config.root}/public")

  app.use timeout(60*60*1000)

  if process.env.NODE_ENV isnt 'text'
    app.use morgan('dev')

  app.set 'views', path.join(config.root, '/views')
  app.set 'view engine', 'jade'
  app.set 'view options', {pretty:false}

  app.use cookieParser(config.app.cookieSecret)

  app.use bodyParser({limit:'99mb'})
  app.use methodOverride()

  app.use session({
    secret: config.app.sessionSecret
    key: config.app.cookieSecret
  })

  app.use (req, res, next) ->
    next()
    return

  app.locals.VERSION = config.version
  app.locals.APP_NAME = config.app.name
  app.locals.TIMESTAMP = Date.now().toString(36)

