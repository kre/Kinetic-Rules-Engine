{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nKynetx Fan application for Impact 2.0   \n",
      "logging": "off",
      "name": "Kynetx Fan Impact"
   },
   "rules": [
      {
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
         "emit": "\nfunction my_select(obj) {      var ftext = $K(obj).text();      if (ftext.match(/kynetx.com/gi)) {        return \"<span><a target='_blank' href='http://www.kynetx.com' border='0'><img border='0' class='welovekynetx' src='http://7bound.com/impact2010/images/kyntexfan.jpg' /><\/a><\/span>\";      } else {        false;      }    }          ",
         "foreach": [],
         "name": "search_annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "findDevex"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction findDevex(obj){         return $K(obj).data(\"domain\").match(/devex.kynetx.com/gi);      }            ",
         "foreach": [],
         "name": "percolate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a40x6"
}
