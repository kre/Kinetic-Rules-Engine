{
   "dispatch": [
      {"domain": "bing.com"},
      {"domain": "cnn.com"},
      {"domain": "facebook.com"},
      {"domain": "google.com"},
      {"domain": "yahoo.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nMartinez Network App   \n",
      "logging": "off",
      "name": "Martinez Network "
   },
   "rules": [
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
         "name": "cnn_com",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"234\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>    <\/div>        \n ",
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
               "rhs": " \n<div id='Optini_Ad' align=\"center\">    <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"233\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>    <\/div>    \n ",
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {    \tKOBJ.watchDOM(\"#rso\",function(){            var app = KOBJ.get_application(\"a677x2\");            app.reload();     \t\twindow.OPTINI_WatchSet = true;    \t});    }                ",
         "foreach": [],
         "name": "facebook_com",
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
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad'><\/div>    <\/div>        <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"235\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/mehshan.dev.optini.com/bridge.php\" + src;        if( document.getElementById('Optini_Ad_Content') )    {        }    else    {      jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    }        <\/script>        \n ",
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
         "name": "google_com",
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
               "lhs": "content",
               "rhs": " \n<div id='Optini_Logo'>    <div id='Optini_Ad'><\/div>    <\/div>        <script>    var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";    var m3_r = Math.floor(Math.random()*99999999999);    var zone = \"236\";       if( !document.MAX_used ) {     document.MAX_used = ',';    }        var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;        if( document.MAX_used != ',' ) {     src += \"&exclude=\" + document.MAX_used;    }    \t\t\t    src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');    \t\t    src += \"&loc=\" + escape(window.location);    \t\t    if(document.referrer) {     src += \"&referer=\" + escape(document.referrer);    }        if(document.context) {     src += \"&context=\" + escape(document.context);    }        if(document.mmm_fo) {     src += \"&mmm_fo=1\";    }        src += \"&url=\" + escape(m3_u);    src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;        jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');        <\/script>        \n ",
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
         "emit": "\nif(window.OPTINI_WatchSet){ } else {        KOBJ.watchDOM(\"#rso\",function(){            var app = KOBJ.get_application(\"a677x2\");            app.reload();            window.OPTINI_WatchSet = true;        });    }                ",
         "foreach": [],
         "name": "sponsor_link_blocker",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "content",
            "rhs": " \n<div id=\"Optini_Link_Blocker\">    <div id=\"Optini_VuMetrics\">    <img src=\"http://vumetrics.optini.com/piwik.php?idsite=19\" style=\"border:0\" alt=\"\"/>    <\/div>    <\/div>    \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a677x2"
}
