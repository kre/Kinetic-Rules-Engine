{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "Phil Windley",
      "authz": {
         "level": "user",
         "type": "required"
      },
      "description": "\nContains an authz directive; for testing purposes on KRE     \n",
      "logging": "off",
      "name": "Test App Authorization"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "This is a test"
            },
            {
               "type": "str",
               "val": "If you can see this, you're authorized"
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
      "name": "test_rule_1",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "/foo/bar.html",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "cs_test_authz"
}
