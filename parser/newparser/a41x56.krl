{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "runtime-addition-search-annotate"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "type": "var",
            "val": "mySelect"
         }],
         "modifiers": [{
            "name": "results_lister",
            "value": {
               "type": "str",
               "val": "li.g, div.g, li div.res, #results>ul>li,.sb_adsW"
            }
         }],
         "name": "annotate_search_results",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nfunction mySelect(obj){  \treturn \"BOO!!!\";  }            ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.bing.com|www.google.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x56"
}
