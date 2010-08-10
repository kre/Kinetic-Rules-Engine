{
   "dispatch": [
      {"domain": "facebook.com"},
      {"domain": "youtube.com"},
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"},
      {"domain": "myspace.com"},
      {"domain": "twitter.com"},
      {"domain": "ksl.com"},
      {"domain": "wikipedia.org"},
      {"domain": "en.wikipedia.com"},
      {"domain": "www.amazon.com"},
      {"domain": "ebay.com"},
      {"domain": "craigslist.org"},
      {"domain": "nba.com"},
      {"domain": "mormontimes.com"},
      {"domain": "deseretnews.com"},
      {"domain": "abc4.com"},
      {"domain": "connect2utah.com"},
      {"domain": "kutv.biz"},
      {"domain": "sltrib.com"},
      {"domain": "hulu.com"}
   ],
   "global": [
      {
         "cachable": {
            "period": "seconds",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "amazonWideSkyscraper",
         "source": "http://ads.grigglee.com/www/delivery/ck.php?n=a418c646&",
         "type": "datasource"
      },
      {
         "lhs": "random",
         "rhs": {
            "args": [{
               "type": "num",
               "val": 9999999
            }],
            "predicate": "random",
            "source": "math",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "verticalBanner",
         "rhs": " \n<div class=\"griggleeAds griggleeVerticalBanner\"><iframe id='a065f422' name='a065f422' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=27&target=_blank&cb=#{random}' framespacing='0' frameborder='no' scrolling='no' width='120' height='240'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=a490953a&cb=#{random}' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=27&cb=#{random}&n=a490953a' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "leaderBoard",
         "rhs": " \n<div class=\"griggleeAds griggleeLeaderBoard\"><iframe id='a1c5a744' name='a1c5a744' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=13&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='728' height='90'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=a512ca4f' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=13&n=a512ca4f' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "oversized",
         "rhs": " \n<div class=\"griggleeAds griggleeOversized\"><iframe id='a2ec754e' name='a2ec754e' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=18&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='960' height='250'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=ae5aa5d8' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=18&n=ae5aa5d8' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "wideSkyscraper",
         "rhs": " \n<div class=\"griggleeAds griggleeWideSkyscraper\"><iframe id='a8effeec' name='a8effeec' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=19&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='160' height='600'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=a0d9e4ed' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=19&n=a0d9e4ed' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "fullBanner",
         "rhs": " \n<div class=\"griggleeAds griggleeFullBanner\"><iframe id='a7cf10a7' name='a7cf10a7' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=11&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='468' height='60'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=a6eb5045' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=11&n=a6eb5045' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "mediumRectangle",
         "rhs": " \n<div class=\"griggleeAds griggleeMediumRectangle\"><iframe id='a0e61aab' name='a0e61aab' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=20&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='300' height='250'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=a1900164' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=20&n=a1900164' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "square",
         "rhs": " \n<div class=\"griggleeAds griggleeSquare\"><iframe id='a5aa2159' name='a5aa2159' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=21&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='200' height='200'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=a55ac9bc' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=21&n=a55ac9bc' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "lhs": "skyscraper",
         "rhs": " \n<div class=\"griggleeAds griggleeSkyscraper\"><iframe id='a1f8a072' name='a1f8a072' src='http:\\/\\/ads.grigglee.com/www/delivery/afr.php?resize=1&zoneid=12&target=_blank' framespacing='0' frameborder='no' scrolling='no' width='120' height='600'><a href='http:\\/\\/ads.grigglee.com/www/delivery/ck.php?n=ad47e365' target='_blank'><img src='http:\\/\\/ads.grigglee.com/www/delivery/avw.php?zoneid=12&n=ad47e365' border='0' alt='' /><\/a><\/iframe><\/div>    \n ",
         "type": "here_doc"
      },
      {
         "content": ".griggleeAds { text-align: center; margin-bottom: 10px;  }    \t.griggleeAds iframe { border: black solid 2px; }    \t.griggleeLeaderBoard, .griggleeFullBanner { margin-top: 10px; }        ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Grigglee",
      "logging": "on",
      "name": "Grigglee"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#home_sponsor_nile>div"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "replace_html",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#home_sponsor_nile>div"
                  },
                  {
                     "type": "var",
                     "val": "FBmessage"
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
                     "val": "#leftCol"
                  },
                  {
                     "type": "var",
                     "val": "Video"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#sidebar_ads>div"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "replace_html",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#sidebar_ads>div"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"emit": "\nKOBJ.watchDOM(\"#content\",function(){ $K(\".adcolumn,#pagelet_filters\").prepend(skyscraper); $K(\"#home_sidebar\").prepend(square); $K(\"#home_sidebar\").prepend(FBmessage); });                      "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "facebook",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "FBmessage",
               "rhs": " \n<div id=\"CAB_Wrapper\" style=\"margin-bottom: 10px;\">  \t\t  \t\t  \t\t\t\t<div class=\"UIHomeBox UITitledBox\" id=\"CAB_Content\" style=\"margin-bottom: 0px;\">  \t\t  \t\t\t\t\t<div class=\"UITitledBox_Content\" style=\"text-align: center;\">  \t\t\t\t\t\t\t<a href=\"http:\\/\\/www.facebook.com/pages/Spanish-Fork-UT/Confetti-Antiques-Books/126513199345?ref=ts\">  \t\t\t\t\t\t\t\t<img src=\"http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x53/image4.jpg\" alt=\"Become a Kynetx\" style=\"margin-top: -10px; margin-bottom: 10px;\" />  \t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t<\/div>  \t\t\t\t\t\t<div>  \t\t\t\t\t\t\t<img hspace=\"8\" vspace=\"4\" align=\"absmiddle\" src=\"http:\\/\\/kynetx-images.s3.amazonaws.com/iconTwitter.gif\"/><a target=\"_blank\" href=\"http://twitter.com/confettibooks\">Follow Confetti Antiques on Twitter!<\/a>  \t\t\t\t\t\t<\/div>  \t\t\t\t\t<\/div>  \t\t\t\t<\/div>  \t\t  \t\t  \t\t\t<\/div>  \t \n ",
               "type": "here_doc"
            },
            {
               "lhs": "Video",
               "rhs": " \n<object width=\"160\" height=\"98\"><param name=\"movie\" value=\"http://www.youtube.com/v/kb5QNmg5RTk&hl=en_US&fs=1&color1=0x234900&color2=0x4e9e00\"><\/param><param name=\"allowFullScreen\" value=\"true\"><\/param><param name=\"allowscriptaccess\" value=\"always\"><\/param><embed src=\"http://www.youtube.com/v/kb5QNmg5RTk&hl=en_US&fs=1&color1=0x234900&color2=0x4e9e00\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"160\" height=\"98\"><\/embed><\/object>  \t\n ",
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
                     "val": "#mbEnd>tbody"
                  },
                  {
                     "type": "var",
                     "val": "googleAds"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#mbEnd>tbody"
                  },
                  {
                     "type": "var",
                     "val": "googleAds"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#footer"
                  },
                  {
                     "type": "var",
                     "val": "leaderBoard"
                  }
               ],
               "modifiers": null,
               "name": "before",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#ssb"
                  },
                  {
                     "type": "var",
                     "val": "leaderBoard"
                  }
               ],
               "modifiers": null,
               "name": "after",
               "source": null
            }},
            {"emit": "\nKOBJ.watchDOM(\"#res,#footer\",function(){$K(\"#footer\").before(leaderBoard); $K(\"#ssb\").after(leaderBoard); $K(\"#mbEnd>tbody\").prepend(googleAds); $K(\"#mbEnd>tbody\").prepend(googleAds); });                    "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "google",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "pre": [
            {
               "lhs": "googleAds1",
               "rhs": " \n<tr><td><div class=\"griggleeLeft\"> \n ",
               "type": "here_doc"
            },
            {
               "lhs": "googleAds2",
               "rhs": " \n<\/div><\/tr><\/td> \n ",
               "type": "here_doc"
            },
            {
               "lhs": "googleAds",
               "rhs": {
                  "args": [
                     {
                        "type": "var",
                        "val": "googleAds1"
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "mediumRectangle"
                           },
                           {
                              "type": "var",
                              "val": "googleAds2"
                           }
                        ],
                        "op": "+",
                        "type": "prim"
                     }
                  ],
                  "op": "+",
                  "type": "prim"
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
                  "val": ".content_wrap"
               },
               {
                  "type": "var",
                  "val": "leaderBoard"
               }
            ],
            "modifiers": null,
            "name": "before",
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
         "name": "bing",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#addiv"
                  },
                  {
                     "type": "var",
                     "val": "mediumRectangle"
                  }
               ],
               "modifiers": null,
               "name": "before",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#addiv"
                  },
                  {
                     "type": "str",
                     "val": "<div />"
                  }
               ],
               "modifiers": null,
               "name": "replace",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#y-content"
                  },
                  {
                     "type": "var",
                     "val": "leaderBoard"
                  }
               ],
               "modifiers": null,
               "name": "before",
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
         "name": "yahoo",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.yahoo.com",
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
                     "val": "#watch-this-vid-info"
                  },
                  {
                     "type": "var",
                     "val": "fullBanner"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#watch-other-vids"
                  },
                  {
                     "type": "var",
                     "val": "mediumRectangle"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#ad_creative_1"
                  },
                  {
                     "type": "var",
                     "val": "oversized"
                  }
               ],
               "modifiers": null,
               "name": "replace_inner",
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
         "name": "youtube",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.youtube.com",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#marketing"
               },
               {
                  "type": "var",
                  "val": "oversized"
               }
            ],
            "modifiers": null,
            "name": "replace_inner",
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
         "name": "myspace",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.myspace.com",
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
                     "val": "#bodyCol1"
                  },
                  {
                     "type": "var",
                     "val": "oversized"
                  }
               ],
               "modifiers": null,
               "name": "before",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#bodyCol3>div:first:has(script)"
                  },
                  {
                     "type": "var",
                     "val": "mediumRectangle"
                  }
               ],
               "modifiers": null,
               "name": "replace_inner",
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
         "name": "ksl",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.ksl.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
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
         "emit": null,
         "foreach": [],
         "name": "deseret_book_home",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "inactive"
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
         "emit": null,
         "foreach": [],
         "name": "deseret_book_product",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#firstHeading"
               },
               {
                  "type": "var",
                  "val": "leaderBoard"
               }
            ],
            "modifiers": null,
            "name": "before",
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
         "name": "wikipedia",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "wikipedia.org/wiki/",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#content"
                  },
                  {
                     "type": "var",
                     "val": "fullBanner"
                  }
               ],
               "modifiers": null,
               "name": "before",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#sidebar"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#sidebar"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"emit": "\n$K(\".griggleeFullBanner\").css({\"text-align\":\"left\"});  \t$K(\".griggleeAds\").css({\"margin-bottom\":\"10px\"});                  "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bing_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.bing.com/search",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#east"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#east"
                  },
                  {
                     "type": "var",
                     "val": "square"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#hd"
                  },
                  {
                     "type": "var",
                     "val": "leaderBoard"
                  }
               ],
               "modifiers": null,
               "name": "after",
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
         "name": "yahoo_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "search.yahoo.com/search",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#tsb"
               },
               {
                  "type": "var",
                  "val": "leaderBoard"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "craigslist",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "craigslist.org",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#bodyCol3>div:first:has(script)"
                  },
                  {
                     "type": "var",
                     "val": "mediumRectangle"
                  }
               ],
               "modifiers": null,
               "name": "replace_inner",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "#bodyCol3"
                  },
                  {
                     "type": "var",
                     "val": "mediumRectangle"
                  }
               ],
               "modifiers": null,
               "name": "prepend",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": ".formDivider"
                  },
                  {
                     "type": "var",
                     "val": "fullBanner"
                  }
               ],
               "modifiers": null,
               "name": "after",
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
         "name": "ksl_other",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.ksl.com",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
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
         "emit": null,
         "foreach": [],
         "name": "grigglee_exception",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "grigglee.com",
            "type": "prim_event",
            "vars": []
         }},
         "post": {
            "cons": [{
               "statement": "last",
               "type": "control"
            }],
            "type": "fired"
         },
         "state": "active"
      }
   ],
   "ruleset_name": "a41x80"
}
