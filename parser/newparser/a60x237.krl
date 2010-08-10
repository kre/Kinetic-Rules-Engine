{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      errorstack testing\n    ",
      "keys": {"errorstack": "4936c1b3b36b3869986cf5d0905a9aee"},
      "logging": "on",
      "name": "errorstack testing"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Hello!"
               },
               {
                  "type": "str",
                  "val": "Good morning. : )"
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
         }},
         {"emit": "\n        console.log(\"wow\");\n        KOBJ.errorstack_submit(KOBJ['a60x237'].keys.errorstack, \"woho\");\n      "}
      ],
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
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x237"
}
