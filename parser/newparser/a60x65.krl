{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "logging": "off",
      "name": "documentation example after"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "h1.entry-title"
            },
            {
               "type": "str",
               "val": "<h1>You fired the AFTER rule!<\/h1>"
            }
         ],
         "modifiers": null,
         "name": "after",
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
      "name": "after_example_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/after/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x65"
}
