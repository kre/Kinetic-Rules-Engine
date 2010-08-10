{
   "dispatch": [
      {"domain": "www.facebook.com"},
      {"domain": "facebook.com"},
      {"domain": "google.com"},
      {"domain": "www.google.com"},
      {"domain": "cnn.com"},
      {"domain": "yahoo.com"},
      {"domain": "youtube.com"},
      {"domain": "craigbryson.com"},
      {"domain": "www.craigbryson.com"},
      {"domain": "nuskin.com"},
      {"domain": "www.unskin.com"},
      {"domain": "bing.com"},
      {"domain": "www.bing.com"},
      {"domain": "lycos.com"},
      {"domain": "www.lycos.com"},
      {"domain": "hulu.com"},
      {"domain": "www.hulu.com"},
      {"domain": "msn.com"},
      {"domain": "www.msn.com"},
      {"domain": "craigslist.org"},
      {"domain": "www.craigslist.org"},
      {"domain": "craigslist.com"},
      {"domain": "www.craigslist.com"},
      {"domain": "amazon.com"},
      {"domain": "speedtest.net"},
      {"domain": "myspace.com"},
      {"domain": "www.myspace.com"},
      {"domain": "weather.com"}
   ],
   "global": [],
   "meta": {
      "author": "Optini LLC",
      "description": "\nThe NuView Network is Part of the craigbryson.com service offering    \n",
      "logging": "off",
      "name": "NuView Network"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#rightCol"
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif(window.OPTINI_WatchSet){ } else {  \tKOBJ.watchDOM(\"#contentArea\",function(){  \t\tdelete KOBJ['a41x53'].pendingClosure;  \t\tKOBJ.reload(1);   \t\twindow.OPTINI_WatchSet = true;  \t});  }            ",
         "foreach": [],
         "name": "facebook_mainpage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msg",
               "rhs": " \n<div id=\"KOBJ_CraigBryson\">    \t\t<div class=\"UIHomeBox UITitledBox\" id=\"KOBJ_CB_Logo\" style=\"margin-bottom: 0px;\">    \t\t\t<div class=\"UITitledBox_Content\" style=\"text-align: center;\">  \t\t\t\t<img src=\"http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x53/image1.jpg\" alt=\"NuView Beta Logo\" />  \t\t\t\t<a href=\"http://www.facebook.com/NuLeadershipNetwork\">  \t\t\t\t\t<img src=\"http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x53/image4.jpg\" alt=\"Become a NuView Fan\" style=\"margin-top: -10px; margin-bottom: 10px;\" />  \t\t\t\t<\/a>  \t\t\t<\/div>  \t\t<\/div>        \t\t<div class=\"UIHomeBox UITitledBox\" id=\"Training_Video\" style=\"text-align: center;\">  \t\t\t<div class=\"UITitledBox_Top\">  \t\t\t\t<div class=\"UITitledBox_TitleBar\">  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\t\t  \t\t<div id=\"CB_CraigFeed\">  \t\t\t<div class=\"UIHomeBox UITitledBox\" id=\"CraigFeedContainer\" style=\"margin-bottom: 0px;\">  \t\t\t\t<div class=\"UITitledBox_Top\">  \t\t\t\t\t<div class=\"UITitledBox_TitleBar\">  \t\t\t\t\t\t<span class=\"UITitledBox_Title\">  \t\t\t\t\t\t\tHighlights  \t\t\t\t\t\t<\/span>  \t\t\t\t\t<\/div>  \t\t\t\t\t<!--<div class=\"UIHomeBox_More\">  \t\t\t\t\t\t<small>  \t\t\t\t\t\t\t<a class=\"UIHomeBox_MoreLink KOBJ_craig_bryson\" href=\"http:\\/\\/www.craigbryson.com/\">  \t\t\t\t\t\t\t\tSee All Posts  \t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t<\/small>  \t\t\t\t\t<\/div>-->  \t\t\t\t<\/div>  \t\t\t\t  \t\t\t\t<div class=\"UITitledBox_Content\">    \t\t\t\t\t\t<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"14\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>                                                            <table id=\"tour_nav\" width=\"249\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\t\t                                                                       <tr>                  \t\t\t\t\t\t<td>                          \t\t\t\t\t\t<a href=\"http://www.youtube.com\"><img src=\"http:\\/\\/www.adliquid.com/static/cb/tour/images/previous.gif\" width=\"83\" height=\"28\" border=\"0\" alt=\"\"><\/a>  \t\t\t\t\t\t\t\t<\/td>                  \t\t\t\t\t\t<td>                          \t\t\t\t\t\t<img src=\"http:\\/\\/www.adliquid.com/static/cb/tour/images/num_5.gif\" width=\"79\" height=\"28\" alt=\"\">  \t\t\t\t\t\t\t\t<\/td>                  \t\t\t\t\t\t<td>                          \t\t\t\t\t\t<a href=\"http://www.google.com\"><img src=\"http:\\/\\/www.adliquid.com/static/cb/tour/images/next.gif\" width=\"87\" height=\"28\" border=\"0\" alt=\"\"><\/a>  \t\t\t\t\t\t\t\t<\/td>          \t\t\t\t\t\t\t<\/tr>          \t\t\t\t\t\t<tr>                  \t\t\t\t\t\t<td colspan=\"3\">                          \t\t\t\t\t\t<a href=\"http://www.craigbryson.com\"><img src=\"http:\\/\\/www.adliquid.com/static/cb/tour/images/cb_site.gif\" width=\"249\" height=\"28\" border=\"0\" alt=\"\"><\/a>  \t\t\t\t\t\t\t\t<\/td>          \t\t\t\t\t\t<\/tr>  \t\t\t\t\t\t<\/table>  \t\t\t\t\t<\/a>  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\t<\/div>  \t<\/div>  \n ",
               "type": "here_doc"
            }
         ],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "absolute"
               },
               {
                  "type": "str",
                  "val": "bottom: 0px"
               },
               {
                  "type": "str",
                  "val": "left: 0px"
               },
               {
                  "type": "var",
                  "val": "kynetx_html_code_info"
               }
            ],
            "modifiers": [
               {
                  "name": "delay",
                  "value": {
                     "type": "num",
                     "val": 0
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "scrollable",
                  "value": {
                     "type": "bool",
                     "val": "false"
                  }
               },
               {
                  "name": "effect",
                  "value": {
                     "type": "str",
                     "val": "blind"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "craigslist_com_float",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.craigslist.org/about/sites.*|.*.craigslist.org",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "r",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "kynetx_html_code_info",
               "rhs": " \n<div id=\"kGrowl\" class=\"kGrowl\" style=\"padding: 10px; z-index: 9999; position: fixed; top: 0px; right: 0px;\">    <div class=\"kGrowl-notification\"/>      <div class=\"kGrowl-notification default\" style=\"padding: 10px; -moz-border-radius-topleft: 5px; -moz-border-radius-topright: 5px; -moz-border-radius-bottomright: 5px; -moz-border-radius-bottomleft: 5px; background-color: rgb(200, 200, 200); color: rgb(255, 255, 255); font-family: Tahoma,Arial,Helvetica,sans-serif; font-size: 12px; margin-bottom: 5px; margin-top: 5px; min-height: 40px; opacity: 1; text-align: left; width: 300px;\">        <div style=\"float: right; font-family: Tahoma,Arial,Helvetica,sans-serif; font-color: white; font-weight: bold; font-size: 12px; cursor: pointer;\"><a onclick=\"$K('#kGrowl').hide();\">X<\/a><\/div>        <div style=\"font-weight: bold; font-size: 13px;\">Message from Craig Bryson<\/div>        <div>          <div id=\"kobj_discount\" style=\"padding: 3pt; -moz-border-radius-topleft: 5px; -moz-border-radius-topright: 5px; -moz-border-radius-bottomright: 5px; -moz-border-radius-bottomleft: 5px; background-color: rgb(255, 255, 255); width: 295; text-align: center;\">            <p style=\"color: rgb(0, 0, 0);\">  <!--            <img src=\"http://media.kickstatic.com/kickapps/images/97525/photos/PHOTO_2858372_97525_5186283_ap_160X120.jpg\"/> -->            <\/p>            <div id=\"optin_ad_#{r}\">  \t\t\t\t\t\t<a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a4a06fc7&amp;cb=#{r}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=33&amp;cb=#{r}&amp;n=a4a06fc7' border='0' alt='' /><\/a>      \t\t\t  <br/>  \t\t\t <\/a>  \t      <\/div>  \t  <br>            <p style=\"text-align: left; color: rgb(100, 100, 100); font-weight: normal\"> We are currently testing this type of message, called a \"float\". We think this message would be helpful to deliver important information to your network, especially on sites like Craiglist, which doesn't have ads.   <br><br>Please send any comments to <a href=\"mailto:support@optini.com\"><strong>support@optini.com.<\/strong><\/a><\/p>          <\/div>        <\/div>     <\/div>  <\/div>  <\/div>  <img src=\"http://api.mixpanel.com/track/?data=eyJldmVudCI6ICJpbXByZXNzaW9uIiwicHJvcGVydGllcyI6IHsidG9rZW4iOiAiMzIzOTY2MTU1ZTc0ZTFkZDZiMWEyYTczOThkZjdjODEifX0=&img=1\">   \n ",
               "type": "here_doc"
            }
         ],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#copy"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "replace_html",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction fetchImgs(){  var fold = $K(window).height() + $K(window).scrollTop() + 50;      $K('p:has(span.p):not(.KimgLoaded)').each(function(){      var t=$K(this);        if(fold <= t.offset().top){        return false;      }        t.addClass('KimgLoaded');      $K.get($K('a',this).attr('href'), function(pic){  \tt.append('<br/>', $K('table[summary] img', pic).attr('height', 70));\t      });  });  }  fetchImgs();  $K(window).scroll(function(){ fetchImgs(); });              ",
         "foreach": [],
         "name": "craigslist_com_fetchimg",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://.*.craigslist.*/.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "r",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<center>  <span id=\"copy\">  <center>  Copyright © 2009 craigslist, inc. - feature's powered by Optini  <\/center>  <left>  <div id=\"optini_bug_#{r}\">  <!--  <iframe id='a2c4f4f4' name='a2c4f4f4' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=15&amp;cb=#{r}' framespacing='0' frameborder='no' scrolling='no'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a8f0e238&amp;cb=#{r}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=15&amp;cb=#{r}&amp;n=a8f0e238' border='0' alt='' /><\/a><\/iframe>  -->  <a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a962ac72&amp;cb=#{r}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=15&amp;cb=#{r}&amp;n=a962ac72' border='0' alt='' /><\/a>  <div>  <!--  <div id=\"optini_vumetrics_#{r}\">  <iframe src=\"http:\\/\\/vue.us.vucdn.com/iframe/craigslist_imgfetch_tracker.html\" weight=\"0\" height=\"0\" frameborder=\"0\"><\/iframe>  <\/div>  <\/left>  -->  <br/>  <\/center>  <img src=\"http://api.mixpanel.com/track/?data=eyJldmVudCI6ICJpbXByZXNzaW9uIiwicHJvcGVydGllcyI6IHsidG9rZW4iOiAiMzIzOTY2MTU1ZTc0ZTFkZDZiMWEyYTczOThkZjdjODEifX0=&img=1\">    \t  \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#addiv"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "replace_html",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "yahoo_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.yahoo.com/.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"6\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#medium_rectangle"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "cnn_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.cnn.com/|http://www.cnn.com/?.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"28\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#nav"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "msn_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.msn.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"29\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#sw_content"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "before",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bing_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.bing.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"30\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#results_area"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bing_com_search_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.bing.com/.*q=.*&.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"31\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#iyt-login-suggest-side-box"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "after",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "youtube_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.youtube.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"32\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#sdb"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "after",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "google_com_search_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id=\"optini_ad\">  <center>  <iframe id='a12a48ad' name='a12a48ad' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?n=a12a48ad&amp;zoneid=35&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='468' height='60' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a5227c57&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=35&amp;cb=#{cb}&amp;n=a5227c57' border='0' alt='' /><\/a><\/iframe>  <script type='text/javascript' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ag.php'><\/script>  <\/center>  <\/div>  <img src=\"http://api.mixpanel.com/track/?data=eyJldmVudCI6ICJpbXByZXNzaW9uIiwicHJvcGVydGllcyI6IHsidG9rZW4iOiAiMzIzOTY2MTU1ZTc0ZTFkZDZiMWEyYTczOThkZjdjODEifX0=&img=1\">  \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "NuVew Test"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "speedtest_net_egg",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.speedtest.net$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<span>This is a Test<\/span><img src=\"http://vumetrics.optini.com/app/piwik.php?idsite=13&cb=#{cb}\" style=\"border:0\" alt=\"\"/>   \n ",
               "type": "here_doc"
            }
         ],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "var",
                  "val": "selector"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "after",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "google_homepage_v2",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "selector",
               "rhs": " \n\"font[size=-1]:first,#footer_about_igoogle_link,#flp\"\n ",
               "type": "here_doc"
            },
            {
               "lhs": "content",
               "rhs": " \n<!---->  <center>  <div id=\"optini_content\" text-align: center; visibility: visible;>  <iframe id='a3a18085' name='a3a18085' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?resize=1&amp;n=a3a18085&amp;campaignid=15&amp;what=campaignid:15/bannerid:26&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='400' height='100' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=afc10e5d&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?campaignid=15&amp;what=campaignid:15/bannerid:26&amp;cb=#{cb}&amp;n=afc10e5d' border='0' alt='' /><\/a><\/iframe>  <script type='text/javascript' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ag.php'><\/script>  <\/div>  <\/center>  <img src=\"http://api.mixpanel.com/track/?data=eyJldmVudCI6ICJpbXByZXNzaW9uIiwicHJvcGVydGllcyI6IHsidG9rZW4iOiAiMzIzOTY2MTU1ZTc0ZTFkZDZiMWEyYTczOThkZjdjODEifX0=&img=1\">  \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#topnav"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "before",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "myspace_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.myspace.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"29\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "var",
                  "val": "selector"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "after",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "mail_google_com",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "mail.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"37\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Message CraigBryson.com"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               },
               {
                  "name": "width",
                  "value": {
                     "type": "num",
                     "val": 260
                  }
               }
            ],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "craiglist_com_float_v2",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.craigslist.org/about/sites.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"33\";    if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>  <div id=\"optini_text>  <left>  <p style=\"text-align: left; color: rgb(0, 0, 0); font-weight: normal\"> We are currently testing this type of message, called a \"float\". We think this message would be helpful to deliver important information to your network, especially on sites like Craiglist, which doesn't have ads.   <br><br>Please send any comments to <a href=\"mailto:support@optini.com\"><strong>support@optini.com.<\/strong><\/a><\/p>  <\/left>  <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#rightCol"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif(window.OPTINI_WatchSet){ } else {  \tKOBJ.watchDOM(\"#contentArea\",function(){  \t\tdelete KOBJ['a41x53'].pendingClosure;  \t\tKOBJ.reload(50);   \t\twindow.OPTINI_WatchSet = true;  \t});  }            ",
         "foreach": [],
         "name": "temp_facebook_youtube",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>  <div id='Optini_Ad'><\/div>  <\/div>    <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"64\";   if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;    if( document.getElementById('Optini_Ad_Content') )  {    }  else  {    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');  }    <\/script>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a41x53"
}
