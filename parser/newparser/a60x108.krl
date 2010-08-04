{
   "dispatch": [{"domain": "docs.kynetx.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Notify example for documentation     \n    ",
      "logging": "on",
      "name": "Notify Example"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "This is just a plain default notify."
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
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "I'm going to disappear!"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "I'm going to disappear in 5 seconds!"
               }
            ],
            "modifiers": [{
               "name": "life",
               "value": {
                  "type": "num",
                  "val": 5000
               }
            }],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "opacity 1.0"
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
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "default opacity"
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
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "opacity .6"
               }
            ],
            "modifiers": [
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 0.6
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "opacity .2"
               }
            ],
            "modifiers": [
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 0.2
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "I'm on the top-left"
               }
            ],
            "modifiers": [
               {
                  "name": "position",
                  "value": {
                     "type": "str",
                     "val": "top-left"
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "My text is Red!"
               }
            ],
            "modifiers": [
               {
                  "name": "color",
                  "value": {
                     "type": "str",
                     "val": "#FF0000"
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "My background color is Red!"
               }
            ],
            "modifiers": [
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#FF0000"
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "My width is 100px"
               }
            ],
            "modifiers": [
               {
                  "name": "width",
                  "value": {
                     "type": "num",
                     "val": 100
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "My width is 400px"
               }
            ],
            "modifiers": [
               {
                  "name": "width",
                  "value": {
                     "type": "num",
                     "val": 400
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "I waited 1 seconds to show up"
               }
            ],
            "modifiers": [
               {
                  "name": "delay",
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
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Notify"
               },
               {
                  "type": "str",
                  "val": "I waited 4 seconds to show up"
               }
            ],
            "modifiers": [
               {
                  "name": "delay",
                  "value": {
                     "type": "num",
                     "val": 4
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://docs.kynetx.com/krl/kynetx-rule-language-documentation/actions/notify/",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x108"
}
