{
   "dispatch": [
      {"domain": "youtube.com"},
      {"domain": "baconsalt.com"}
   ],
   "global": [],
   "meta": {
      "author": "Sam Curren",
      "description": "\nDisplays a QR code for any site     \n",
      "logging": "off",
      "name": "QRCode"
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
      "name": "youtube",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "youtube.com",
         "type": "prim_event",
         "vars": []
      }},
      "post": {
         "cons": [null],
         "type": null
      },
      "pre": [
         {
            "lhs": "url",
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
            "lhs": "url",
            "rhs": null,
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a8x15"
}
