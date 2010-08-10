{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "josbank.com"}
   ],
   "global": [{
      "lhs": "acxiomChicago",
      "rhs": {
         "type": "hashraw",
         "val": [
            {
               "lhs": "shadesmith.com",
               "rhs": {
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "phone",
                        "rhs": {
                           "type": "str",
                           "val": "6302261249"
                        }
                     },
                     {
                        "lhs": "badgeRequired",
                        "rhs": {
                           "type": "bool",
                           "val": "true"
                        }
                     },
                     {
                        "lhs": "couponCode",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     }
                  ]
               }
            },
            {
               "lhs": "josbank.com",
               "rhs": {
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "name",
                        "rhs": {
                           "type": "str",
                           "val": "Jos A. Bank Clothiers"
                        }
                     },
                     {
                        "lhs": "phone",
                        "rhs": {
                           "type": "str",
                           "val": "8002852265"
                        }
                     },
                     {
                        "lhs": "badgeRequired",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     },
                     {
                        "lhs": "couponCode",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     }
                  ]
               }
            },
            {
               "lhs": "chicagoskinsolutions.com",
               "rhs": {
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "name",
                        "rhs": {
                           "type": "str",
                           "val": "Chicago Skin Solutions"
                        }
                     },
                     {
                        "lhs": "phone",
                        "rhs": {
                           "type": "str",
                           "val": "3122177546"
                        }
                     },
                     {
                        "lhs": "badgeRequired",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     },
                     {
                        "lhs": "couponCode",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     }
                  ]
               }
            },
            {
               "lhs": "premierdesigns.com",
               "rhs": {
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "phone",
                        "rhs": {
                           "type": "str",
                           "val": "7733014024"
                        }
                     },
                     {
                        "lhs": "badgeRequired",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     },
                     {
                        "lhs": "couponCode",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     }
                  ]
               }
            },
            {
               "lhs": "wisdells.com",
               "rhs": {
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "phone",
                        "rhs": {
                           "type": "str",
                           "val": "6082544636"
                        }
                     },
                     {
                        "lhs": "badgeRequired",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     },
                     {
                        "lhs": "couponCode",
                        "rhs": {
                           "type": "str",
                           "val": "acx602"
                        }
                     }
                  ]
               }
            },
            {
               "lhs": "elkgrovemarathon.com",
               "rhs": {
                  "type": "hashraw",
                  "val": [
                     {
                        "lhs": "phone",
                        "rhs": {
                           "type": "str",
                           "val": "8473010058"
                        }
                     },
                     {
                        "lhs": "badgeRequired",
                        "rhs": {
                           "type": "bool",
                           "val": "true"
                        }
                     },
                     {
                        "lhs": "couponCode",
                        "rhs": {
                           "type": "bool",
                           "val": "false"
                        }
                     }
                  ]
               }
            }
         ]
      },
      "type": "expr"
   }],
   "meta": {
      "logging": "off",
      "name": "myAcxiom"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "acxiom_search"
            }],
            "modifiers": null,
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction acxiom_search(obj){    try {      var entryURL = $K(obj).find(\"span.url, cite\").text();      var host = KOBJ.get_host(entryURL).replace(/^www\\./,\"\");    KOBJ.log(host);    var o = acxiomChicago[host];      if(!o){    \to = acxiomChicago[\"www.\" + host];    }      if(o) {       KOBJ.log(o);       return '<a href=\"http://'+ host +'\"><img src=\"http://www.acxiom.com/Style%20Library/Images/acxiom/LOGO_HomeAcxiom.gif\" style=\"border: none; position: relative; left: 75px;\"><\/a>';    } else {      return false;    }        } catch(e) {      }        };            ",
         "foreach": [],
         "name": "chicago",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|yahoo.com",
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
                  "val": "Acxiom Discount!"
               },
               {
                  "type": "var",
                  "val": "msgBadge"
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
         "callbacks": null,
         "cond": {
            "type": "var",
            "val": "badge"
         },
         "emit": null,
         "foreach": [],
         "name": "josbankbadge",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.josbank.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "domain",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "domain"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msgBadge",
               "rhs": " \n<div id=\"AcxiomDiscount\">  \t\t\t\t<div style=\"float: left;\">  \t\t\t\t\t<img src=\"http://www.acxiom.com/Style%20Library/Images/acxiom/LOGO_HomeAcxiom.gif\" alt=\"Acxiom Logo\" />  \t\t\t\t<\/div>  \t\t\t\t<div>There is a discount available here, at #{acxiomChicago[domain].name}. You do need to present your Acxiom Badge when asking for the discount, and no coupon code is required.  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\n ",
               "type": "here_doc"
            },
            {
               "lhs": "msgNoBadge",
               "rhs": " \n<div id=\"AcxiomDiscount\">  \t\t\t\t<div style=\"float: left;\">  \t\t\t\t\t<img src=\"http://www.acxiom.com/Style%20Library/Images/acxiom/LOGO_HomeAcxiom.gif\" alt=\"Acxiom Logo\" />  \t\t\t\t<\/div>  \t\t\t\t<div>There is a discount available here, at #{acxiomChicago[domain].name}. You do NOT need to present your Acxiom Badge when asking for the discount, and no coupon code is required.  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\n ",
               "type": "here_doc"
            },
            {
               "lhs": "badge",
               "rhs": {
                  "args": [{
                     "args": [
                        {
                           "type": "str",
                           "val": "$.."
                        },
                        {
                           "args": [
                              {
                                 "type": "str",
                                 "val": "www."
                              },
                              {
                                 "args": [
                                    {
                                       "type": "var",
                                       "val": "domain"
                                    },
                                    {
                                       "type": "str",
                                       "val": ".badge"
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
                     "op": "+",
                     "type": "prim"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "acxiomChicago"
                  },
                  "type": "operator"
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
                  "val": "Acxiom Discount!"
               },
               {
                  "type": "var",
                  "val": "msgNoBadge"
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
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "josbanknobadge",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.josbank.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "domain",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "domain"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msgBadge",
               "rhs": " \n<div id=\"AcxiomDiscount\" style=\"padding: 7px; background-color: white; color: black; font-size: 18px; text-align: center;\">  \t\t\t\t<div style=\"float: center;\">  \t\t\t\t\t<img src=\"http://www.acxiom.com/Style%20Library/Images/acxiom/LOGO_HomeAcxiom.gif\" alt=\"Acxiom Logo\" />  \t\t\t\t<\/div>  \t\t\t\t<div>There is a discount available at #{acxiomChicago[domain].name}. You do need to present your Acxiom Badge when asking for the discount, and no coupon code is required.  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\n ",
               "type": "here_doc"
            },
            {
               "lhs": "msgNoBadge",
               "rhs": " \n<div id=\"AcxiomDiscount\" style=\"padding: 7px; background-color: white; color: black; font-size: 18px; text-align: center;\">  \t\t\t\t<div style=\"float: center;\">  \t\t\t\t\t<img src=\"http://www.acxiom.com/Style%20Library/Images/acxiom/LOGO_HomeAcxiom.gif\" />  \t\t\t\t<\/div>  \t\t\t\t<div>There is a discount available at #{acxiomChicago[domain].name}. You do NOT need to present your Acxiom Badge when asking for the discount, and no coupon code is required.  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\n ",
               "type": "here_doc"
            },
            {
               "lhs": "badge",
               "rhs": {
                  "args": [{
                     "args": [
                        {
                           "type": "str",
                           "val": "$.."
                        },
                        {
                           "args": [
                              {
                                 "type": "str",
                                 "val": "www."
                              },
                              {
                                 "args": [
                                    {
                                       "type": "var",
                                       "val": "domain"
                                    },
                                    {
                                       "type": "str",
                                       "val": ".badge"
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
                     "op": "+",
                     "type": "prim"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "acxiomChicago"
                  },
                  "type": "operator"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a41x73"
}
