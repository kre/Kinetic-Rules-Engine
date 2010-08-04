{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "zipcidtest"
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
      "name": "google_search_insert",
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
      "post": {
         "cons": [null],
         "type": null
      },
      "state": "active"
   }],
   "ruleset_name": "a93x9"
}
