###
# http 相关工具类
###
debuglog = require("debug")("weixin-web:utils:http_utils")
xxtea = require "xxtea"
xxteaKey = null

 # 生成一个时间戳（单位：秒）
exports.generateTimestamp = () ->
  return parseInt(Date.now()/1000)

exports.init =(options) ->
  xxteaKey = options.xxteaKey || ''

exports.xxteaEncryptObj = (obj) ->
  return xxtea.encrypt(JSON.stringify(obj), xxteaKey)

exports.xxteaDecryptObj = (str) ->
  str = xxtea.decrypt(str,key)
  try
    return JSON.parse(str)
  catch err
    debuglog "ERROR: #{err}"
    return {}

