{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "twitter.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "stackoverflow.com"},
      {"domain": "stackexchange.com"},
      {"domain": "amazon.com"},
      {"domain": "kynetx.com"},
      {"domain": "michaelgrace.org"},
      {"domain": "cnn.com"},
      {"domain": "nbc.com"},
      {"domain": "youtube.com"},
      {"domain": "jquery.com"},
      {"domain": "byui.edu"},
      {"domain": "imdb.com"},
      {"domain": "facebook.com"}
   ],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "yahoo_pipes",
      "source": "http://pipes.yahoo.com/pipes/pipe.run",
      "type": "datasource"
   }],
   "meta": {
      "author": "Michael Grace",
      "description": "\nYour personal back seat driver with you on the web    \n",
      "logging": "off",
      "name": "MikeGrace"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "facebook!"
               },
               {
                  "type": "var",
                  "val": "count"
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
         "name": "facebook",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "sites",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "_id",
                           "rhs": {
                              "type": "str",
                              "val": "9f4c9a264498ecdf90173c00b9fffb5f"
                           }
                        },
                        {
                           "lhs": "_render",
                           "rhs": {
                              "type": "str",
                              "val": "json"
                           }
                        }
                     ]
                  }],
                  "predicate": "yahoo_pipes",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "count",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.count"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            }
         ],
         "state": "active"
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
         "emit": "\nfunction my_select(obj) {      checklist = \"\";      for(i=0;i<site_list.length;i++) {        checklist += \"/\" + site_list[i].site + \"/\";        if(i != site_list.length - 1) checklist += \"|\";      }          var ftext = $K(obj).text();      if (ftext.match(/google.com/|/kynetx.com/|/pipes.yahoo.com/|/flickr.com/|/jquery.com/|/apple.com/|/twitter.com/|/stackexchange.com/|/stackoverflow.com/)) {        return \"<img src='http://kynetx.michaelgrace.org/mikegrace/mikegrace.jpg' />\"      } else {        false;      }    }          ",
         "foreach": [],
         "name": "google",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "sites",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "_id",
                           "rhs": {
                              "type": "str",
                              "val": "9f4c9a264498ecdf90173c00b9fffb5f"
                           }
                        },
                        {
                           "lhs": "_render",
                           "rhs": {
                              "type": "str",
                              "val": "json"
                           }
                        }
                     ]
                  }],
                  "predicate": "yahoo_pipes",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "count",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.count"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "site_list",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x19"
}
