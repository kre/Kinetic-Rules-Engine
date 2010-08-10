{
   "dispatch": [
      {"domain": "tearstone.com"},
      {"domain": "baconsalt.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nSingle Notification App     \n",
      "logging": "on",
      "name": "Tutorial"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Hello World"
               },
               {
                  "type": "str",
                  "val": "Everything should taste like bacon"
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
         "name": "my_first_rule",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://baconsalt.com/",
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
                     "val": "opacity .4"
                  }
               ],
               "modifiers": [
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 0.4
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
                     "name": "pos",
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
                     "val": "I waited 2 seconds to show up"
                  }
               ],
               "modifiers": [
                  {
                     "name": "delay",
                     "value": {
                        "type": "num",
                        "val": 2
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
                     "val": "I waited 3 seconds to show up"
                  }
               ],
               "modifiers": [
                  {
                     "name": "delay",
                     "value": {
                        "type": "num",
                        "val": 3
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
         "name": "tearstone",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://tearstone.com/shop/",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      }
   ],
   "ruleset_name": "a405x1"
}
