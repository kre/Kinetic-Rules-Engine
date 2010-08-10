{
   "dispatch": [{"domain": "google.com"}],
   "global": [
      {"emit": "\nKOBJ.cssNEW=function(css){        \tvar head = document.getElementsByTagName('head')[0],    \t\tstyle = document.createElement('style'),    \t\trules = document.createTextNode(css);    \t\tKOBJstyle = document.getElementById('KOBJ_stylesheet');            if(KOBJstyle == null) {                    style.type = 'text/css';           \t    style.id = 'KOBJ_stylesheet';                if(style.styleSheet) {    \t\tstyle.styleSheet.cssText = rules.nodeValue;    \t    } else {    \t\tstyle.appendChild(rules);    \t    }        \t    head.appendChild(style);                } else {                if(KOBJstyle.styleSheet) {    \t\tKOBJstyle.styleSheet.cssText += rules.nodeValue;    \t    } else {    \t\tKOBJstyle.appendChild(rules);    \t    }            }        };                        "},
      {
         "content": "body {background-color: red;}    ",
         "type": "css"
      }
   ],
   "meta": {
      "logging": "off",
      "name": "CSS Test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "CSS"
            },
            {
               "type": "str",
               "val": "CSS emit test"
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
      "state": "active"
   }],
   "ruleset_name": "a41x36"
}
