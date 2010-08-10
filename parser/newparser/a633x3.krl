{
   "dispatch": [
      {"domain": "espn.go.com"},
      {"domain": "msn.foxsports.com"},
      {"domain": "cbssports.com"},
      {"domain": "sportsillustrated.cnn.com"}
   ],
   "global": [
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "RSS",
         "name": "ESPN_NBA",
         "source": "http://sports.espn.go.com/espn/rss/mlb/news",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "RSS",
         "name": "SI_NBA",
         "source": "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fsportsillustrated.cnn.com%2Fbaseball%2Fmlb%2F%22%20and%20xpath%3D'%2F%2Fdiv%5B%40class%3D%22cnnT2s%22%5D%2Ful%2Fli%2Fa'&format=json&_maxage=3600&callback=",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "RSS",
         "name": "FOX_NBA",
         "source": "http://feeds.pheedo.com/feedout/syndicatedContent_categoryId_49",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "RSS",
         "name": "CBS_NBA",
         "source": "http://cbssports.com/partners/feeds/rss/mlb_news",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "RSS",
         "name": "NBA_NBA",
         "source": "http://mlb.mlb.com/partnerxml/gen/news/rss/mlb.xml",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "RSS",
         "name": "SCHED",
         "source": "http://www.buzzcal.com/rss/",
         "type": "dataset"
      },
      {
         "content": "\n//    #espn-news.background {\n  //    opacity:0.5;\n    //}\n    #espn-news {\n    }   \n    \n    #cids-schedule {\n    }\n    \n    #fox-news {\n    }\n    \n    .our_item {\n      padding-bottom: 5px;\n      font-size : -1;\n      overflow:hidden;\n    };\n    \n    \n    #font-news h2 {\n     font-family: arial, sans-serif;\n     `font-size : +1;\n    }  \n    \n     #cbssports-news {\n    }\n    \n     #si-news {\n    }\n    \n    .cids-accord-header {\n      height: 30px;\n      padding-left:40px;\n    }\n    \n    #cids {\n    font-size: -2;\n    color:black;\n    }\n\n    #cids a {\n     font-family: arial, sans-serif;\n        font-size: 12px;\n      color: white;\n      vertical-align: middle;\n    }\n    \n    .sport-wrapper-div {\n        font-size: 12px;\n        font-family: arial, sans-serif;\n        position:fixed;\n        top: 20px;\n        right: 10px;\n        padding: 1em;\n        z-index: 999999;\n    }\n    .sport-wrapper-div h1  {\n      font-family: arial, sans-serif;\n        font-size: 12px;      \n\t   }\n\n    .sport-wrapper-div h2  {\n      font-family: arial, sans-serif;\n        font-size: 12px;\n      \n\t   }\n    .sport-wrapper-div h3  {\n     font-family: arial, sans-serif;\n        font-size: 12px;\n      \n\t   }\n    .sport-wrapper-div a {\n     font-family: arial, sans-serif;\n        font-size: 12px;\n      \n\t   }\n\n\n  ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Alex Quintero",
      "description": " \n  Show other relevant articles for the sports fanatic.\n  ",
      "keys": {"errorstack": "f781d9b65e45f413592a177b8d79988d"},
      "logging": "off",
      "name": "Sports Inside Out"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "body"
                  },
                  {
                     "type": "var",
                     "val": "espnDiv"
                  }
               ],
               "modifiers": null,
               "name": "append",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "prepare_espn_headlines",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(foxsports|cbssports|sportsillustrated|espn).*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "espnDiv",
            "rhs": "\n      <div class=\"sport-wrapper-div\">\n        <a href=\"#\" id=\"clickthis\">\n          <img src=\"http://www.gettyicons.com/free-icons/108/sport/png/256/baseball_ball_256.png\" width=\"75px\"/>\n        <\/a> \n      <\/div>\n\n        <div id=\"cids\" style=\"display:none; width:100%;\">      \n          <div id=\"cids-accord\">\n                <h3 id=\"espn-news-item-cid\"  class=\"cids-accord-header\"><span style=\"height:20px;padding-top:5px;\">ESPN<\/span><\/h3>\n                  <div id=\"espn-news\"><\/div>\n            <h3 id=\"fox-news-item-cid\" class=\"cids-accord-header\"><span style=\"height:20px;padding-top:5px;\">Fox<\/span><\/h3>\n                  <div id=\"fox-news\"><\/div>\n            <h3 id=\"cbssports-news-item-cid\" class=\"cids-accord-header\"><span style=\"height:20px;padding-top:5px;\">CBS<\/span><\/h3>\n                  <div id=\"cbssports-news\"><\/div>\n            <h3 id=\"si-news-item-cid\" class=\"cids-accord-header\"><span style=\"height:20px;padding-top:5px;\">SI<\/span><\/h3>\n                  <div id=\"si-news\"><\/div>\n            <h3 id=\"schedule-news-item-cid\" class=\"cids-accord-header\"><span style=\"height:20px;padding-top:5px;\">Schedule<\/span><\/h3>\n                  <div id=\"cids-schedule\"><\/div>\n            <h3 id=\"watch-live-item-cid\" class=\"cids-accord-header\"><span style=\"height:20px;padding-top:5px;\">Watch Live<\/span><\/h3>\n                  <div id=\"watch-live\">                  <object width=\"480\" height=\"385\"><param name=\"movie\" value=\"http://www.youtube.com/v/Rg6463aqOyA&hl=en_US&fs=1&color1=0x3a3a3a&color2=0x999999\"><\/param><param name=\"allowFullScreen\" value=\"true\"><\/param><param name=\"allowscriptaccess\" value=\"always\"><\/param><embed src=\"http://www.youtube.com/v/Rg6463aqOyA&hl=en_US&fs=1&color1=0x3a3a3a&color2=0x999999\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"480\" height=\"385\"><\/embed><\/object><\/div>\n                \n          <\/div>\n        <\/div>\n\n      <div style=\"clear:both\"/>\n",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#espn-news"
                  },
                  {
                     "type": "var",
                     "val": "newsItem"
                  }
               ],
               "modifiers": null,
               "name": "append",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..item"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "ESPN_NBA"
               },
               "type": "operator"
            },
            "var": ["item"]
         }]],
         "name": "show_espn_nba_headline",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(foxsports|cbssports|sportsillustrated).*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.title.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
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
                     "val": "$.link.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "newsItem",
               "rhs": "\n        <div class=\"our_item\"><div style=\"float:left;\"><img src=\"http://www.gettyicons.com/free-icons/108/sport/png/256/baseball_ball_256.png\" width=\"20px\"/><\/div><div style=\"float:left\"> &nbsp;&nbsp;&nbsp;<a class=\"unbindusnow\" href=\"#{link}\">#{title}<\/a><\/div><div style=\"clear:both\"><\/div><\/div>\n      ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#espn-news-item-cid"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#espn-news"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "show_espn",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(espn).*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#si-news-item-cid"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#si-news"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "show_is",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(sportsillustrated).*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#cbssports-news-item-cid"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#cbssports-news"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "show_cbs",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(cbssports).*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#fox-news-item-cid"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "#fox-news"
               }],
               "modifiers": null,
               "name": "remove",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "show_fox",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(foxsports).*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#fox-news"
                  },
                  {
                     "type": "var",
                     "val": "newsItem"
                  }
               ],
               "modifiers": null,
               "name": "append",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#fox-news"
                  },
                  {
                     "type": "str",
                     "val": "blind"
                  },
                  {
                     "type": "str",
                     "val": "fast"
                  }
               ],
               "modifiers": null,
               "name": "show",
               "source": "jquery_ui"
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..item"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "FOX_NBA"
               },
               "type": "operator"
            },
            "var": ["item"]
         }]],
         "name": "show_fox_nba_headline",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(cbssports|sportsillustrated|espn).*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.title.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
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
                     "val": "$.link.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "newsItem",
               "rhs": "\n              <div class=\"our_item\"><div style=\"float:left;\"><img src=\"http://www.gettyicons.com/free-icons/108/sport/png/256/baseball_ball_256.png\" width=\"20px\"/><\/div><div style=\"float:left\"> &nbsp;&nbsp;&nbsp;<a class=\"unbindusnow\" href=\"#{link}\">#{title}<\/a><\/div><div style=\"clear:both\"><\/div><\/div>\n        ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#si-news"
                  },
                  {
                     "type": "var",
                     "val": "newsItem"
                  }
               ],
               "modifiers": null,
               "name": "append",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$.query.results..a"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "SI_NBA"
               },
               "type": "operator"
            },
            "var": ["item"]
         }]],
         "name": "show_si_nba_headlines",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(foxsports|cbssports|espn).*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
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
                     "val": "$.href"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "newsItem",
               "rhs": "\n        <div class=\"our_item\"><div style=\"float:left;\"><img src=\"http://www.gettyicons.com/free-icons/108/sport/png/256/baseball_ball_256.png\" width=\"20px\"/><\/div><div style=\"float:left\"> &nbsp;&nbsp;&nbsp;<a class=\"unbindusnow\" href=\"#{link}\">#{title}<\/a><\/div><div style=\"clear:both\"><\/div><\/div>\n      ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#cbssports-news"
                  },
                  {
                     "type": "var",
                     "val": "newsItem"
                  }
               ],
               "modifiers": null,
               "name": "append",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": ".searchField"
               }],
               "modifiers": null,
               "name": "datepicker",
               "source": "jquery_ui"
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..item"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "CBS_NBA"
               },
               "type": "operator"
            },
            "var": ["item"]
         }]],
         "name": "show_cbs_nba_headlines",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(foxsports|sportsillustrated|espn).*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.title.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
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
                     "val": "$.link.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "newsItem",
               "rhs": "\n        <div class=\"our_item\"><div style=\"float:left;\"><img src=\"http://www.gettyicons.com/free-icons/108/sport/png/256/baseball_ball_256.png\" width=\"20px\"/><\/div><div style=\"float:left\"> &nbsp;&nbsp;&nbsp;<a class=\"unbindusnow\" href=\"#{link}\">#{title}<\/a><\/div><div style=\"clear:both\"><\/div><\/div>\n      ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": null,
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..item"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "SCHED"
               },
               "type": "operator"
            },
            "var": ["item"]
         }]],
         "name": "show_cbs_nba_headlines",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)(foxsports|cbssports|sportsillustrated|espn).*",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [null],
            "type": null
         },
         "state": "active"
      }
   ],
   "ruleset_name": "a633x3"
}
