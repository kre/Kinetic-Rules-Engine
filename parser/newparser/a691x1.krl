{
   "dispatch": [{"domain": "www.byuistore.com"}],
   "global": [],
   "meta": {
      "author": "Jason Rice",
      "description": "\nMy first app. by Jason Rice.     \n",
      "logging": "on",
      "name": "Hello World"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "$K Hello World"
            },
            {
               "type": "str",
               "val": "This website is my next target objective."
            }
         ],
         "modifiers": [{
            "name": "sticky",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
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
      "name": "myfirstrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.byuistore.com/booklist.aspx",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a691x1"
}
