{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "www.amazon.com"}
   ],
   "global": [],
   "meta": {
      "author": "Sam Curren",
      "description": "\ntesting page:env variables     \n",
      "logging": "off",
      "name": "PageENVTest"
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
      "name": "callerdomain",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "post": {
         "alt": [{
            "type": "log",
            "what": {
               "args": [
                  {
                     "type": "num",
                     "val": -9
                  },
                  {
                     "args": [
                        null,
                        {
                           "args": [
                              null,
                              {
                                 "args": [
                                    null,
                                    {
                                       "args": [
                                          null,
                                          null
                                       ],
                                       "op": "/",
                                       "type": "prim"
                                    }
                                 ],
                                 "op": "*",
                                 "type": "prim"
                              }
                           ],
                           "op": "/",
                           "type": "prim"
                        }
                     ],
                     "op": "+",
                     "type": "prim"
                  }
               ],
               "op": "-",
               "type": "prim"
            }
         }],
         "cons": [null],
         "type": null
      },
      "pre": [
         {
            "lhs": "pageurl",
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
            "lhs": "pagedomain",
            "rhs": null,
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a8x14"
}
