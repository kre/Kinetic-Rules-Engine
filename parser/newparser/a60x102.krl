{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nappend example for documentation     \n",
      "logging": "on",
      "name": "append example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": ":header"
            },
            {
               "type": "str",
               "val": " ... I'm a Header!"
            }
         ],
         "modifiers": null,
         "name": "append",
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
      "name": "the_appender",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/append/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x102"
}
