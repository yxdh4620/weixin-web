debuglog = require("debug")("weixin-web:controller:weixins")
{redis} = require '../utils/redis_db'
#WeixinTools = require("weixin-tools")
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
  console.log authorizeUrl
  res.redirect authorizeUrl


exports.login = (req, res, next) ->
  {code} = req.query||{}
  wxt.loadAuthorzeToken  code,(err, authorizeToken) ->
    return _sendError res, err if err?
    return _sendError res, new Error('authorizeToken is null') unless authorizeToken? and authorizeToken.openid?
    tokenKey = "weixin_au_token::#{authorizeToken.openid}"
    if authorizeToken.scope == 'snsapi_userinfo'
      wxt.loadUserInfo authorizeToken.openid, authorizeToken.access_token, "zh-CN", (err, userinfo) ->
        console.dir userinfo
        return _sendError res, err if err?
        return _sendError res, new Error("not find userinfo") unless userinfo
        redis.hmset "weixin_userinfo::#{authorizeToken.openid}", userinfo, (err) ->
          #res.json
          #  succuse:true
          #  results:userinfo
          #req.userinfo = userinfo
          req.session.userinfo = userinfo
          res.redirect "/index"
          return
        return
      return
    # 去redis中找
    _loadUserInfo authorizeToken.openid, (err, userinfo) ->
      if not err? and userinfo?
        #res.json
        #  succuse:true
        #  results:userinfo
        #req.userinfo = userinfo
        req.session.userinfo = userinfo
        res.redirect "/index"
        return
      authorizeUrl = wxt.generateAuthorizeURL(AUTHORIXZE_URL, "", 'snsapi_userinfo')
      res.redirect authorizeUrl

exports.index = (req, res, next) ->
  userinfo = req.session.userinfo || {}
  console.dir req
  url = "http://#{domainName}#{req.originalUrl}"
  weixinUtil.generateConfig url, (err, config) ->
    return _sendError res, err if err?
    console.dir config
    res.render "index2",
      config: config
    return
  return


