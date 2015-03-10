
wx.ready () ->
  #jsApiList = config.jsApiList
  #wx.checkJsApi
  #  jsApiList:jsApiList
  #  success: (res)->
  #    alert(JSON.stringify(res))

  shareData =
      title: 'Gama 游戏·'
      desc: '为 Gama Labs， Gama 引擎， Gama SDK 的客户提供快捷方便的客户服务。'
      link: 'http://weixin.gamagama.cn'
      imgUrl: 'https://mp.weixin.qq.com/misc/getheadimg?token=1540123482&fakeid=3076364027&r=613427'

  wx.onMenuShareAppMessage(shareData)
  wx.onMenuShareTimeline(shareData)
  wx.onMenuShareQQ(shareData)
  wx.onMenuShareWeibo(shareData)

wx.error (res) ->
  alert(res.errMsg)

