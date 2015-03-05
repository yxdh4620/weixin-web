###
# 系统的总路由
# author:YuanXiangDong
# date: 2015-02-27
###

debuglog = require("debug")("gama-assets-reup::config::routes")

module.exports = (app) ->

  controller = require '../controllers/weixins'
  app.route("/").get controller.home

  app.use (err, req, res, next) ->
    return next() if (not err?) or (err.name is "NotFoundError") or (~err.message.indexOf('not found'))
    res.status(500).render('500', {error: err.stack})
    return

  app.use (req, res, next) ->
    res.status(404).render('404', {url:req.originalUrl, error:'not found'})


