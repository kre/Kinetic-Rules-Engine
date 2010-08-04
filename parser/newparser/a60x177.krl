{
   "dispatch": [{"domain": "dogpile.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nsearch annotation on dogpile.com     \n",
      "logging": "on",
      "name": "dogpile search"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "search"
            },
            {
               "type": "str",
               "val": "dogpile"
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
      "name": "custom_search_annotation_for_dogpile",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*dogpile.com\\/dogpile\\/ws\\/results\\/Web\\/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x177"
}
