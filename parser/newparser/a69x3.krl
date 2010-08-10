{
   "dispatch": [{"domain": "kynetx.com"}],
   "global": [],
   "meta": {
      "description": "\nThis is descrition of my first application    \n",
      "logging": "off",
      "name": "KRL Tutorial Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello World"
            },
            {
               "type": "str",
               "val": "This is my first rule and I want to tell the world hello!"
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
      "name": "my_first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "\\?test",
         "type": "prim_event",
         "vars": []
      }},
      "state": "inactive"
   }],
   "ruleset_name": "a69x3"
}
