{
   "dispatch": [],
   "global": [{"emit": "\n    dataset = \"rss\" : {\n      \"item\" : [\n        {\n          \"thumbs\" : [\n            {\n              \"url\" : \"http://geek.michaelgrace.org/fun.jpg\"\n            },\n            {\n              \"url\" : \"http://geek.michaelgrace.org/happy.jpg\"\n            }\n          ]\n        },\n        {\n          \"thumbs\" : [\n            {\n              \"url\" : \"http://geek.michaelgrace.org/sad.jpg\"\n            },\n            {\n              \"url\" : \"http://geek.michaelgrace.org/down.jpg\"\n            }\n          ]\n        },\n        {\n          \"thumbs\" : [\n            {\n              \"url\" : \"http://geek.michaelgrace.org/really.jpg\"\n            },\n            {\n              \"url\" : \"http://geek.michaelgrace.org/yes.jpg\"\n            }\n          ]\n        }\n      ],\n      \"otherStuff\" : {\n        \"devexRocks\" : \"true\"\n      }\n    }\n    "}],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      for devex question\n    ",
      "logging": "on",
      "name": "array inside an array"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Nested Arrays!"
            },
            {
               "type": "str",
               "val": "party time"
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
   "ruleset_name": "a60x226"
}
