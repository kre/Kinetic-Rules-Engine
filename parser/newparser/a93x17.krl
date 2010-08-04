{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "sandbox_test"
   },
   "rules": [{
      "actions": [
         {"emit": "\nKOBJ.log(\"test\");    \t\tKOBJ.forward_to_chrome(\"Hello World from the action you are in the page....\");    \t\talert(\"test\");    \t                "},
         {"action": {
            "args": [{
               "type": "str",
               "val": "bob"
            }],
            "modifiers": null,
            "name": "alert",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "test"
               },
               {
                  "type": "str",
                  "val": "sandboxing"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "simple_notify",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a93x17"
}
