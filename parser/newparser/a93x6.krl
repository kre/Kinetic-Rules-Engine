{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "cnn.com"},
      {"domain": "facebook.com"},
      {"domain": "google.co.uk"},
      {"domain": "google.com.pk"}
   ],
   "global": [],
   "meta": {
      "keys": {"errorstack": "521b680b0f92a3237b8f419342e3c620"},
      "logging": "on",
      "name": "zipweb2"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "var",
               "val": "selector"
            },
            {
               "type": "var",
               "val": "content"
            }
         ],
         "modifiers": null,
         "name": "after",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nif(window.OPTINI_WatchSet){ } else {  \tKOBJ.watchDOM(\"#rso\",function(){  \t\tdelete KOBJ['a93x6'].pendingClosure; KOBJ['a93x6'].dataLoaded = false;alert(\"hello World\"); \t\t\t\twindow.OPTINI_WatchSet = true;  \t});  }                            ",
      "foreach": [],
      "name": "google_search_insert",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.google.com.*",
         "type": "prim_event",
         "vars": [
            "notneeded",
            "term"
         ]
      }},
      "pre": [],
      "state": "active"
   }],
   "ruleset_name": "a93x6"
}
