{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [],
   "meta": {
      "author": "Nathan Whiting",
      "description": "\nDOW Ticker Display with Notify     \n",
      "logging": "on",
      "name": "Dow Ticker"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Stock datasource"
            },
            {
               "type": "var",
               "val": "msg"
            }
         ],
         "modifiers": [
            {
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            },
            {
               "name": "opacity",
               "value": {
                  "type": "num",
                  "val": 1
               }
            }
         ],
         "name": "notify",
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "ticker",
            "rhs": {
               "type": "str",
               "val": "goog"
            },
            "type": "expr"
         },
         {
            "lhs": "last",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "last",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "open",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "open",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "high",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "high",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "low",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "low",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "volume",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "volume",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "previous_close",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "previous_close",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "name",
            "rhs": {
               "args": [{
                  "type": "var",
                  "val": "ticker"
               }],
               "predicate": "name",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": " \nTicker: #{ticker}<br/>          Last: #{last}<br/>          Open: #{open}<br/>          High: #{high}<br/>          Low: #{low}<br/>          Volume: #{volume}<br/>          Previous Close: #{previous_close}<br/>          Name: #{name}<br/>          <style>            .KOBJ_message { font-size: 18px; }            .KOBJ_header { font-size: 24px !important; }          <\/style>            \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a381x1"
}
