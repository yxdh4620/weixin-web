###
# admin-site 项目主程序
# author:YuanXiangDong
# date: 2015-02-27
###


fs = require "fs"
path = require "path"
p = require 'commander'
express = require "express"
_ = require 'underscore'
debuglog = require("debug")("weixin-web::server")

pkg = JSON.parse(fs.readFileSync(path.join(__dirname, "../package.json")))

## 更新外部配置
p.version(pkg.version)
  .option('-e, --environment [type]', 'runtime environment of [development, production, testing]', 'development')
  .option('-p, --port [value]', 'runtime port ', '7789')
  .parse(process.argv)

console.dir p

###
# bootstrap config
###
env = p.environment || 'development'
port = p.port || 7789
c = require('./config/config')
console.dir c
config = require('./config/config')[env]
console.dir config
config.port = port
config.version = pkg.version
config.root = path.resolve __dirname, "../"


###
# express settings
###
app = express()
require("./config/express")(app, config)

###
# bootstrap routes
###
require("./config/routes")(app)


unless env is 'development'
  process.on 'uncaughtException', (error) -> mailer.deliverServerException(error)

###
# start the app by listening on port
###
app.listen port
console.log "weixin-web web started on port:#{port}, env:#{env}"

exports = module.exports = app


