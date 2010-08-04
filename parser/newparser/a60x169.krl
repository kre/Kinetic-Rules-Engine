{
   "dispatch": [{"domain": "example.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nTo demonstrate timing     \n",
      "logging": "on",
      "name": "Timing Test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Setting up"
            },
            {
               "type": "var",
               "val": "html"
            }
         ],
         "modifiers": [{
            "name": "sticky",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
         "name": "notify",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nvar found = $K(\"div#setup\");      if(found) {        alert(\"found the setup div\");      } else {        alert(\"couldn't find the setup div\");      }          ",
      "foreach": [],
      "name": "setup",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "html",
         "rhs": " \n<div id=\"setup\">Setup Div<\/div>    \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a60x169"
}
