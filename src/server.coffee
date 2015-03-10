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
WeixinTools = require("weixin-tools")
debuglog = require("debug")("weixin-web::server")

pkg = JSON.parse(fs.readFileSync(path.join(__dirname, "../package.json")))

## 更新外部配置
p.version(pkg.version)
  .option('-e, --environment [type]', 'runtime environment of [development, production, testing]', 'development')
  .option('-p, --port [value]', 'runtime port ', '7789')
  .parse(process.argv)


###
# bootstrap config
###
env = p.environment || 'development'
port = p.port || 7789
c = require('./config/config')
config = require('./config/config')[env]
config.port = port
config.version = pkg.version
config.root = path.resolve __dirname, "../"


start=(config)->
  require('./utils/redis_db').init config,()->
    options = config.weixin || {}
    wxt = new WeixinTools(options.appid, options.secret, options.jsapiList, true)
    require("./utils/weixin_util").init(wxt)
    ###
    # express settings
    ###
    app = express()
    require("./config/express")(app, config)
    ###
    # bootstrap routes
    ###
    require("./config/routes")(app, wxt, config)
    #unless env is 'development'
    #  process.on 'uncaughtException', (error) -> mailer.deliverServerException(error)

    ###
    # start the app by listening on port
    ###
    app.listen port
    console.log "weixin-web web started on port:#{port}, env:#{env}"

start(config)


