{
   "dispatch": [{"domain": "search.yahoo.com"}],
   "global": [],
   "meta": {},
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#logo_web"
               },
               {
                  "type": "var",
                  "val": "test"
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
         "name": "iphone",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "search.yahoo.com/i",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "test",
            "rhs": " \n<center><img src=\"http://a.l.yimg.com/a/i/us/sch/gr3/iphone_logo_20080707.png\" alt=\"Yahoo! Search\" id=\"logo_web\"/><br/><p style=\"font-size: 0.8em;\">Free WiFi brought to you by:<\/p><a href=\"http://www.beansandbrews.com/\"><img src=\"http://img198.imageshack.us/img198/2485/75525359.jpg\" alt=\"Beans and Brew Free WiFi\" style=\"border: 0pt none ;\"/><\/a><\/center><\/div> \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#ft"
               },
               {
                  "type": "var",
                  "val": "test"
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
         "name": "computer",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "search.yahoo.com|www.search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "test",
            "rhs": " \n<center><p style=\"font-size:.8em;\">Free WiFi brought to you by:<\/p><a href=\"http://www.beansandbrews.com/\"><img style=\"border:0;\" alt=\"Beans and Brew Free WiFi\" src=\"http://img198.imageshack.us/img198/2485/75525359.jpg\"/><\/a><\/center>      <div id=\"ft\">  <hr/>  <p class=\"copyright\">  <span>© 2009 Yahoo!<\/span>  <a href=\"http://privacy.yahoo.com/\">Privacy<\/a>  /  <a href=\"http://info.yahoo.com/legal/us/yahoo/utos/utos-173.html\">Legal<\/a>  -  <a href=\"http://search.yahoo.com/info/submit.html\">Submit Your Site<\/a>  <\/p>  <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a38x10"
}
