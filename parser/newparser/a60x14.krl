{
   "dispatch": [{"domain": "geek.michaelgrace.org"}],
   "global": [],
   "meta": {
      "description": "\ntest   \n",
      "logging": "off",
      "name": "geek.michaelgrace.org"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "subdomain"
            },
            {
               "type": "str",
               "val": "ran"
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
      "name": "notify",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x14"
}
