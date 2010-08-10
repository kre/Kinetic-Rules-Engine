{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nMove after example for documentation     \n",
      "logging": "on",
      "name": "Move After Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#footer"
            },
            {
               "type": "str",
               "val": "#header_bar_top"
            }
         ],
         "modifiers": null,
         "name": "move_after",
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
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/move-after/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x105"
}
