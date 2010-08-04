{
   "dispatch": [
      {"domain": "www.barackobama.com/issues/healthcare"},
      {"domain": "www.whitehouse.gov"},
      {"domain": "www.google.com"},
      {"domain": "www.yahoo.com"},
      {"domain": "www.bing.com"}
   ],
   "global": [
      {
         "cachable": {
            "period": "seconds",
            "value": "5"
         },
         "datatype": "JSON",
         "name": "ourVoiceSearch",
         "source": "http://www.caandb.com/kynetx/ourvoice.php?op=get&page=",
         "type": "datasource"
      },
      {
         "content": ".kGrowl-notification a { color: #0099CC; }    \t    \t.kGrowl-notification { color: #737373; }    \t    \t.KOBJ_ourVoice_item { margin: 10px; border-bottom: 1px dashed #D2DADA; padding-bottom: 10px; }        \t#KOBJ_ourVoice_list { list-style-position:outside; margin: 0; padding: 0; list-style-type: none; list-style-image: none; }        \t.KOBJ_ourVoice_div { height: 250px; overflow-x: auto; overflow-y: auto; }        \t#KOBJ_ourVoice_logo { background-image: url(\"http://www.frameaction.com/myvoice/images/header_ourvoice.jpg\"); height: 70px; display: block; margin-bottom: 10px; }    \t            #myvoice a:link {    color:#ffffff;    text-decoration:none;    }    #myvoice a:visited {    color:#ffffff;    text-decoration:none;    }    #myvoice a:hover {    color:#ffffff;    text-decoration:none;    }    #myvoice a:active {    color:#ffffff;    text-decoration:none;    }    #myvoice a:linked {    color:#ffffff;    text-decoration:none;    }            #KOBJ_anno_list {        \tleft: 120px;    \tposition: relative;        }        ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Danny DeBate",
      "logging": "on",
      "name": "My Voice"
   },
   "rules": [{
      "actions": null,
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "box",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "post": {
         "cons": [null],
         "type": null
      },
      "pre": [
         {
            "lhs": "url",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "caller"
               }],
               "predicate": "env",
               "source": "page",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "domain",
            "rhs": null,
            "type": "expr"
         }
      ],
      "state": "inactive"
   }],
   "ruleset_name": "a41x52"
}
