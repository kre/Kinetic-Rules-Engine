{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Jon Wilson",
      "description": "\ntestapp     \n",
      "logging": "off",
      "name": "Tester"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "This is fun"
            },
            {
               "type": "str",
               "val": "Everything should taste like lemons!"
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
      "name": "jon_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.baconsalt.com/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a566x1"
}
