{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "twitter_search",
         "source": "http://search.twitter.com/search.json",
         "type": "datasource"
      },
      {
         "content": "\n    #kresults {\n      margin-left: 25px;\n      border-radius: 10px;\n      border: 1px solid #AAAAAA;\n      width: 550px;\n      padding: 5px;\n      display: none;\n      position: absolute;\n      top: 200px;\n      right: 10px;\n    }\n  \n    .tweet {\n      color: #FFFFFF;\n      background-color: #333333;\n      border-radius: 5px;\n      margin-bottom: 5px;\n      padding: 5px;\n      min-height: 50px;\n    }\n    \n    .tweet a {\n      color: #FFFFFF;\n    }\n  ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Dan R. Olsen III",
      "description": " \n     The twitter application showed in the KRL workshop.\n  ",
      "logging": "on",
      "name": "Twitter Mashup Demo"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#gsr"
            },
            {
               "type": "var",
               "val": "tweet_div_one"
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
      "name": "create_display_area",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.google.com/search.*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "tweet_div_one",
         "rhs": "\r\n      <div id=\"kresults\"><\/div>\r\n    ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a57x2"
}
