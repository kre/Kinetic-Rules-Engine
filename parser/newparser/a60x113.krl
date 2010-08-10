{
   "dispatch": [
      {"domain": "acxiom.com"},
      {"domain": "dnb.com"}
   ],
   "global": [
      {"emit": "\nKOBJ.watchDOM(\"#dnb_member_mark\",addMemberClickFunctionality);    function addMemberClickFunctionality() {    $K(\"#dnb_member_mark\").click(function() {      KOBJ.log(\"clicked\");    });    clearInterval(KOBJ.watcherRunning);    }                "},
      {
         "lhs": "DNB",
         "rhs": {
            "type": "hashraw",
            "val": [
               {
                  "lhs": "www.acxiom.com",
                  "rhs": {
                     "type": "hashraw",
                     "val": [{
                        "lhs": "pageLocation",
                        "rhs": {
                           "type": "str",
                           "val": "http://dl.dropbox.com/u/1446072/Business%20Information%20Report%20with%20Auto-Refresh-20100115152714.html"
                        }
                     }]
                  }
               },
               {
                  "lhs": "www.dnb.com",
                  "rhs": {
                     "type": "hashraw",
                     "val": [{
                        "lhs": "pageLocation",
                        "rhs": {
                           "type": "str",
                           "val": "http://dl.dropbox.com/u/1446072/Business%20Information%20Report%20with%20Auto-Refresh-20100115152714.html"
                        }
                     }]
                  }
               }
            ]
         },
         "type": "expr"
      },
      {
         "content": "#KOBJ_PopIn_Dialog {    \tleft: 50%;    \tmargin-top: -25%;    \tmargin-left: -25%;    \twidth: 50%;    }    ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Mike Grace",
      "logging": "on",
      "name": "Dun and Bradstreet Community"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [{
               "type": "var",
               "val": "msg"
            }],
            "modifiers": [
               {
                  "name": "position",
                  "value": {
                     "type": "str",
                     "val": "right-top"
                  }
               },
               {
                  "name": "imageLocation",
                  "value": {
                     "type": "str",
                     "val": "http://dl.dropbox.com/u/1446072/dnb_duns_reg_click_english_110x36_animation_gif.gif"
                  }
               },
               {
                  "name": "link_color",
                  "value": {
                     "type": "str",
                     "val": "transparent"
                  }
               }
            ],
            "name": "side_tab",
            "source": null
         }},
         {"emit": "\nsetInterval(function() {      $K(\"#KOBJ_PopIn_Dialog\").css(\"left\", \"50%\");      $K(\"#KOBJ_PopIn_Dialog\").css(\"margin-right\", \"-25%\");      $K(\"#KOBJ_PopIn_Dialog\").css(\"margin-left\", \"-25%\");      $K(\"#KOBJ_PopIn_Dialog\").width(\"50%\");      $K(\"#KOBJ_PopIn_Dialog\").css(\"top\", \"20%\");      $K(\"#KOBJ_PopIn_Dialog\").height(\"60%\");      var heightToBe = $K(\"#KOBJ_PopIn_Dialog\").height() - 35;      $K(\"#KOBJ_PopIn_Content > iframe\").height(heightToBe);      $K(\"#KOBJ_Close\").css(\"font-size\", \"14pt\");    },  500);                 "}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "mark_member_",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "hostName",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "hostname"
               }],
               "predicate": "url",
               "source": "page",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": " \n<iframe src=\"#{DNB[hostName].pageLocation}\" width=\"100%\" height=\"0\" />  \t\n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a60x113"
}
