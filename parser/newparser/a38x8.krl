{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Google Free WiFi"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#body>center"
            },
            {
               "type": "var",
               "val": "test"
            }
         ],
         "modifiers": null,
         "name": "append",
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
      "name": "free_wifi",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "google.com",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "test",
         "rhs": " \n<p style=\"font-size:.6em;\">Free WiFi brought to you by:<\/p><a href=\"http://www.beansandbrews.com/\"><img style=\"border:0;\" alt=\"Beans and Brew Free WiFi\" src=\"http://img198.imageshack.us/img198/2485/75525359.jpg\"/><\/a> \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a38x8"
}
