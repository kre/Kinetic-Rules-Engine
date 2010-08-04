{
   "dispatch": [
      {"domain": "netflix.com"},
      {"domain": "hollywoodvideo.com"},
      {"domain": "blockbuster.com"},
      {"domain": "example.com"}
   ],
   "global": [
      {
         "cachable": {
            "period": "minutes",
            "value": "30"
         },
         "datatype": "JSON",
         "name": "rottenTomatoesScore",
         "source": "http://www.rottentomatoes.com/m/",
         "type": "datasource"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "30"
         },
         "datatype": "JSON",
         "name": "yql",
         "source": "http://query.yahooapis.com/v1/public/yql?",
         "type": "datasource"
      },
      {
         "cachable": {
            "period": "seconds",
            "value": "5"
         },
         "datatype": "JSON",
         "name": "blockBusterSearch",
         "source": "http://www.blockbuster.com/download/stores/storelocator/findStoresWithTitleAvailability?",
         "type": "datasource"
      },
      {"emit": "\nfunction kNotify(header, msg) {    \t\tconfig=\"{txn_id: 'C21CE5BA-5B86-11DE-8D16-C767F8606F2B',rule_name: 'facebookimage','opacity':.95,'width':'400px'}\";    \t\tuniq = (Math.round(Math.random()*100000000)%100000000);    \t\t$K.kGrowl.defaults.header = header;    \t\tif(typeof config === 'object') {    \t\t\tjQuery.extend($K.kGrowl.defaults,config);    \t}    \t$K.kGrowl(msg);        }                    "}
   ],
   "meta": {
      "description": "\nchecks ratings from Rotten Tomatoes and displays them. Also checks to see if movie is available near your local area.     \n",
      "logging": "off",
      "name": "Movies"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [{
            "args": [
               {
                  "type": "var",
                  "val": "queryBase"
               },
               {
                  "args": [
                     {
                        "type": "var",
                        "val": "toSearch"
                     },
                     {
                        "type": "var",
                        "val": "queryEnd"
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               }
            ],
            "op": "+",
            "type": "prim"
         }],
         "modifiers": null,
         "name": "query",
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
      "name": "netflix",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "netflix.com/Movie/(\\w+)/",
         "type": "prim_event",
         "vars": ["title"]
      }},
      "post": {
         "cons": [null],
         "type": null
      },
      "pre": [
         {
            "lhs": "toSearch",
            "rhs": {
               "args": [
                  {
                     "type": "str",
                     "val": "http://www.blockbuster.com/browse/search/product/products/?keyword="
                  },
                  {
                     "type": "var",
                     "val": "title"
                  }
               ],
               "op": "+",
               "type": "prim"
            },
            "type": "expr"
         },
         {
            "lhs": "queryBase",
            "rhs": " \nq=select%20*%20from%20html%20where%20url%3D'\n ",
            "type": "here_doc"
         },
         {
            "lhs": "queryEnd",
            "rhs": " \n'&format=json&callback=&diagnostics=off\n ",
            "type": "here_doc"
         }
      ],
      "state": "inactive"
   }],
   "ruleset_name": "a41x22"
}
