{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "cnn.com"},
      {"domain": "facebook.com"},
      {"domain": "google.co.uk"},
      {"domain": "google.com.pk"},
      {"domain": "msn.com"},
      {"domain": "search.yahoo.com"}
   ],
   "global": [],
   "meta": {
      "keys": {"errorstack": "69337afe3d971495e11571e555d6131b"},
      "logging": "on",
      "name": "zipweb"
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
   "ruleset_name": "a99x7"
}
