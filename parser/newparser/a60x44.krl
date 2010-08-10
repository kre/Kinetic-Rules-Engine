{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"},
      {"domain": "kynetximpactspring2010.eventbrite.com"}
   ],
   "global": [],
   "meta": {
      "author": "MikeGrace",
      "description": "\nKeeping you updated and connected to Kynetx with news alerts, games, contests, and more.      Currently annotates search results for questions asked on our developers exchange site.     \n",
      "logging": "on",
      "name": "Kynetx Fan"
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
         "emit": "\nfunction my_select(obj) {      var ftext = $K(obj).text();      if (ftext.match(/kynetx.com/)) {        return \"<img class='devexrocks' src='http://kynetx.michaelgrace.org/kynetx_app/devex.png' />\";      } else {        false;      }    }          ",
         "foreach": [],
         "name": "search_annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "<h1>Congratulations!<\/h1>"
               },
               {
                  "type": "str",
                  "val": "<h3>Thanks for being a fan of Kynetx!<\/h3><p>Your discount code for $51 off has been entered. You may continue your order.<\/p>"
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
         "emit": "\nif($K(\"input[name='cost_8837003']\").val() == \"150.00\") {      $K(\"#discountDiv input[type='text']\").val(\"Earlybirdspring2010\");      applyDiscount('None');    }          ",
         "foreach": [],
         "name": "spring_impact_discount_autofill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://kynetximpactspring2010.eventbrite.com/",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a60x44"
}
