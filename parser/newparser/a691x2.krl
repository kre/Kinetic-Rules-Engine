{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Jason Rice",
      "description": "\n      Logging tutorial with some JavaScript capabilities. (See tutorials 2-3)\n    ",
      "logging": "on",
      "name": "Debugging"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "$K is now available to use."
            },
            {
               "type": "str",
               "val": ": )"
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
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a691x2"
}
