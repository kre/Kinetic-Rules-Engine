{
   "dispatch": [{"domain": "gamestop.com"}],
   "global": [],
   "meta": {
      "author": "Tristan Wagstaff",
      "description": "\nAuto check prices of desired games and notify when price drops occur     \n",
      "logging": "off",
      "name": "Video Game Price Checker"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Wow video games"
            },
            {
               "type": "str",
               "val": "games games games"
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
         "pattern": "http://www.gamestop.com/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a594x1"
}
