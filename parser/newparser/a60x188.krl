{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [],
   "meta": {
      "author": "Alex Quintero",
      "description": " \n     Make it so that programming websites that are likely to help appear first. \n   ",
      "logging": "on",
      "name": "Programming websites preference"
   },
   "rules": [{
      "actions": [
         {"emit": "\n        function findDevex(obj){\n         console.log( $K(obj).data(\"domain\") );\n         return $K(obj).data(\"domain\").match(/codeproject|stackoverflow|msdn|codeguru/gi);      \n        }            \n      "},
         {"action": {
            "args": [{
               "type": "var",
               "val": "findDevex"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "percolation",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "google\\.com|yahoo\\.com|bing\\.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x188"
}
