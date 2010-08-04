{
   "dispatch": [{"domain": "www.yahoo.com"}],
   "global": [],
   "meta": {
      "description": "\nMy First App   \n",
      "logging": "off",
      "name": "SunitaApp"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Welcome Sunita"
            },
            {
               "type": "str",
               "val": "This is a hello world app from Kynetx - Sunita"
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
      "name": "sunita_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.yahoo.com/$",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a437x7"
}
