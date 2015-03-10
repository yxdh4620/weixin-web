###
# 微信的工具类
# author: YuanXiangDong
# date: 2015-03-03
###

debuglog = require("debug")("weixin-web:utils:weixin_util")
crypto = require 'crypto'
_ = require 'underscore'
request = require 'request'
assert = require "assert"
{redis} = require '../utils/redis_db'

WXT = null

# 缓存与redis中得微信票据的数据的key
REDIS_WEIXIN_KEYS =
  access_token:"weixin_access_token"
  jsapi_ticket:"weixin_jsapi_ticket"


# 读取redis中指定key得微信票据数据
_loadCacheTicket = (key, callback) ->
  redis.get key, (err, value) ->
    if err?
      debuglog "[weixin_util::_loadCacheTicket] error:#{err}"
      return callback err
    return callback null, value
  return

# 将制定key 的微信票据缓存redis， 缓存时间seconds
_cacheTicket = (key, seconds, value, callback) ->
  #console.log "key:#{key} seconds:#{seconds} value:#{value}"
  redis.setex key, seconds, value, (err) ->
    debuglog "[weixin_util::_cacheTicket] error#{err}" if err?
    callback err
    return
  return


init = (wxt) ->
  debuglog "LOG [weixin_util::init] start"
  WXT = wxt

# 获得微信的access_token
getAccessToken = (callback) ->
  _loadCacheTicket REDIS_WEIXIN_KEYS.access_token, (err, result) ->
    return callback null, result if not err and result?
    WXT.loadAccessToken (err, result) ->
      return callback err if err?
      seconds = parseInt(result.expires_in) - 600
      _cacheTicket REDIS_WEIXIN_KEYS.access_token, seconds, result.access_token, (err) ->
        return callback err if err?
        return callback(null, result.access_token)
      return
    return
  return

#获得微信的jsapi_ticket
getJsapiTicket = (callback) ->
  _loadCacheTicket REDIS_WEIXIN_KEYS.jsapi_ticket, (err, result) =>
    return callback null, result if not err and result?
    getAccessToken (err, access_token) ->
      return callback err if err?
      WXT.loadJsapiTicket access_token,(err, result) =>
        return callback err if err?
        return callback new Error("result data is error") if _.isEmpty(result)
        seconds = parseInt(result.expires_in) - 600
        _cacheTicket REDIS_WEIXIN_KEYS.jsapi_ticket, seconds, result.ticket, (err) =>
          return callback err if err?
          return callback(null, result.ticket)
        return
      return
    return
  return

# 获得微信的config
generateConfig = (url, callback) ->
  getJsapiTicket (err, jsapi_ticket) ->
    return callback err if err?
    config = WXT.generateConfig url, jsapi_ticket
    config.debug = true
    callback null, config

module.exports =
  init: init
  getAccessToken: getAccessToken
  getJsapiTicket: getJsapiTicket
  generateConfig: generateConfig



