{
   "dispatch": [{"domain": "kynetx.com"}],
   "global": [{
      "content": "\n      #kacss * {\n      margin: 0;\n      padding: 0;\n      border: 0;\n      outline: 0;\n      font-size:24px;\n      font-size: 100%;\n      font-weight:normal;\n      vertical-align: baseline;\n      background: transparent;\n      color: #000;\n      font-family:arial,sans-serif;\n      direction: ltr;\n      line-height: 1;\n      letter-spacing: normal;\n      text-align: left; \n      text-decoration: none;\n      text-indent: 0;\n      text-shadow: none;\n      text-transform: none;\n      vertical-align: baseline;\n      white-space: normal;\n      word-spacing: normal;\n      font: normal normal normal medium/1 sans-serif ;\n      list-style: none;\n      clear: none;\n      }\n  \n      #kacss h1 {\n        font-size: 100px;\n        float: left;\n      }\n  \n      #kacss #newbie {\n        font-size: 32px;\n      }\n      \n      #kacss #mike {\n        color:#2978BD;\n        font-size:41px;\n      }\n      \n      #kacss #build, #blog, #marketplace, #help {\n        font-size:20px;\n        padding:10px;\n        width: 600px;\n      }\n      \n      /* make containing div relative so I can put my arrow where I want it. */\n      #welcome {\n        position: relative;\n      }\n      #arrow {\n        position:absolute;\n        right:295px;\n        top:9px;\n      }\n      #blog-arrow {\n        position:absolute;\n        right:337px;\n        top:104px;\n      }\n      #marketplace-arrow {\n        position:absolute;\n        right:337px;\n        top:194px;\n      }\n      #help-me {\n        left:13px;\n        position:absolute;\n        top:2px;\n      }\n      #help a {\n        text-decoration: underline;\n        color: #2978BD;\n        font-size: 24px;\n      }\n    ",
      "type": "css"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Helping newbies get their bearings and get started in the right direction.\n    ",
      "logging": "on",
      "name": "AppBuilder Butler"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#welcome"
               },
               {
                  "type": "var",
                  "val": "hi"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 3
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "newbie"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 4
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 5
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 5.2
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 5.6
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "photo"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.3
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.4
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.5
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.6
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.7
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.8
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#mike"
               },
               {
                  "type": "var",
                  "val": "avatar"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 6.9
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 8
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 8.2
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 8.8
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "build"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 9
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#welcome"
               },
               {
                  "type": "var",
                  "val": "arrow"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 9.5
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 11
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 11.5
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#arrow"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 13
               }
            }],
            "name": "replace_html",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "blog"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 13.5
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#welcome"
               },
               {
                  "type": "var",
                  "val": "blogArrow"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 14
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 15
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#blog-arrow"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 18
               }
            }],
            "name": "replace_html",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "marketplace"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 18
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#welcome"
               },
               {
                  "type": "var",
                  "val": "marketplaceArrow"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 18.5
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "spacer"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 21
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#marketplace-arrow"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 24
               }
            }],
            "name": "replace_html",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#kacss"
               },
               {
                  "type": "var",
                  "val": "help"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 24
               }
            }],
            "name": "prepend",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.1
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.2
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.3
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.4
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.5
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.6
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.7
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.8
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 25.9
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "str",
                  "val": "."
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 26
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#welcome"
               },
               {
                  "type": "var",
                  "val": "helpImg"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 26.8
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help"
               },
               {
                  "type": "var",
                  "val": "remainingHelp"
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 28
               }
            }],
            "name": "append",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#help-me"
               },
               {
                  "type": "str",
                  "val": ""
               }
            ],
            "modifiers": [{
               "name": "delay",
               "value": {
                  "type": "num",
                  "val": 35
               }
            }],
            "name": "replace_html",
            "source": null
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
      "name": "introduction",
      "pagetype": {
         "event_expr": {
            "domain": "web",
            "op": "pageview",
            "pattern": "kynetx.com",
            "type": "prim_event",
            "vars": []
         },
         "foreach": []
      },
      "pre": [
         {
            "lhs": "hi",
            "rhs": "\n        <br class=\"clear\"/>\n        <div id=\"kacss\">\n          <h1>HI!<\/h1>\n        <\/div>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "newbie",
            "rhs": "\n        <p id=\"newbie\">Looks like you might be new around these parts.<\/p>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "photo",
            "rhs": "\n        <p id=\"mike\">My name is Mike <\/p>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "avatar",
            "rhs": "\n        <img src=\"https://kynetx-apps.s3.amazonaws.com/appbuilder-butler/mikegrace.jpg\"/>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "spacer",
            "rhs": "  <br/>  ",
            "type": "here_doc"
         },
         {
            "lhs": "build",
            "rhs": "\n        <p id=\"build\">When you want to build cool Kynetx apps like this one, create an account and get started!<\/p>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "arrow",
            "rhs": " <span id=\"arrow\"><img src=\"https://kynetx-apps.s3.amazonaws.com/appbuilder-butler/arrow.png\"/><\/span> ",
            "type": "here_doc"
         },
         {
            "lhs": "blogArrow",
            "rhs": " <span id=\"blog-arrow\"><img src=\"https://kynetx-apps.s3.amazonaws.com/appbuilder-butler/arrow.png\"/><\/span> ",
            "type": "here_doc"
         },
         {
            "lhs": "marketplaceArrow",
            "rhs": " <span id=\"marketplace-arrow\"><img src=\"https://kynetx-apps.s3.amazonaws.com/appbuilder-butler/arrow.png\"/><\/span> ",
            "type": "here_doc"
         },
         {
            "lhs": "blog",
            "rhs": "\n        <p id=\"blog\">Stay up to date w/ the latest on our developer blog<\/p>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "marketplace",
            "rhs": "\n        <p id=\"marketplace\">Find sweet Kynetx apps that have been built in the Marketplace and eventually list your own creations there!<\/p>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "helpImg",
            "rhs": " <span id=\"help-me\"><img src=\"https://kynetx-apps.s3.amazonaws.com/appbuilder-butler/help.jpg\"/><\/span> ",
            "type": "here_doc"
         },
         {
            "lhs": "help",
            "rhs": "\n        <p id=\"help\">and if you ever have trouble building your app<\/p>\n      ",
            "type": "here_doc"
         },
         {
            "lhs": "remainingHelp",
            "rhs": "\n      <br/><br/> you can get LOTS of help over at our developer exchange at <a href=\"http://devex.kynetx.com\">http:\\/\\/devex.kynetx.com<\/a>\n      ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x236"
}
