#连接redis的工具，不要将redis的数据暴露出去,因为大部分的模型 都使用nohm来处理了。

_ = require "underscore"
debuglog = require("debug")("weixin-web::utils::redis_db")


_redis = null

RANDOM_NAME_KEY="auto_random_name"

module.exports =

  init:(env, callback)->
    debuglog "[redis_db::init] start. REDIS_PORT:#{env.REDIS_PORT} REDIS_HOST:#{env.REDIS_HOST}"
    #_redis = require("redis").createClient env.REDIS_PORT, env.REDIS_HOST ,{detect_buffers:true}
    _redis = require("redis").createClient env.REDIS_PORT, env.REDIS_HOST
    _redis.select(env.SELECT||1)

    _redis.debug_mode = env.DEBUG

    _redis.on "error",  (error) ->
      debuglog "[db.on_error] #{error}"

    _redis.on "end", ->
      debuglog "[db.on_end]"

    _redis.on "ready", ->
      debuglog  "[db] redis client is ready to server."
      callback() if _.isFunction callback

    _redis.on "reconnecting", (info) ->
      debuglog "[db] redis client is reconnecting to datastore... delay:#{info.delay}, attempt:#{info.attempt}"

    @.redis=_redis



