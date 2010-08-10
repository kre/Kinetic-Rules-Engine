{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "alluringwalls.com"},
      {"domain": "extendedlearning.org"},
      {"domain": "arkansaslaserandskincare.com"},
      {"domain": "audiusa.com"},
      {"domain": "avis.com"},
      {"domain": "backyardburgers.com"},
      {"domain": "bankozarks.com"},
      {"domain": "barnesandnoble.com"},
      {"domain": "home-loan1.com"},
      {"domain": "brooksbrothers.com"},
      {"domain": "budget.com"},
      {"domain": "caldwell-toyota.com"},
      {"domain": "carpetmillsar.com"},
      {"domain": "cdw.com"},
      {"domain": "centralarkansascheer.com"},
      {"domain": "chicagoskinsolutions.com"},
      {"domain": "coltonssteakhouse.com"},
      {"domain": "cometcleaners.com"},
      {"domain": "conwaycopies.com"},
      {"domain": "autotropolis.com"},
      {"domain": "us.corporateperks.com"},
      {"domain": "cosmeticlasersolution.com"},
      {"domain": "dell.com"},
      {"domain": "detailsunlimited1.com"},
      {"domain": "dixiecafe.com"},
      {"domain": "dpw1.com"},
      {"domain": "elkgrovemarathon.com"},
      {"domain": "enterprise.com"},
      {"domain": "tracytidwell.com"},
      {"domain": "exitrealtyconway.com"},
      {"domain": "fordpartner.com"},
      {"domain": "fromyouflowers.com"},
      {"domain": "gifttree.com"},
      {"domain": "gmsupplierdiscount.com"},
      {"domain": "hp.com"},
      {"domain": "iberiabankmortgage.com"},
      {"domain": "jackdanielsmotors.com"},
      {"domain": "javaroastingcafe.com"},
      {"domain": "josbank.com"},
      {"domain": "kotobistro.com"},
      {"domain": "landers.com"},
      {"domain": "larryspizzaofarkansas.com"},
      {"domain": "lennys.com"},
      {"domain": "mazzios.com"},
      {"domain": "midaslittlerock.com"},
      {"domain": "insidenissan.com"},
      {"domain": "nutrishopconway.com"},
      {"domain": "nypdpizzeria.com"},
      {"domain": "officedepot.com"},
      {"domain": "parkwayautomotive.net"},
      {"domain": "pcmall.com"},
      {"domain": "regissalons.com"},
      {"domain": "hfawarenessnetwork.org"},
      {"domain": "shadesmith.com"},
      {"domain": "shortysmalls.com"},
      {"domain": "sdcticketoffers.com"},
      {"domain": "simmonsfirst.com"},
      {"domain": "slim-chickens.com"},
      {"domain": "smithford.dealerconnection.com"},
      {"domain": "smoothieking.com"},
      {"domain": "southernautomotivecompanies.com"},
      {"domain": "tracystocks.com"},
      {"domain": "stonebridgeattheranch.com"},
      {"domain": "stonehavenalf.com"},
      {"domain": "superiorchevy.net"},
      {"domain": "superiornissan.com"},
      {"domain": "enclaveriverfront.com"},
      {"domain": "thefishhouse-smittys.com"},
      {"domain": "msauthority.com"},
      {"domain": "theproblemseekers.com"},
      {"domain": "tropicalsmoothie.com"},
      {"domain": "valleyautos.net"},
      {"domain": "vintagetovogueonline.com"},
      {"domain": "wingstop.com"},
      {"domain": "wisdells.com"},
      {"domain": "wonderstatemortgage.com"}
   ],
   "global": [
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "acxiom_discounts",
         "source": "http://spreadsheets.google.com/feeds/list/0Aj440OxyX9KJdHVYN0xyYUptNlBNUEZWLVBiaFpmQ3c/od6/public/values?alt=json",
         "type": "dataset"
      },
      {
         "content": "\n\n        .k-reset * {\n          margin: 0;\n          padding: 0;\n          border: 0;\n          outline: 0;\n          font-size:24px;\n          font-size: 100%;\n          font-weight:normal;\n          vertical-align: baseline;\n          background: transparent;\n          color: #000;\n          font-family:arial,sans-serif;\n          direction: ltr;\n          line-height: 16px;\n          letter-spacing: normal;\n          text-align: left;\n          text-decoration: none;\n          text-indent: 0;\n          text-shadow: none;\n          text-transform: none;\n          vertical-align: baseline;\n          white-space: normal;\n          word-spacing: normal;\n          font: normal normal normal medium/1 sans-serif;\n          list-style: none;\n          clear: none;\n        }\n\n        img.acxiom-annotation {\n          float:right;\n          margin:6px 8px 0 0;\n        }\n        \n        #acxiom-discount-details {\n          -moz-border-radius:5px 5px 5px 5px;\n          background-color:white;\n          border:1px solid #999999;\n          padding:9px;\n          width:345px;\n          display: none;\n        }\n        \n        .show {\n          display: block !important;\n        }\n        \n        .hide {\n          display: none !important;\n        }\n        \n        .relative {\n          position: relative;\n        }\n        \n        #closer {\n          height:8px;\n          position:absolute;\n          right:9px;\n          top:7px;\n        }\n      ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Kynetx",
      "description": "\n        Acxiom Employees can use this card to identify where they can get discounts     \n      ",
      "keys": {"errorstack": "f853aad49b56c0e2cea48a45f5ae041b"},
      "logging": "on",
      "name": "Improved Acxiom Employee Discount Card"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "body"
               },
               {
                  "type": "var",
                  "val": "tracking"
               }
            ],
            "modifiers": null,
            "name": "append",
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
         "name": "tracking",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "tracking",
            "rhs": "\n          <a href=\"http://www.statcounter.com/free_hit_counter.html\" target=\"_blank\"><img src=\"http://c.statcounter.com/5861548/0/55ea3c10/1/\" border=\"0\"><\/a>\n        ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"emit": "\n          $K(\"head\").append(catchy);\n        "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "error_stack",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "catchy",
            "rhs": "\n        <script type=\"text/javascript\">\n          onerror = function(msg,url,l){\n          \tvar txt=\"_s=f853aad49b56c0e2cea48a45f5ae041b&_r=img\";\n          \ttxt+=\"&Msg=\"+escape(msg);\n          \ttxt+=\"&URL=\"+escape(url);\n          \ttxt+=\"&Line=\"+l;\n          \ttxt+=\"&Platform=\"+escape(navigator.platform);\n          \ttxt+=\"&UserAgent=\"+escape(navigator.userAgent);\n          \tvar i = document.createElement(\"img\");\n          \ti.setAttribute(\"src\", ((\"https:\" == document.location.protocol) ? \n          \t\t\"https://errorstack.appspot.com\" : \"http://www.errorstack.com\") + \"/submit?\" + txt);\n          \tdocument.body.appendChild(i);\n          }\n        <\/script>\n        ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\n          function acxiom_search(obj){\n            try {\n              var entryURL = $K(obj).data(\"domain\");\n              var host = entryURL.replace(/^www\\./,\"\");\n              for (var i=0; i<mySites.length; i++){\n                if (host == mySites[i]){\n                  var o = mySites[i];\n                }\n              }\n              if(!o){\n                newHost = \"www\\.\" + fixHost;\n                o = mySites[newHost];\n              }\n              if(o && !$K(obj).is(\".localbox\")) {\n                return '<a href=\"http://'+ host +'\"><img src=\"https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png\" style=\"border: none; position: relative; left: 15px;\"><\/a>';\n              } else {\n                return false;\n              }\n            } catch(e) { }\n          }           \n        "},
            {"action": {
               "args": [{
                  "type": "var",
                  "val": "acxiom_search"
               }],
               "modifiers": null,
               "name": "annotate_search_results",
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
         "name": "searchannotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "mySites",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$..gsx$domain..$t"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "acxiom_discounts"
               },
               "type": "operator"
            },
            "type": "expr"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "absolute"
                  },
                  {
                     "type": "str",
                     "val": "top:50px"
                  },
                  {
                     "type": "str",
                     "val": "right:50px"
                  },
                  {
                     "type": "var",
                     "val": "annotationDetail"
                  }
               ],
               "modifiers": null,
               "name": "float_html",
               "source": null
            }},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "absolute"
                  },
                  {
                     "type": "str",
                     "val": "top:50px"
                  },
                  {
                     "type": "str",
                     "val": "right:50px"
                  },
                  {
                     "type": "var",
                     "val": "annotationButton"
                  }
               ],
               "modifiers": null,
               "name": "float_html",
               "source": null
            }},
            {"emit": "\n          // temporary fix until float_html action is fixed. Fogbugz ticket #802\n          $K(\".k-reset\").parent().css(\"display\",\"block\");\n          \n          // show details when annotation image is clicked on\n          $K(\".acxiom-annotation\").click(function() {\n            if($K(\"#acxiom-discount-details\").css(\"display\") == \"none\") {\n              $K(\"#acxiom-discount-details\").css(\"display\",\"block\");\n            } else {\n              $K(\"#acxiom-discount-details\").css(\"display\",\"none\");\n            }\n          });\n          \n          // hide everything if close button is pressed\n          $K(\"#closer\").click(function() {\n            $K(\".k-reset\").hide();\n          });\n        "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "type": "var",
                  "val": "foundYou"
               },
               {
                  "type": "num",
                  "val": 1
               }
            ],
            "op": "==",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..entry"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "acxiom_discounts"
               },
               "type": "operator"
            },
            "var": ["sites"]
         }]],
         "name": "store_site_annotation",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
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
               "lhs": "name",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..gsx$title..$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "site",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..gsx$domain..$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "desc",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..gsx$content..$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "foundYou",
               "rhs": {
                  "args": [
                     {
                        "type": "var",
                        "val": "domain"
                     },
                     {
                        "type": "var",
                        "val": "site"
                     }
                  ],
                  "op": "like",
                  "type": "ineq"
               },
               "type": "expr"
            },
            {
               "lhs": "annotationButton",
               "rhs": "\n          <div class=\"k-reset relative\">\n            <img class=\"acxiom-annotation\" id=\"discount-image-annotation\" src=\"https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png\" alt=\"Acxiom Discount Available!\" />\n            <img id=\"closer\" src=\"https://kynetx-apps.s3.amazonaws.com/acxiom/close.png\" />\n          <\/div>\n        ",
               "type": "here_doc"
            },
            {
               "lhs": "annotationDetail",
               "rhs": "\n          <div class=\"k-reset\">\n            <div id=\"acxiom-discount-details\">\n              <img class=\"acxiom-annotation\" src=\"https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-annotate.png\" alt=\"Acxiom Discount Available!\" style=\"visibility: hidden;\"/>\n              #{desc}\n            <\/div>\n          <\/div>\n        ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [],
               "modifiers": [
                  {
                     "name": "message",
                     "value": {
                        "type": "var",
                        "val": "tempaxcMsg"
                     }
                  },
                  {
                     "name": "backgroundColor",
                     "value": {
                        "type": "str",
                        "val": "white"
                     }
                  },
                  {
                     "name": "pathToTabImage",
                     "value": {
                        "type": "str",
                        "val": "https://kynetx-apps.s3.amazonaws.com/acxiom/acxiom-tab.png"
                     }
                  },
                  {
                     "name": "tabColor",
                     "value": {
                        "type": "str",
                        "val": ""
                     }
                  },
                  {
                     "name": "imageHeight",
                     "value": {
                        "type": "str",
                        "val": "180px"
                     }
                  },
                  {
                     "name": "imageWidth",
                     "value": {
                        "type": "str",
                        "val": "80px"
                     }
                  },
                  {
                     "name": "width",
                     "value": {
                        "type": "str",
                        "val": "310px"
                     }
                  },
                  {
                     "name": "height",
                     "value": {
                        "type": "str",
                        "val": "180px"
                     }
                  }
               ],
               "name": "sidetab",
               "source": null
            }},
            {"emit": "\n          $K(\"#AcxiomDiscount .name\").html(name);\n          $K(\"#AcxiomDiscount .desc\").html(desc);\n          $K(\"#AcxiomDiscount .linkOne\").attr(\"href\",linkOne);\n          $K(\"#AcxiomDiscount .linkOnedes\").html(linkOnedes);\n          $K(\"#AcxiomDiscount .linkTwo\").attr(\"href\",linkTwo);\n          $K(\"#AcxiomDiscount .linkTwodes\").html(linkTwodes);\n        "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "type": "var",
                  "val": "foundYou"
               },
               {
                  "type": "num",
                  "val": 1
               }
            ],
            "op": "==",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..entry"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "acxiom_discounts"
               },
               "type": "operator"
            },
            "var": ["sites"]
         }]],
         "name": "discountstores",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
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
               "lhs": "name",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..gsx$title..$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "site",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..gsx$domain..$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "desc",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..gsx$content..$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "sites"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "foundYou",
               "rhs": {
                  "args": [
                     {
                        "type": "var",
                        "val": "domain"
                     },
                     {
                        "type": "var",
                        "val": "site"
                     }
                  ],
                  "op": "like",
                  "type": "ineq"
               },
               "type": "expr"
            },
            {
               "lhs": "tempaxcMsg",
               "rhs": " \n          <div id=\"AcxiomDiscount\">\n            <div>There is a discount available here, at <span class=\"name\"><\/span>. <span class=\"desc\"><\/span> <a class=\"linkOne\" href=\"#\"><span class=\"linkOnedes\"><\/span><\/a>   <a class=\"linkTwo\" href=\"#\"><span class=\"linkTwodes\"><\/span><\/a><\/div>\n          <\/div>                  \n        ",
               "type": "here_doc"
            }
         ],
         "state": "inactive"
      },
      {
         "actions": [
            {"emit": "\n          if ($K(\"#companyCode\").length == 0) {\n            $K(\"#user_name\").focus();\n          }\n          if ($K(\"#companyCode\").length){\n            $K(\"#companyCode\").val(\"866303\");\n            $K(\"#companyCode\").focus();\n            $K(\"button:first\").trigger(\"click\");\n          }              \n        "},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "Acxiom Discount"
                  },
                  {
                     "type": "str",
                     "val": "The Acxiom Discount has been automaticaly applied! Please continue by making a username and password on the left of the website."
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
         "name": "gm_formfill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)https://www.gmsupplierdiscount.com/ip-gmsupplier/",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"emit": "\n          $K(\"p.promo_code\").css({\"background-color\" : \"#CB2E2E\", \"border\" : \"2px solid gray\", \"border-style\" : \"outset\", \"color\" : \"white\", \"padding-bottom\" : \"4px\"});\n        "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "gifttree_buttonaccent",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)http://www.gifttree.com/checkout/checkout.review.php",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\n          $K(\"#EPPKey\").val(\"f2chk2zp\");\n          $K(\"#SUBMIT1\").trigger(\"click\");\n        "},
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "Congratulations!"
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
         "name": "cdw_formfill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)https://www.cdw.com/shop/EPP/Accounts/default.asp",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msgBadge",
            "rhs": " \n          The Access Code has been entered for you! Please fill out the information on the page for the EPP E-Account.    \t\n        ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"emit": "\n          window.location.replace(\"http://btob.barnesandnoble.com/index.asp?SourceId=0039357841&Btob=Y\");\n        "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bandn_redirect",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)http://www.barnesandnoble.com/",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      }
   ],
   "ruleset_name": "a60x243"
}
