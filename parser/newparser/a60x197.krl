{
   "dispatch": [{"domain": "autotrader.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": " \n    Testing for devex question. \n  ",
      "logging": "on",
      "name": "Autotrader Anotation"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "ho"
            },
            {
               "type": "str",
               "val": "ho"
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
         "pattern": ".*autotrader.com/fyc/searchresults.jsp.*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x197"
}
