{
   "dispatch": [{"domain": "www.windley.com"}],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "cto_feed",
      "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=2545e1c749cb51a9d0251c79d5bff5f4&_render=json",
      "type": "dataset"
   }],
   "meta": {
      "logging": "on",
      "name": "Windley"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": ".content ul:eq(0)"
            },
            {
               "type": "var",
               "val": "msg"
            }
         ],
         "modifiers": null,
         "name": "replace_html",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nmsg = $K('<ul id=\"CTO_dates\"><\/ul>');  \t  \tto_post = $K(contents);  \t$K(to_post).each(function(i) {  \t  \t\tcontent = this;  \t\t  \t\tcontentArray = content.split('<br \\/>');  \t\t  \t\tdateWhole = contentArray[0];  \t\t  \t\tdate = dateWhole.replace(/When: (\\w+)/,\"$1\");  \t\t  \t\t$K(msg).append('<li>'+date+'<\/li>');  \t  \t  \t});                ",
      "foreach": [],
      "name": "cto_breakfast",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.windley.com/cto_forum",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "cto_breakfasts",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$..items"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "cto_feed"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "contents",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$..content.content"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "cto_breakfasts"
               },
               "type": "operator"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a41x54"
}
