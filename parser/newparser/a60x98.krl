{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nDocumentation example for float_html    \n",
      "logging": "on",
      "name": "float test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "absolute"
            },
            {
               "type": "str",
               "val": "top:50px"
            },
            {
               "type": "str",
               "val": "right:50px"
            },
            {
               "type": "str",
               "val": "<h1>I'm Floating HTML!<\/h1><h2>WEEEEEeeeeeeee!<\/h2>"
            }
         ],
         "modifiers": null,
         "name": "float_html",
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
      "name": "floater",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x98"
}
