{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "facebook.com"},
      {"domain": "cnn.com"},
      {"domain": "nuskin.com"},
      {"domain": "wikipedia.org"},
      {"domain": "go.com"},
      {"domain": "yahoo.com"},
      {"domain": "sports.yahoo.com"},
      {"domain": "www.craigslist.org"},
      {"domain": "www.craigslist.com"},
      {"domain": "craigslist.org"},
      {"domain": "craigslist.com"}
   ],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "CraigBryson.com"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Enhance Your Web Experience:"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
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
         "name": "ComF5_dl",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.nuskin.com/en_US/home.html",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": "\n          <div id = \"Optini\" align = \"left\" height: 250px width: 300px> \n           \n            <h3>Stay Connected with the ComF5 Connector<\/h3>\n\n            <a class = \"Download\" href = \"http://vu.optini.com/comf5\">\n              <image alt = \"Download\" width=\"125\" height=\"50\" src = \"http://vue.us.vucdn.com/x282/www/delivery/ai.php?filename=button.png&contenttype=png\">\n            <\/a>\n\n        <\/div>\n        <br>\n      ",
            "type": "here_doc"
         }],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "[name=f]"
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
         "name": "google_search_replacement",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.co.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": "\n                      <script type=\"text/javascript\" src=\"http://www.google.com/jsapi\"><\/script>\n<script type=\"text/javascript\">\n  google.load('search', '1');\n  google.setOnLoadCallback(function() {\n    google.search.CustomSearchControl.attachAutoCompletion(\n      '005992153758944534110:vokoirvyw9i',\n      document.getElementById('q'),\n      'cse-search-box');\n  });\n<\/script>\n<form action=\"http://www.google.com/cse\" id=\"cse-search-box\">\n  <div>\n    <input type=\"hidden\" name=\"cx\" value=\"005992153758944534110:vokoirvyw9i\" />\n    <input type=\"hidden\" name=\"ie\" value=\"UTF-8\" />\n    <input type=\"text\" name=\"q\" id=\"q\" autocomplete=\"off\" size=\"31\" />\n    <input type=\"submit\" name=\"sa\" value=\"Search\" />\n  <\/div>\n<\/form>\n<script type=\"text/javascript\" src=\"http://www.google.com/jsapi\"><\/script>\n<script type=\"text/javascript\">google.load(\"elements\", \"1\", {packages: \"transliteration\"});<\/script>\n<script type=\"text/javascript\" src=\"http://www.google.com/cse/t13n?form=cse-search-box&t13n_langs=am%2Car%2Cbn%2Cel%2Cgu%2Chi%2Ckn%2Cml%2Cmr%2Cne%2Cfa%2Cpa%2Cru%2Csa%2Csr%2Cta%2Cte%2Cti%2Cur\"><\/script>\n<script type=\"text/javascript\" src=\"http://www.google.com/cse/brand?form=cse-search-box&lang=en\"><\/script>\n",
            "type": "here_doc"
         }],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#footer"
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
         "name": "google_com_homepage",
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
               "rhs": "\n         \"font[size=-1]:first,#footer_about_igoogle_link,#flp\"\n         ",
               "type": "here_doc"
            },
            {
               "lhs": "content",
               "rhs": "\n         <div id='Optini_Logo'>\n<div id='Optini_Ad'>\n<script>\nvar m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";\nvar m3_r = Math.floor(Math.random()*99999999999);\nvar zone = \"65\"; // Enter VuLiquid ZoneID here\n\nif( !document.MAX_used ) {\n document.MAX_used = ',';\n}\n\nvar src = \"?zoneid=\"+ zone + '&cb=' + m3_r;\n\nif( document.MAX_used != ',' ) {\n src += \"&exclude=\" + document.MAX_used;\n}\n\t\t\t\nsrc += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');\n\t\t\nsrc += \"&loc=\" + escape(window.location);\n\t\t\nif(document.referrer) {\n src += \"&referer=\" + escape(document.referrer);\n}\n\nif(document.context) {\n src += \"&context=\" + escape(document.context);\n}\n\nif(document.mmm_fo) {\n src += \"&mmm_fo=1\";\n}\n\nsrc += \"&url=\" + escape(m3_u);\n//src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;\nsrc = \"http:\\/\\/vue.us.vucdn.com/x282/www/delivery/bridge.php\" + src;\n\n\njQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');\n\n<\/script>\n<\/div>\n<\/div>\n\n         ",
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
         "name": "bing_com_homepage",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"63\";        if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>    <\/div>        \n ",
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {    \tKOBJ.watchDOM(\"#contentArea\",function(){            var app = KOBJ.get_application(\"a99x10\");            app.reload();     \t\twindow.OPTINI_WatchSet = true;    \t});    }                ",
         "foreach": [],
         "name": "facebook_com_vgrid",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com/|http://www.facebook.com/?ref=logo|http://www.facebook.com/#!/?ref=logo",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": " \n<script type=\"text/javascript\" src=\"http://vugrid.s3.amazonaws.com/js/jquery.swfobject.1-0-9.min.js\" charset=\"utf-8\"><\/script>       <script src=\"http://vugrid.s3.amazonaws.com/js/jquery.vuflashapitest.js\" type=\"text/javascript\" charset=\"utf-8\"><\/script>    <script type=\"text/javascript\" charset=\"utf-8\">      var optini_vugridxmlfile = \"versions/nuskin/nuskin_setup.xml\";    <\/script>    <script src=\"http://vugrid.s3.amazonaws.com/js/runvugrid.js\" charset=\"utf-8\"><\/script>        <div id=\"optiniVuGridContainer\" style=\"position: absolute;\">    <\/div>             \n ",
            "type": "here_doc"
         }],
         "state": "inactive"
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"66\";        if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>    <\/div>        \n ",
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {    \tKOBJ.watchDOM(\"#contentArea\",function(){    \t\tdelete KOBJ['a99x10'].pendingClosure;    \t\tKOBJ.reload(50);     \t\twindow.OPTINI_WatchSet = true;    \t});    }                ",
         "foreach": [],
         "name": "facebook_com_homepage",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad'><\/div>    <\/div>        <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"64\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        if( document.getElementById('Optini_Ad_Content') )    {        }    else    {      jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    }        <\/script>        \n ",
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
                  "val": "#content"
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
         "name": "wikipedia_com",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://en.wikipedia.org/wiki/.*",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"242\";        if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>   <\/div>  \t  \n ",
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
                  "val": "#yui-sub>div"
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
         "name": "sports_yahoo_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://sports.yahoo.com/",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"243\";        if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>        \n ",
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
                  "val": "#tads,#rhs_block,.sb_adsWv2:eq(0),.sb_adsNv2,.ads"
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {    \tKOBJ.watchDOM(\"#rso\",function(){            var app = KOBJ.get_application(\"a99x10\");            app.reload();     \t\twindow.OPTINI_WatchSet = true;    \t});    }                ",
         "foreach": [],
         "name": "sponsored_link_blocker",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com/.*q=.*|www.bing.com\\/search|search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": " \n<div id=\"Optini_Link_Blocker\">    <!-- Piwik  -->    <script type=\"text/javascript\" src=\"http://vumetrics.optini.com/piwik.js\"  charset=\"utf-8\"><\/script>        <!-- End Piwik Tag -->    <\/div>    \n ",
            "type": "here_doc"
         }],
         "state": "active"
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
            "pattern": "http://.*.craigslist.*",
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
               "rhs": " \n              <div id=\"Optini\">\n                <div class=\"hp_connect_box\">\n                  <div class=\"uiHeader uiHeaderBottomBorder mbm pbs\">\n                    <div class=\"clearfix uiHeaderTop\">\n                      <div class=\"uiTextSubtitle uiHeaderActions rfloat\">\n                      <\/div>\n                      <div><h4 class=\"uiHeaderTitle\">Get Connected With Nuskin<\/h4>\n                      <\/div>\n                    <\/div>\n                  <\/div>\n                  <div class=\"UIImageBlock clearfix mbs\">\n                    <i class=\"\">\n                    <\/i>\n                    <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">\n                      <div>\n                      \n                      What's New With Craig Bryson?\n                      \n                      <\/div>\n                      \n                      <a href=\"http://www.facebook.com/rcraigbryson\">Find Out Here<\/a>\n                      \n                      <\/div>\n                    <\/div>\n                    <div class=\"UIImageBlock clearfix mbs\">\n                    <i class=\"\">\n                    <\/i>\n                    <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">\n                      <div>\n                      \n                      Have You Seen Nuskin's New Products?\n                      \n                      <\/div>\n                      \n                      <a href=\"http://www.nuskin.com/en_US/home.html\">Shop Now!<\/a>\n                      \n                      <\/div>\n                    <\/div>\n                    <div class=\"UIImageBlock clearfix mbs\">\n                      <i class=\"\">\n                      <\/i>\n                      <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">\n                        <div>\n                        \n                        Stay in touch with NSE dreams\n                        \n                        <\/div>\n                        \n                        <a href=\"https://www.nsedreams.com/pwp/wac/webaccount/hostingLogin.jsp?textCacheLocale=en_US\">Go Now!<\/a>\n                        \n                      <\/div>\n                    <\/div>\n                    <div class=\"UIImageBlock clearfix mbs\">\n                      <i class=\"\">\n                      <\/i>\n                      <div class=\"UIImageBlock_Content UIImageBlock_ICON_Content\">                         \n                        <div>\n                        \n                        Build Your Business\n                        \n                        <\/div>\n                        \n                        <a href=\"http://www.nuskin.com/en_US/opportunity/roadmap_to_success.html\">Nuskin Will Guide You<\/a> \n                        \n                      <\/div>\n                    <\/div>\n                  <\/div>\n                <\/div>\n              <\/div>\n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a99x10"
}
