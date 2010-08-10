{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "google.co.uk"}
   ],
   "global": [],
   "meta": {
      "description": "\nfandango   \n",
      "logging": "off",
      "name": "fandangotogo"
   },
   "rules": [{
      "actions": null,
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "main",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.google.c.*/(.*(?:&q|\\?q|#)=([^&]*)|$)",
         "type": "prim_event",
         "vars": [
            "notneeded",
            "term"
         ]
      }},
      "state": "active"
   }],
   "ruleset_name": "a428x4"
}
