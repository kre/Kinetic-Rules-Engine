{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "www.azigo.com"},
      {"domain": "amazon.com"}
   ],
   "global": [
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "library_search",
         "source": "http://www.azigo.com/utils/library_proxy.html?",
         "type": "datasource"
      },
      {"emit": "\nvar a=3;    var b=5;    alert(a+b);        function greet(){    \talert('Hello World');    }    greet();                "}
   ],
   "meta": {
      "description": "\nMicronotes Sample     \n",
      "logging": "off",
      "name": "Micronotes Sample"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Hello"
               },
               {
                  "type": "str",
                  "val": "Welcome"
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
         "name": "sample",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.google.com",
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
                  "val": "Sample"
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "width",
                  "value": {
                     "type": "str",
                     "val": "400px"
                  }
               },
               {
                  "name": "height",
                  "value": {
                     "type": "str",
                     "val": "400px"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               }
            ],
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
         "name": "sample2",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<iframe src=\"http://news.yahoo.com\" scrolling=\"auto\" frameborder=\"0\" width=\"100%\" height=\"400px\"/>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n$K('#num').change(function() {       KOBJ.eval({\"rids\"  : [\"a37x9\"], \"a37x9:q\":$K('#num').val()});    });          $K('#num').parent().append(\"<br/><br/>Result: <div id='result' style='color: #ff0000; display: inline'><\/div>\");          ",
         "foreach": [],
         "name": "sample3",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.azigo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "var",
                  "val": "msgtitle"
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": [
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#000"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "args": [{
                     "type": "str",
                     "val": "$..numFound"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "book_data"
                  },
                  "type": "operator"
               },
               {
                  "type": "num",
                  "val": 0
               }
            ],
            "op": ">",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [],
         "name": "sample4_mln",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(/gp/product/|/dp/)(\\d+)/",
            "type": "prim_event",
            "vars": [
               "path",
               "isbn"
            ]
         }},
         "pre": [
            {
               "lhs": "book_data",
               "rhs": {
                  "args": [{
                     "args": [
                        {
                           "type": "str",
                           "val": "q="
                        },
                        {
                           "type": "var",
                           "val": "isbn"
                        }
                     ],
                     "op": "+",
                     "type": "prim"
                  }],
                  "predicate": "library_search",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..docs[0].url"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "book_data"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..docs[0].title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "book_data"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "msg",
               "rhs": " \n<style type=\"text/css\" media=\"screen\">    .mln_round {  \tcursor:pointer;   \tcursor:hand;   \tline-height:20px;  \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat right top;   \tpadding-right:16px;   \tvertical-align:middle;  \tdisplay:block;   \tdisplay:inline-block;   \tdisplay:-moz-inline-box;    }    .mln_round span {   \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat left top;  \theight:21px;  \tdisplay:block;  \tdisplay:inline-block;  \tpadding-left:16px; line-height:20px;  }  \ta.mln_round {color:#FFF !important; font-size:90%; font-weight:bold; text-decoration:none;}  \ta.mln_round:visited {color:#FFF !important;}  \ta.mln_round:visited span {color:#FFF !important;}  \ta.mln_round:hover {background-position:right -21px;}  \ta.mln_round:hover span {background-position:left -21px;}  \t\t      <\/style>  <div style=\"margin-top: 5px; opacity: 1.0; padding: 10px; -moz-border-radius: 5px; background-color: #FFF; color:#000; text-align: center;\">  <img src=\"http://www.azigo.com/sales-demo/mln_logo.png\">  <p style=\"text-align:center; margin-top: 5px;\">#{title}<\/p>  <p><a href=\"#{url}\" class=\"mln_round\"><span>Check Catalog<\/span><\/a><\/p>  <\/div>  \n ",
               "type": "here_doc"
            },
            {
               "lhs": "msgtitle",
               "rhs": {
                  "type": "str",
                  "val": "<img src='http://www.azigo.com/sales-demo/azigo_black_50.png' style='valign:center;'/>Book Title Found at MLN"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Micronotes Survey Title"
               },
               {
                  "type": "str",
                  "val": "Micronotes Survey Content"
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
         "name": "notify_test",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "http://www.cictr.com"
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
         "name": "alert_test",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://news.yahoo.com",
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
                  "val": "absolute"
               },
               {
                  "type": "str",
                  "val": "top: 10px"
               },
               {
                  "type": "str",
                  "val": "right: 10px"
               },
               {
                  "type": "str",
                  "val": "http://www.yahoo.com"
               }
            ],
            "modifiers": [
               {
                  "name": "delay",
                  "value": {
                     "type": "num",
                     "val": 0
                  }
               },
               {
                  "name": "draggable",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "effect",
                  "value": {
                     "type": "str",
                     "val": "appear"
                  }
               }
            ],
            "name": "float",
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
         "name": "float_test",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com",
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
                  "val": "Hello"
               },
               {
                  "type": "str",
                  "val": "Welcome"
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
         "name": "redirect_test",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://news.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "Alert from inside"
            }],
            "modifiers": null,
            "name": "alert",
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
         "name": "yahoo_alert",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a37x8"
}
