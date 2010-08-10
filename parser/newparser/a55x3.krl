{
   "dispatch": [{"domain": "baconsalt.com"}],
   "global": [],
   "meta": {
      "author": "Chris Jensen",
      "description": "\nNew Hello World \n",
      "logging": "off",
      "name": "Tutorial"
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
               "val": "Everything should taste like bacon"
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
         "pattern": "http://www.baconsalt.com/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a55x3"
}
