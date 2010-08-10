{
   "dispatch": [{"domain": "craigslist.org"}],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "yql",
      "source": "http://query.yahooapis.com/v1/public/yql",
      "type": "datasource"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\nSearching craigslist by image     \n",
      "logging": "on",
      "name": "Craigslist Image"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "args": [
               {
                  "type": "str",
                  "val": "select * from html where url=%22"
               },
               {
                  "args": [
                     {
                        "type": "var",
                        "val": "caller"
                     },
                     {
                        "type": "str",
                        "val": "%22 and xpath=%22//span[@class='p']/../a%22"
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               }
            ],
            "op": "+",
            "type": "prim"
         }],
         "modifiers": null,
         "name": "query",
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
      "name": "images",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "post": {
         "cons": [null],
         "type": null
      },
      "pre": [
         {
            "lhs": "caller",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "caller"
               }],
               "predicate": "env",
               "source": "page",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "call",
            "rhs": {
               "type": "var",
               "val": "caller"
            },
            "type": "expr"
         },
         {
            "lhs": "host",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "hostname"
               }],
               "predicate": "url",
               "source": "page",
               "type": "qualified"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x41"
}
