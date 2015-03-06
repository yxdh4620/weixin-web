debuglog = require("debug")("weixin-web:controller:animations")

# 给 router 用的，用于找到对应的要处理的对象
exports.home = (req, res, next)->
  console.dir req
  res.json
    params: req.params
    query: req.query
    body: req.body

