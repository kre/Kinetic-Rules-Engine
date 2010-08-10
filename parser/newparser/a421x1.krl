{
   "dispatch": [{"domain": "twitter.com"}],
   "global": [],
   "meta": {
      "author": "Randall Bohn",
      "description": "\nApplication for Bean Curd Breakfast     \n",
      "logging": "off",
      "name": "bcbApplication"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Guess What!"
            },
            {
               "type": "str",
               "val": "You're using Twitter again!"
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
      "name": "notifytwit",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a421x1"
}
