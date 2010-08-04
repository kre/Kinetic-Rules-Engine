{
   "dispatch": [{"domain": "www.cougarboard.com"}],
   "global": [],
   "meta": {
      "description": "\ntest   \n",
      "logging": "off",
      "name": "Hello World"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello, World"
            },
            {
               "type": "str",
               "val": "This is a test"
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
      "name": "hellotest",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "cougarboard",
         "type": "prim_event",
         "vars": []
      }},
      "state": "inactive"
   }],
   "ruleset_name": "a73x1"
}
