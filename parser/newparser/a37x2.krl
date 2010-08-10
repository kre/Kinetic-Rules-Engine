{
   "dispatch": [
      {"domain": "amazon.com"},
      {"domain": "barnesandnoble.com"},
      {"domain": "borders.com"}
   ],
   "global": [{
      "cachable": 0,
      "datatype": "JSON",
      "name": "library_search",
      "source": "http://www.azigo.com/utils/library_proxy.html?",
      "type": "datasource"
   }],
   "meta": {
      "description": "\nMLN Rule with OCLC lookup     \n",
      "logging": "on",
      "name": "MLN OCLC"
   },
   "rules": [
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
         "name": "booknotficationamazon",
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
         "name": "booknotficationborders",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(sku=)(\\d+)",
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
               "rhs": " \n<style type=\"text/css\" media=\"screen\">    .mln_round {  \tcursor:pointer;   \tcursor:hand;   \tline-height:20px;  \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat right top;   \tpadding-right:16px;   \tvertical-align:middle;  \tdisplay:block;   \tdisplay:inline-block;   \tdisplay:-moz-inline-box;    }    .mln_round span {   \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat left top;  \theight:21px;  \tdisplay:block;  \tdisplay:inline-block;  \tpadding-left:16px; line-height:20px;  }  \ta.mln_round {color:#FFF !important; font-size:90%; font-weight:bold; text-decoration:none;}  \ta.mln_round:visited {color:#FFF !important;}  \ta.mln_round:visited span {color:#FFF !important;}  \ta.mln_round:hover {background-position:right -21px;}  \ta.mln_round:hover span {background-position:left -21px;}  \t\t      <\/style>  <div style=\"margin-top: 5px; opacity: 1.0; padding: 10px; -moz-border-radius: 5px; background-color: #FFF; color:#000; text-align: center;\">  <img src=\"http://www.azigo.com/sales-demo/mln_logo.png\">  <p style=\"text-align:left; margin-top: 5px;\">#{title}<\/p>  <p><a href=\"#{url}\" class=\"mln_round\"><span>Check Catalog<\/span><\/a><\/p>  <\/div>  \n ",
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
         "name": "booknotficationbn",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(/e/)(\\d+)/",
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
               "rhs": " \n<style type=\"text/css\" media=\"screen\">    .mln_round {  \tcursor:pointer;   \tcursor:hand;   \tline-height:20px;  \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat right top;   \tpadding-right:16px;   \tvertical-align:middle;  \tdisplay:block;   \tdisplay:inline-block;   \tdisplay:-moz-inline-box;    }    .mln_round span {   \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat left top;  \theight:21px;  \tdisplay:block;  \tdisplay:inline-block;  \tpadding-left:16px; line-height:20px;  }  \ta.mln_round {color:#FFF !important; font-size:90%; font-weight:bold; text-decoration:none;}  \ta.mln_round:visited {color:#FFF !important;}  \ta.mln_round:visited span {color:#FFF !important;}  \ta.mln_round:hover {background-position:right -21px;}  \ta.mln_round:hover span {background-position:left -21px;}  \t\t      <\/style>  <div style=\"margin-top: 5px; opacity: 1.0; padding: 10px; -moz-border-radius: 5px; background-color: #FFF; color:#000; text-align: center;\">  <img src=\"http://www.azigo.com/sales-demo/mln_logo.png\">  <p style=\"text-align:left; margin-top: 5px;\">#{title}<\/p>  <p><a href=\"#{url}\" class=\"mln_round\"><span>Check Catalog<\/span><\/a><\/p>  <\/div>  \n ",
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
         "name": "booknotficationbnisbnsearch",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(ean=)(\\d+)",
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
               "rhs": " \n<style type=\"text/css\" media=\"screen\">    .mln_round {  \tcursor:pointer;   \tcursor:hand;   \tline-height:20px;  \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat right top;   \tpadding-right:16px;   \tvertical-align:middle;  \tdisplay:block;   \tdisplay:inline-block;   \tdisplay:-moz-inline-box;    }    .mln_round span {   \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat left top;  \theight:21px;  \tdisplay:block;  \tdisplay:inline-block;  \tpadding-left:16px; line-height:20px;  }  \ta.mln_round {color:#FFF !important; font-size:90%; font-weight:bold; text-decoration:none;}  \ta.mln_round:visited {color:#FFF !important;}  \ta.mln_round:visited span {color:#FFF !important;}  \ta.mln_round:hover {background-position:right -21px;}  \ta.mln_round:hover span {background-position:left -21px;}  \t\t      <\/style>  <div style=\"margin-top: 5px; opacity: 1.0; padding: 10px; -moz-border-radius: 5px; background-color: #FFF; color:#000; text-align: center;\">  <img src=\"http://www.azigo.com/sales-demo/mln_logo.png\">  <p style=\"text-align:left; margin-top: 5px;\">#{title}<\/p>  <p><a href=\"#{url}\" class=\"mln_round\"><span>Check Catalog<\/span><\/a><\/p>  <\/div>  \n ",
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
      }
   ],
   "ruleset_name": "a37x2"
}
