{
   "dispatch": [
      {"domain": "example.com"},
      {"domain": "google.com"},
      {"domain": "michaelgrace.org"}
   ],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Seeing if I can inject tracking code all around the web.\n    ",
      "logging": "on",
      "name": "StatCounter test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "head"
            },
            {
               "type": "var",
               "val": "tracking"
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
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "tracking",
         "rhs": "\n        <script type=\"text/javascript\">\n          var sc_project=5861062; \n          var sc_invisible=1; \n          var sc_security=\"2d9239c2\"; \n        <\/script>\n        <script type=\"text/javascript\" src=\"http://www.statcounter.com/counter/counter.js\"><\/script>\n      ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x215"
}
