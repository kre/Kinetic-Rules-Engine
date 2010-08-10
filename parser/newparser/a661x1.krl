{
   "dispatch": [
      {"domain": "bing.com"},
      {"domain": "cnn.com"},
      {"domain": "google.com"},
      {"domain": "facebook.com"},
      {"domain": "assembla.com"},
      {"domain": "amazon.com"},
      {"domain": "comf5.com"},
      {"domain": "nuskin.com"},
      {"domain": "fandango.com"}
   ],
   "global": [],
   "meta": {
      "author": "Taylor",
      "description": "\nThis app is for Training purposes \n\n",
      "logging": "off",
      "name": "Taylor's App"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#needing-help-panel"
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
         "name": "ComF5_dl",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*www.fandango.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": "\n                  \n<div id =\"optini\" align=\"center\">\n              <image  src=\"http://vue.us.vucdn.com/x282/www/delivery/ai.php?filename=optini_message.png&contenttype=png\" />\n<p><\/P>\n   <a class = \"Download\" href = \"http://vu.optini.com/craigbryson\">\n              <image  alt = \"Download\" src = \"http://vue.us.vucdn.com/x282/www/delivery/ai.php?filename=optini_install_button.png&contenttype=png\">\n            <\/a>\n<\/div>\n\n      }\n      float(\"absolute\", \"top:10px\", \"right:10px\", \"http://vue.us.vucdn.com/x282/www/delivery/ai.php?filename=optini_message.png&contenttype=png\")\n    }\n//\n//\n//\n rule assembla_final is active {\n    select using \"www.assembla.com/.*\" setting ( )\n    pre {\n            cb = math:random(999999999999);\n            content = << \n<div id = 'optini_logo'> <div id = 'Optini_Ad' align = \"center\"> <iframe width='300' height='250' frameborder='2' src='http://spreadsheets.google.com/pub?key=0Al-3kI_mZ0Z6dEl4YVNVOGpuOTE0ZnhvRGcxWUU1c0E&output=html&widget=true'><\/iframe><br><br><\/div>\n ",
            "type": "here_doc"
         }],
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
         "name": "bing_searchresults",
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
               "rhs": " \n<div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"191\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>    \n ",
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
         "name": "cnn_homepage",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"192\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>    <\/div>        \n ",
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {    \tKOBJ.watchDOM(\"#rso\",function(){            var app = KOBJ.get_application(\"a661x1\");            app.reload();     \t\twindow.OPTINI_WatchSet = true;    \t});    }                ",
         "foreach": [],
         "name": "facebook_member_homepage",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad'><\/div>    <\/div>        <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"193\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;        if( document.getElementById('Optini_Ad_Content') )    {        }    else    {      jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    }        <\/script>        \n ",
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
                  "val": "#pagelet_connectbox"
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {    \tKOBJ.watchDOM(\"#rso\",function(){            var app = KOBJ.get_application(\"a661x1\");            app.reload();     \t\twindow.OPTINI_WatchSet = true;    \t});    }                ",
         "foreach": [],
         "name": "facebook_Connect",
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
               "rhs": " \n              <div id=\"Optini\">\n                <div class=\"hp_connect_box\">\n                  <div class=\"uiHeader uiHeaderBottomBorder mbm pbs\">\n                    <div class=\"clearfix uiHeaderTop\">\n                      <div class=\"uiTextSubtitle uiHeaderActions rfloat\">\n                      <\/div>\n                      <div><h4 class=\"uiHeaderTitle\">Get Connected With Taylor<\/h4>\n                      <\/div>\n                    <\/div>\n                  <\/div>\n                  <div class=\"UIImageBlock clearfix mbs\">\n                    <i class=\"\">\n                    <\/i>\n                    <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">\n                      <div>\n                      \n                      What's New With Taylor Scott?\n                      \n                      <\/div>\n                      \n                      <a href=\"http://www.facebook.com/\">Text Him!<\/a>\n                      \n                      <\/div>\n                    <\/div>\n                    <div class=\"UIImageBlock clearfix mbs\">\n                    <i class=\"\">\n                    <\/i>\n                    <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">\n                      <div>\n                      \n                      Have You Seen Nuskin's New Products?\n                      \n                      <\/div>\n                      \n                      <a href=\"http://www.nuskin.com/en_US/home.html\">Shop Now!<\/a>\n                      \n                      <\/div>\n                    <\/div>\n                    <div class=\"UIImageBlock clearfix mbs\">\n                      <i class=\"\">\n                      <\/i>\n                      <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">\n                        <div>\n                        \n                        Stay in touch with NSE dreams?\n                        \n                        <\/div>\n                        \n                        <a href=\"https://www.nsedreams.com/pwp/wac/webaccount/hostingLogin.jsp?textCacheLocale=en_US\">Go Now!<\/a>\n                        \n                      <\/div>\n                    <\/div>\n                    <div class=\"UIImageBlock clearfix mbs\">\n                      <i class=\"\">\n                      <\/i>\n                      <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">                         \n                        <div>\n                        \n                        Build Your Business\n                        \n                        <\/div>\n                        \n                        <a href=\"http://www.nuskin.com/en_US/opportunity/roadmap_to_success.html\">Nuskin Will Guide You<\/a> \n                        \n                      <\/div>\n                    <\/div>\n                  <\/div>\n                <\/div>\n              <\/div>\n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction zap() {      try {        $K(\"#pagelet_ads\").replaceWith(\"\");      } catch(e) {}      try {        $K(\"#pagelet_adbox\").replaceWith(\"\");      } catch(e) {}      try {        $K(\"#sidebar_ads\").replaceWith(\"\");      } catch(e) {}          }         function sweeper() {      setTimeout(\"zap()\",4000);       }         function pageChange() {      zap();      sweeper();       }          KOBJ.watchDOM(\"#content\",pageChange);    KOBJ.watchDOM(\"#menubar_container\",pageChange);    KOBJ.watchDOM(\"#pagefooter\",pageChange);    KOBJ.watchDOM(\"#pagelet_presence\",pageChange);          zap();    sweeper();                          ",
         "foreach": [],
         "name": "facebook_houdini",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com",
            "type": "prim_event",
            "vars": []
         }},
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
         "emit": "\nfunction fetchImgs(){\nvar fold = $K(window).height() + $K(window).scrollTop() + 50;\n\n\n$K('p:has(span.p):not(.KimgLoaded)').each(function(){\n    var t=$K(this);\n\n    if(fold <= t.offset().top){\n      return false;\n    }\n\n    t.addClass('KimgLoaded');\n    $K.get($K('a',this).attr('href'), function(pic){\n\tt.append('<br/>', $K('table[summary] img', pic).attr('height', 70));\t\n    });\n});\n}\nfetchImgs();\n$K(window).scroll(function(){ fetchImgs(); });\n        ",
         "foreach": [],
         "name": "craigslist_fetching",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://facebook.com",
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
               "rhs": " \n<center>\n<span id=\"copy\">\n<center>\nCopyright © 2009 craigslist, inc. - feature's powered by Austin\n<\/center>\n<left>\n<div id=\"optini_bug_#{r}\">\n<!--\n<iframe id='a2c4f4f4' name='a2c4f4f4' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=15&amp;cb=#{r}' framespacing='0' frameborder='no' scrolling='no'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a8f0e238&amp;cb=#{r}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=15&amp;cb=#{r}&amp;n=a8f0e238' border='0' alt='' /><\/a><\/iframe>\n-->\n<a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a962ac72&amp;cb=#{r}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=15&amp;cb=#{r}&amp;n=a962ac72' border='0' alt='' /><\/a>\n<div>\n<!--\n<div id=\"optini_vumetrics_#{r}\">\n<iframe src=\"http:\\/\\/vue.us.vucdn.com/iframe/craigslist_imgfetch_tracker.html\" weight=\"0\" height=\"0\" frameborder=\"0\"><\/iframe>\n<\/div>\n<\/left>\n-->\n<br/>\n<\/center>\n<img src=\"http://api.mixpanel.com/track/?data=eyJldmVudCI6ICJpbXByZXNzaW9uIiwicHJvcGVydGllcyI6IHsidG9rZW4iOiAiMzIzOTY2MTU1ZTc0ZTFkZDZiMWEyYTczOThkZjdjODEifX0=&img=1\">\n\n\t  \n ",
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
                  "val": "#center"
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
         "name": "amazon_home",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.amazon.com/s/ref=.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": "\n           <div id='optini_Ad' align=\"center\"><a href=\"http://www.facebook.com\">\"Welcome To Rainbow\"<\/a><\/div>\n          ",
            "type": "here_doc"
         }],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#rso"
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
         "name": "annotate_google_search",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*google.com.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": "\n        <li class=\"g\"><h3 class=\"r\"><a onmousedown=\"return rwt(this,'','','','1','AFQjCNHUqFN1kGCkCOuybEnuDd-R6sANYA','','0CCcQFjAA')\" class=\"l\" href=\"http://www.facebook.com/\"><em>Taylor Scott<\/em><\/a><\/h3><div class=\"s\">Introducing <em>Taylor Scott<\/em>, The Handsomest Man in all of town.  You should give him a call at (801)-425-5498.  He enjoys long walks on the beach and an occasion milkshake peow peow!!! (yes, <b>...<\/b><br><span class=\"f\"><cite>www.facebook.com/<\/cite> - <span class=\"gl\"><a onmousedown=\"return rwt(this,'','','','1','AFQjCNF7rr2FQtEbIt1p8FLNF80PWBQ_Mg','','0CCkQIDAA')\" href=\"http://webcache.googleusercontent.com/search?q=cache:r_PPd7ZrQmwJ:www.baconsalt.com/+bacon+salt&amp;cd=1&amp;hl=en&amp;ct=clnk&amp;gl=us\">Cached<\/a> - <a href=\"/search?hl=en&amp;q=related:www.baconsalt.com/+bacon+salt&amp;tbo=1&amp;sa=X&amp;ei=yUs3TKu1CYf2tgPJgoxS&amp;ved=0CCoQHzAA\">Similar<\/a><\/span><\/span><\/div><!--n--><!--m--><\/li>\n        ",
            "type": "here_doc"
         }],
         "state": "inactive"
      }
   ],
   "ruleset_name": "a661x1"
}
