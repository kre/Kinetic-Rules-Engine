{
   "dispatch": [
      {"domain": "geekandpoke.typepad.com"},
      {"domain": "facebook.com"},
      {"domain": "cnn.com"},
      {"domain": "abcnews.go.com"},
      {"domain": "cnet.com"},
      {"domain": "google.com"}
   ],
   "global": [
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "rss",
         "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=95d74922e08d59eb37b6fdf17854d3ea&_render=json",
         "type": "dataset"
      },
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "comic",
         "source": "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fgeekandpoke.typepad.com%2F%22%20and%20xpath%3D%22%2F%2Fdiv%5B%40class%3D'entry-body'%5D%2F%2Fimg%22%20limit%201&format=json&diagnostics=false&callback=",
         "type": "dataset"
      },
      {
         "content": "#geekandpoke_notify img { width: 234px; }      #geekandpoke_notify p a { color:white; font-size:18px; }              #cnn_toptstmparea { height: 175px; }      #geekandpoke_cnn * { float: left; }      #geekandpoke_cnn img { height: 150px; }      #geekandpoke_cnn { padding-left: 125px; }      #geekandpoke_cnn h1 {         font-size: 33px;         color:black;        padding: 64px 0 0 32px;      }              #dynamicHL { height: 100px }      #dynamicHL #geekandpoke { padding: 0 0 0 156px; }      #dynamicHL #geekandpoke img { height: 100px; }      #dynamicHL #geekandpoke img, #dynamicHL #geekandpoke h2 { float: left }      #dynamicHL #geekandpoke p { padding-top: 35px; }      #dynamicHL #geekandpoke a {         font-size: 30px;         color:black;      }    ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Mike Grace",
      "description": "\nBringing Geek & Poke to you!     \n",
      "logging": "on",
      "name": "Geek and Poke"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "The latest Geek and Poke!"
               },
               {
                  "type": "var",
                  "val": "comic"
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
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "success_link"
         }]},
         "cond": {
            "args": [
               {
                  "args": [
                     {
                        "type": "var",
                        "val": "count"
                     },
                     {
                        "type": "num",
                        "val": 1
                     }
                  ],
                  "op": "==",
                  "type": "ineq"
               },
               {
                  "domain": "ent",
                  "expr": {
                     "type": "num",
                     "val": 2
                  },
                  "ineq": "<",
                  "timeframe": "hours",
                  "type": "persistent_ineq",
                  "var": "show_count",
                  "within": {
                     "type": "num",
                     "val": 14
                  }
               }
            ],
            "op": "&&",
            "type": "pred"
         },
         "emit": null,
         "foreach": [],
         "name": "google",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "action": "iterator",
               "domain": "ent",
               "from": {
                  "type": "num",
                  "val": 1
               },
               "name": "show_count",
               "op": "+=",
               "type": "persistent",
               "value": {
                  "type": "num",
                  "val": 1
               }
            }],
            "type": "fired"
         },
         "pre": [
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
                     "val": "rss"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "link",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items[0].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "rss"
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
                     "val": "$.query.results.img.alt"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "comic"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "image",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.img.src"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "comic"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "comic",
               "rhs": " \n<div id='geekandpoke_notify'>        <a href=\"#{link}\" class=\"success_link\"><p>#{title}<\/p>        <a href=\"#{link}\" class=\"success_link\"><img src=\"#{image}\"/><\/a>      <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#cnn_toptstmparea"
               },
               {
                  "type": "var",
                  "val": "comic"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "success_link"
         }]},
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "cnn",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "cnn.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "link",
               "rhs": {
                  "type": "str",
                  "val": "http://geekandpoke.typepad.com/"
               },
               "type": "expr"
            },
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.img.alt"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "comic"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "image",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.img.src"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "comic"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "comic",
               "rhs": " \n<div id='geekandpoke_cnn'>        <a href=\"#{link}\" class=\"success_link\"><img src=\"#{image}\"/><\/a>        <a href=\"#{link}\" class=\"success_link\"><h1>Geek And Poke does it again with #{title}!<\/h1>      <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#dynamicHL"
               },
               {
                  "type": "var",
                  "val": "comic"
               }
            ],
            "modifiers": null,
            "name": "replace_inner",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "success_link"
         }]},
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "cnet",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "cnet.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "link",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items[0].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "rss"
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
                     "val": "$.query.results.img.alt"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "comic"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "image",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.img.src"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "comic"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "comic",
               "rhs": " \n<div id='geekandpoke'>        <a href=\"#{link}\" class=\"success_link\"><img src=\"#{image}\"/><\/a>        <a href=\"#{link}\" class=\"success_link\"><p>Geek And Poke does it again with #{title}!<\/p>      <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x38"
}
