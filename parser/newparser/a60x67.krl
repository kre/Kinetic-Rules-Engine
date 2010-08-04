{
   "dispatch": [{"domain": "docs.google.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\ndemonstrate simple search results annotation     \n",
      "logging": "off",
      "name": "documentation annotate search results example"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "http://www.google.com/search?q=kynetx.com"
            }],
            "modifiers": null,
            "name": "redirect",
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
         "name": "redirect_to_search_page",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/annotate-search-results/",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
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
         "emit": "\nfunction my_select(obj) {      var ftext = $K(obj).text();  var htext = $K(obj).html();      KOBJ.log(ftext);      if (ftext.match(/kynetx.com/)) {        return \"<img class='devexrocks' src='http://kynetx.michaelgrace.org/kynetx_app/devex.png' />\";      } else {        false;      }    }          ",
         "foreach": [],
         "name": "annotate_kynetx_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com/search",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a60x67"
}
