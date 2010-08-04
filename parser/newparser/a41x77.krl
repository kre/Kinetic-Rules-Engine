{
   "dispatch": [
      {"domain": "acxiom.com"},
      {"domain": "dnb.com"}
   ],
   "global": [
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
                           "val": "http://k-misc.s3.amazonaws.com/resources/a41x77/reports/acxiom.html"
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
                           "val": "http://k-misc.s3.amazonaws.com/resources/a41x77/reports/dun_brad.html"
                        }
                     }]
                  }
               }
            ]
         },
         "type": "expr"
      },
      {
         "content": "#KOBJ_PopIn_Dialog {    \tleft: 50%;    \tmargin-top: -25%;    \tmargin-left: -25%;    \twidth: 50%;    }            ",
         "type": "css"
      }
   ],
   "meta": {
      "logging": "off",
      "name": "DNB"
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
                     "val": "http://k-misc.s3.amazonaws.com/resources/a41x77/db.png"
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
         {"emit": "\nsetInterval(function(){  \t$K(\"#KOBJ_PopIn_Dialog\").css(\"left\",\"50%\");  \t$K(\"#KOBJ_PopIn_Dialog\").css(\"margin-right\",\"-25%\");  \t$K(\"#KOBJ_PopIn_Dialog\").css(\"margin-left\",\"-25%\");  \t$K(\"#KOBJ_PopIn_Dialog\").width(\"50%\");  \t$K(\"#KOBJ_PopIn_Dialog\").css(\"top\",\"20%\");  \t$K(\"#KOBJ_PopIn_Dialog\").height(\"60%\");  \tvar heightToBe = $K(\"#KOBJ_PopIn_Dialog\").height() - 35;  \t$K(\"#KOBJ_PopIn_Content > iframe\").height(heightToBe);  \t$K(\"#KOBJ_Close\").css(\"font-size\",\"14pt\");  },500);                  "}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "d_b",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.dnb.com/us/$|^http://www.acxiom.com/Pages/Home.aspx$",
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
   "ruleset_name": "a41x77"
}
