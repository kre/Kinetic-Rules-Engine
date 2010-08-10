{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [],
   "meta": {
      "keys": {"errorstack": "f2ffa11fdbb0fef95a790c1a7d0424b9"},
      "logging": "off",
      "name": "search annotate"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "my_select"
         }],
         "modifiers": null,
         "name": "annotate_search_results",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nfunction my_select(obj) {  \tvar ftext = $K(obj).text();  \tif (ftext.match(/BYU/)) {  \t\tconsole.log(\"I changed\");  \t\treturn \"<span><a href='#'>Yourschool!<\/a><\/span>\"  \t} else {  \t\tfalse;  \t}  }          ",
      "foreach": [],
      "name": "augment_results",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x6"
}
