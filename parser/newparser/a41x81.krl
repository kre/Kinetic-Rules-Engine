{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [],
   "meta": {
      "author": "JAM",
      "logging": "off",
      "name": "Annotate Remote Demo"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [{
               "name": "remote",
               "value": {
                  "type": "str",
                  "val": "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?"
               }
            }],
            "name": "annotate_search_results",
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
         "name": "annotate_remote",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [{
               "name": "remote",
               "value": {
                  "type": "str",
                  "val": "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?"
               }
            }],
            "name": "annotate_local_search_results",
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
         "name": "annotate_local_remote",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x81"
}
