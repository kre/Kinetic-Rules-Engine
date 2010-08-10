{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": " \n     Kynetx Tuts Example showing off the power of debug on\n  ",
      "logging": "on",
      "name": "Debug On Example"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "hi"
            },
            {
               "type": "var",
               "val": "hereDoc"
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
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "hereDoc",
         "rhs": "\n        I can put what ever I want here\n        and it will be left the way it is.\n        <h1>: )<\/h1>\n      ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x198"
}
