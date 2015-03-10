###
# 系统的总路由
# author:YuanXiangDong
# date: 2015-02-27
###

debuglog = require("debug")("gama-assets-reup::config::routes")

module.exports = (app, wxt, config) ->
  weixinOptions = config.weixin || {}
  weixinOptions.domainName = config.domainName
  controller = require '../controllers/weixins'
  controller.init(wxt, weixinOptions)
  app.route("/").get controller.home
  app.route("/login").get controller.login
  app.route("/index").get controller.index

  app.use (err, req, res, next) ->
    return next() if (not err?) or (err.name is "NotFoundError") or (~err.message.indexOf('not found'))
    debuglog "ERROR: #{err}"
    res.status(500).render('500', {error: err.stack})
    return

  app.use (req, res, next) ->
    res.status(404).render('404', {url:req.originalUrl, error:'not found'})


