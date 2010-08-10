{
   "dispatch": [
      {"domain": "imdb.com"},
      {"domain": "rottentomatoes.com"},
      {"domain": "facebook.com"},
      {"domain": "tomcruisefan.com"}
   ],
   "global": [],
   "meta": {
      "author": "Jessie JAM Morris",
      "keys": {"amazon": {
         "associate_id": "confetantiqub-20",
         "secret_key": "eQsLYXcHtov81F6TONG17Le84+l8mQ9t1fWgt6Ua",
         "token": "AKIAJZVN6HIAZYCHYLQA"
      }},
      "logging": "off",
      "name": "IMDB Amazon"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Amazon!!"
               },
               {
                  "type": "var",
                  "val": "amazon_message"
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
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 0.9
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
                  "type": "var",
                  "val": "price"
               },
               {
                  "type": "array",
                  "val": []
               }
            ],
            "op": "neq",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [],
         "name": "title",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.imdb.com/title/(\\w+)/",
            "type": "prim_event",
            "vars": ["title_id"]
         }},
         "pre": [
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "title"
                  }],
                  "predicate": "env",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "title",
               "rhs": {
                  "args": [
                     {
                        "args": null,
                        "name": null,
                        "obj": {
                           "type": "var",
                           "val": "title"
                        },
                        "type": "operator"
                     },
                     {
                        "args": [
                           {
                              "args": null,
                              "name": null,
                              "obj": null,
                              "type": "operator"
                           },
                           {
                              "args": [
                                 null,
                                 {
                                    "args": [
                                       null,
                                       {
                                          "args": [
                                             null,
                                             {
                                                "args": [
                                                   null,
                                                   null
                                                ],
                                                "op": "/",
                                                "type": "prim"
                                             }
                                          ],
                                          "op": "*",
                                          "type": "prim"
                                       }
                                    ],
                                    "op": "+",
                                    "type": "prim"
                                 }
                              ],
                              "op": "+",
                              "type": "prim"
                           }
                        ],
                        "op": "*",
                        "type": "prim"
                     }
                  ],
                  "op": "/",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_data",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "index",
                           "rhs": {
                              "type": "str",
                              "val": "dvd"
                           }
                        },
                        {
                           "lhs": "title",
                           "rhs": {
                              "type": "var",
                              "val": "title"
                           }
                        }
                     ]
                  }],
                  "predicate": "item_search",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "dvd",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item[0]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "amazon_data"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "asin",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.ASIN"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "dvd"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "details",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "item_id",
                           "rhs": {
                              "type": "var",
                              "val": "asin"
                           }
                        },
                        {
                           "lhs": "response_group",
                           "rhs": {
                              "type": "array",
                              "val": [{
                                 "type": "str",
                                 "val": "Medium"
                              }]
                           }
                        }
                     ]
                  }],
                  "predicate": "item_lookup",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "image_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.LargeImage.URL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "page_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.DetailPageURL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
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
                     "val": "$..Item.ItemAttributes.Title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "price",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.OfferSummary.LowestNewPrice.FormattedPrice"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_message",
               "rhs": " \n<div style=\"color: white; text-align: center;\">  \t\t\t<a href=\"#{page_url}\" target=\"_blank\">  \t\t\t\t<img src=\"#{image_url}\" alt=\"#{title} Photo\" style=\"width: 200px; margin: 5px 0px;\" />  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<a href=\"#{page_url}\" target=\"_blank\" style=\"color: white;\">  \t\t\t\tAvailable new starting at #{price}.  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<div alt=\"Buy Now!\" style=\"margin: 5px auto; width: 160px; height: 23px; background-image: url(http:\\/\\/kynetx-images.s3.amazonaws.com/amazon_button.png); font-size: 14pt; text-align: center; color: #003399; cursor: pointer;\" onclick=\"location.href='#{page_url}';\">  \t\t\t\tBuy Now!  \t\t\t<\/div>    \t\n ",
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
                  "val": "Amazon!!"
               },
               {
                  "type": "var",
                  "val": "amazon_message"
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
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 0.9
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
                  "type": "var",
                  "val": "price"
               },
               {
                  "type": "array",
                  "val": []
               }
            ],
            "op": "neq",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [],
         "name": "name",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.imdb.com/name/(\\w+)/",
            "type": "prim_event",
            "vars": ["name_id"]
         }},
         "pre": [
            {
               "lhs": "actor",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "title"
                  }],
                  "predicate": "env",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "actor",
               "rhs": {
                  "args": [
                     {
                        "args": null,
                        "name": null,
                        "obj": {
                           "type": "var",
                           "val": "actor"
                        },
                        "type": "operator"
                     },
                     {
                        "args": [
                           {
                              "args": null,
                              "name": null,
                              "obj": null,
                              "type": "operator"
                           },
                           {
                              "args": [
                                 null,
                                 {
                                    "args": [
                                       null,
                                       {
                                          "args": [
                                             null,
                                             {
                                                "args": [
                                                   null,
                                                   null
                                                ],
                                                "op": "/",
                                                "type": "prim"
                                             }
                                          ],
                                          "op": "*",
                                          "type": "prim"
                                       }
                                    ],
                                    "op": "+",
                                    "type": "prim"
                                 }
                              ],
                              "op": "+",
                              "type": "prim"
                           }
                        ],
                        "op": "*",
                        "type": "prim"
                     }
                  ],
                  "op": "/",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_data",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "index",
                           "rhs": {
                              "type": "str",
                              "val": "dvd"
                           }
                        },
                        {
                           "lhs": "actor",
                           "rhs": {
                              "type": "var",
                              "val": "actor"
                           }
                        }
                     ]
                  }],
                  "predicate": "item_search",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "dvd",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item[0]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "amazon_data"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "asin",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.ASIN"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "dvd"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "details",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "item_id",
                           "rhs": {
                              "type": "var",
                              "val": "asin"
                           }
                        },
                        {
                           "lhs": "response_group",
                           "rhs": {
                              "type": "array",
                              "val": [{
                                 "type": "str",
                                 "val": "Medium"
                              }]
                           }
                        }
                     ]
                  }],
                  "predicate": "item_lookup",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "image_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.LargeImage.URL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "page_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.DetailPageURL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
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
                     "val": "$..Item.ItemAttributes.Title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "price",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.OfferSummary.LowestNewPrice.FormattedPrice"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_message",
               "rhs": " \n<div style=\"color: white; text-align: center;\">  \t\t\t<a href=\"#{page_url}\" target=\"_blank\">  \t\t\t\t<img src=\"#{image_url}\" alt=\"#{title} Photo\" style=\"width: 200px; margin: 5px 0px;\" />  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<a href=\"#{page_url}\" target=\"_blank\" style=\"color: white;\">  \t\t\t\tAvailable new starting at #{price}.  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<div alt=\"Buy Now!\" style=\"margin: 5px auto; width: 160px; height: 23px; background-image: url(http:\\/\\/kynetx-images.s3.amazonaws.com/amazon_button.png); font-size: 14pt; text-align: center; color: #003399; cursor: pointer;\" onclick=\"location.href='#{page_url}';\">  \t\t\t\tBuy Now!  \t\t\t<\/div>    \t\n ",
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
                  "val": "Amazon!!"
               },
               {
                  "type": "var",
                  "val": "amazon_message"
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
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 0.9
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
                  "type": "var",
                  "val": "price"
               },
               {
                  "type": "array",
                  "val": []
               }
            ],
            "op": "neq",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [],
         "name": "tom_cruise_facebook",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com/officialtomcruise|http://www.tomcruisefan.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "random",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 5
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_data",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "index",
                           "rhs": {
                              "type": "str",
                              "val": "dvd"
                           }
                        },
                        {
                           "lhs": "actor",
                           "rhs": {
                              "type": "str",
                              "val": "Tom Cruise"
                           }
                        }
                     ]
                  }],
                  "predicate": "item_search",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "dvd",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item[#{random}]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "amazon_data"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "asin",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.ASIN"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "dvd"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "details",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "item_id",
                           "rhs": {
                              "type": "var",
                              "val": "asin"
                           }
                        },
                        {
                           "lhs": "response_group",
                           "rhs": {
                              "type": "array",
                              "val": [{
                                 "type": "str",
                                 "val": "Medium"
                              }]
                           }
                        }
                     ]
                  }],
                  "predicate": "item_lookup",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "image_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.LargeImage.URL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "page_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.DetailPageURL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
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
                     "val": "$..Item.ItemAttributes.Title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "price",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.OfferSummary.LowestNewPrice.FormattedPrice"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_message",
               "rhs": " \n<div style=\"color: white; text-align: center;\">  \t\t\t<a href=\"#{page_url}\" target=\"_blank\">  \t\t\t\t<img src=\"#{image_url}\" alt=\"#{title} Photo\" style=\"width: 200px; margin: 5px 0px;\" />  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<a href=\"#{page_url}\" target=\"_blank\" style=\"color: white;\">  \t\t\t\tAvailable new starting at #{price}.  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<div alt=\"Buy Now!\" style=\"margin: 5px auto; width: 160px; height: 23px; background-image: url(http:\\/\\/kynetx-images.s3.amazonaws.com/amazon_button.png); font-size: 14pt; text-align: center; color: #003399; cursor: pointer;\" onclick=\"location.href='#{page_url}';\">  \t\t\t\tBuy Now!  \t\t\t<\/div>    \t\n ",
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
                  "val": "Amazon!!"
               },
               {
                  "type": "var",
                  "val": "amazon_message"
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
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 0.9
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
                  "type": "var",
                  "val": "price"
               },
               {
                  "type": "array",
                  "val": []
               }
            ],
            "op": "neq",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [],
         "name": "wikipedia",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://en.wikipedia.org/wiki/(\\w+)",
            "type": "prim_event",
            "vars": ["keyword"]
         }},
         "pre": [
            {
               "lhs": "page_title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "title"
                  }],
                  "predicate": "env",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "page_title",
               "rhs": null,
               "type": "expr"
            },
            {
               "lhs": "random",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 5
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_data",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "index",
                           "rhs": {
                              "type": "str",
                              "val": "all"
                           }
                        },
                        {
                           "lhs": "keywords",
                           "rhs": {
                              "type": "var",
                              "val": "page_title"
                           }
                        }
                     ]
                  }],
                  "predicate": "item_search",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "dvd",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item[#{random}]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "amazon_data"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "asin",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.ASIN"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "dvd"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "details",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "item_id",
                           "rhs": {
                              "type": "var",
                              "val": "asin"
                           }
                        },
                        {
                           "lhs": "response_group",
                           "rhs": {
                              "type": "array",
                              "val": [{
                                 "type": "str",
                                 "val": "Medium"
                              }]
                           }
                        }
                     ]
                  }],
                  "predicate": "item_lookup",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "image_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.LargeImage.URL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "page_url",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.DetailPageURL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
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
                     "val": "$..Item.ItemAttributes.Title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "price",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Item.OfferSummary.LowestNewPrice.FormattedPrice"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "details"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "amazon_message",
               "rhs": " \n<div style=\"color: white; text-align: center;\">  \t\t\t<a href=\"#{page_url}\" target=\"_blank\">  \t\t\t\t<img src=\"#{image_url}\" alt=\"#{title} Photo\" style=\"width: 200px; margin: 5px 0px;\" />  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<a href=\"#{page_url}\" target=\"_blank\" style=\"color: white;\">  \t\t\t\tAvailable new starting at #{price}.  \t\t\t<\/a>  \t\t\t<br />  \t\t\t<div alt=\"Buy Now!\" style=\"margin: 5px auto; width: 160px; height: 23px; background-image: url(http:\\/\\/kynetx-images.s3.amazonaws.com/amazon_button.png); font-size: 14pt; text-align: center; color: #003399; cursor: pointer;\" onclick=\"location.href='#{page_url}';\">  \t\t\t\tBuy Now!  \t\t\t<\/div>    \t\n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a41x96"
}
