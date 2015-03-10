
wx.ready () ->
  #jsApiList = config.jsApiList
  #wx.checkJsApi
  #  jsApiList:jsApiList
  #  success: (res)->
  #    alert(JSON.stringify(res))

  shareData =
      title: '微信JS-SDK Demo'
      desc: '微信JS-SDK,帮助第三方为用户提供更优质的移动web服务',
      link: 'http://demo.open.weixin.qq.com/jssdk/',
      imgUrl: 'http://mmbiz.qpic.cn/mmbiz/icTdbqWNOwNRt8Qia4lv7k3M9J1SKqKCImxJCt7j9rHYicKDI45jRPBxdzdyREWnk0ia0N5TMnMfth7SdxtzMvVgXg/0'
  wx.onMenuShareAppMessage(shareData)
  wx.onMenuShareTimeline(shareData)


wx.error (res) ->
  alert(res.errMsg)

