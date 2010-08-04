{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "author": "Nathan Whiting",
      "description": "\nTracks The Stocks Based on the Web Site     \n",
      "logging": "on",
      "name": "StockTracker"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Stock Information"
            },
            {
               "args": [
                  {
                     "type": "var",
                     "val": "msg"
                  },
                  {
                     "type": "var",
                     "val": "msg2"
                  }
               ],
               "op": "+",
               "type": "prim"
            }
         ],
         "modifiers": null,
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
            "lhs": "current_price",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "^DJI"
               }],
               "predicate": "last",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "change",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "^DJI"
               }],
               "predicate": "change",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "name",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "^DJI"
               }],
               "predicate": "name",
               "source": "stocks",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": " \nName: #{name}<br/>          Change: #{change}<br/>  \tCurrent_price: #{current_price}<br/>          <style>            .KOBJ_message { font-size: 16px; }            .KOBJ_header { font-size: 20px !important; }          <\/style>            \n ",
            "type": "here_doc"
         },
         {
            "lhs": "msg2",
            "rhs": " \n<br/>  \t<br/>          Ticker: #{ticker}<br/>          Last: #{last}<br/>          Open: #{open}<br/>          High: #{high}<br/>          Low: #{low}<br/>          Volume: #{volume}<br/>          Previous Close: #{previous_close}<br/>          Name: #{name}<br/>          <style>            .KOBJ_message { font-size: 18px; }            .KOBJ_header { font-size: 24px !important; }          <\/style>            \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a381x3"
}
