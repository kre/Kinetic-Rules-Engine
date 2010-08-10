{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [],
   "meta": {
      "author": "Michael Grace",
      "description": "\nInserts stackoverflow icon to the right of search results pointing to stackoverflow.com    \n",
      "logging": "off",
      "name": "StackOverflow fan"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": null,
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {      var ftext = $K(obj).text();      if (ftext.match(/stackoverflow.com/)) {        return \"<img class='stackoverflowrocks' src='http://kynetx.michaelgrace.org/stackoverflow/stackoverflow.jpg' />\";      } else {        false;      }    }          ",
         "foreach": [],
         "name": "search",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "findDevex"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction findDevex(obj){         return $K(obj).data(\"domain\").match(/stackoverflow/gi);      }            ",
         "foreach": [],
         "name": "percolation",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": null,
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {        match = false;         if( $K(obj).data(\"domain\").match(/stackoverflow/gi) ) {          match = \"<img class='stackoverflowrocks' src='http://kynetx.michaelgrace.org/stackoverflow/stackoverflow.jpg' />\";        }        return match;      }            ",
         "foreach": [],
         "name": "annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a60x17"
}
