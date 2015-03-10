debuglog = require("debug")("weixin-web:controller:weixins")
{redis} = require '../utils/redis_db'
httpUtil = require "../utils/http_utils"
weixinUtil = require('../utils/weixin_util')

AUTHORIXZE_URL = null
wxt = null
domainName = ""

_sendError = (res, err) ->
  res.json
    succuse: false
    message: err
  return

_loadAccessToken = (callback) ->
  wxt.loadAccessToken (err, access_token) ->

_loadUserInfo = (openid, callback) ->
  redis.hgetall "weixin_userinfo::#{openid}", callback

_redirectIndex = (res, userinfo) ->
  timestamp = httpUtil.generateTimestamp()
  userinfo.timestamp = timestamp
  userinfoStr = httpUtil.xxteaEncryptObj(userinfo)
  res.redirect "/index?timestamp=#{timestamp}&u=#{userinfoStr}"


exports.init = (weixinTools, options) ->
  console.log "weixins init."
  AUTHORIXZE_URL = options.authorizeUrl
  domainName = options.domainName
  wxt = weixinTools
  return

# 给 router 用的，用于找到对应的要处理的对象
exports.home = (req, res, next)->
  console.log "authorizeUrl:#{AUTHORIXZE_URL}"
  authorizeUrl = wxt.generateAuthorizeURL(AUTHORIXZE_URL, "", 'snsapi_base')
  res.redirect authorizeUrl


exports.login = (req, res, next) ->
  {code} = req.query||{}
  wxt.loadAuthorzeToken  code,(err, authorizeToken) ->
    return _sendError res, err if err?
    return _sendError res, new Error('authorizeToken is null') unless authorizeToken? and authorizeToken.openid?
    if authorizeToken.scope == 'snsapi_userinfo'
      wxt.loadUserInfo authorizeToken.openid, authorizeToken.access_token, "zh-CN", (err, userinfo) ->
        return _sendError res, err if err?
        return _sendError res, new Error("not find userinfo") unless userinfo
        redis.hmset "weixin_userinfo::#{authorizeToken.openid}", userinfo, (err) ->
          req.session.userinfo = userinfo
          _redirectIndex res, userinfo
          return
        return
      return
    # 去redis中找
    _loadUserInfo authorizeToken.openid, (err, userinfo) ->
      if not err? and userinfo?
        req.session.userinfo = userinfo
        _redirectIndex res, userinfo
        return
      authorizeUrl = wxt.generateAuthorizeURL(AUTHORIXZE_URL, "", 'snsapi_userinfo')
      res.redirect authorizeUrl

exports.index = (req, res, next) ->
  url = "http://#{domainName}#{req.originalUrl}"
  userStr = req.query.u||""
  console.log "userStr:  #{userStr}"
  weixinUtil.generateConfig url, (err, config) ->
    return _sendError res, err if err?
    res.render "index2",
      config: config
      userStr: userStr
    return
  return


