{
   "dispatch": [{"domain": "kynetx.com"}],
   "global": [],
   "meta": {
      "description": "\nThis is a sample app that creates a basic hello world   \n",
      "logging": "off",
      "name": "Hello World"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello"
            },
            {
               "type": "str",
               "val": "Hello Big Beautiful World!"
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.kynetx.com/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a9x11"
}
