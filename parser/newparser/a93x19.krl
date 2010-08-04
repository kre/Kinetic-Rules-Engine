{
   "dispatch": [],
   "global": [],
   "meta": {
      "author": "",
      "description": "\n      \n    ",
      "logging": "off",
      "name": "MyDomWatch"
   },
   "rules": [{
      "actions": [
         {"emit": "\n          if(window.OPTINI_WatchSet) { } \n            else {  \t\n            KOBJ.watchDOM(\"#rso\",function()\n                    {  \t\t  \t\n                          var app =\tKOBJ.get_application(\"a93x9\");\n                          app.reload();   \t\t\n                          window.OPTINI_WatchSet = true;  \t\n                    });  \n          }            \n          "},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "body"
               },
               {
                  "type": "str",
                  "val": "we seen something change"
               }
            ],
            "modifiers": null,
            "name": "append",
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
      "name": "first_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a93x19"
}
