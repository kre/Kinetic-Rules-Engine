{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "search.yahoo.com"}
   ],
   "global": [],
   "meta": {
      "author": "Nathan Whiting",
      "description": "\nDemonstration of Percolate     \n",
      "logging": "on",
      "name": "SPercolate"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "percolate_select_function"
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
      "emit": "\nfunction percolate_select_function(obj){     var regex_test = $K(obj).data(\"domain\").match(/syntech/gi);       if(regex_test){        return true;     } else {        return false;     }  }            ",
      "foreach": [],
      "name": "search",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "google.com|search.yahoo.com|bing.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a381x4"
}
