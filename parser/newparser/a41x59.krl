{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Land's End"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "str",
            "val": "Hi!"
         }],
         "modifiers": null,
         "name": "alert",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "var",
         "val": "foo"
      },
      "emit": null,
      "foreach": [],
      "name": "eddiebauer",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "message",
            "rhs": " \n<div class=\"landsEnd\"><h3>Love down?<\/h3><p>Do you love warm, soft down coats? Don't forget that at the Land's End Down Sale, you can get 30% off using Promo Code DD293<\/p><a href=\"http://www.landsend.com\">  \t\n ",
            "type": "here_doc"
         },
         {
            "lhs": "foo",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "Firefox"
               }],
               "predicate": "browser_name",
               "source": "useragent",
               "type": "qualified"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a41x59"
}
