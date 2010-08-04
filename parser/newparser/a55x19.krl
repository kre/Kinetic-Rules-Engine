{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [
      {
         "cachable": {
            "period": "minutes",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "flickr_data",
         "source": "http://api.flickr.com/services/feeds/groups_pool.gne?id=1404010@N21&format=xml",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "60"
         },
         "datatype": "JSON",
         "name": "imgInfo",
         "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=3dea49be35557fa8043a40170d20439c&_render=json",
         "type": "dataset"
      }
   ],
   "meta": {
      "author": "Chris",
      "description": "\nCopyright (c) 2010 7bound, LLC All Rights Reserved   \n\n",
      "logging": "off",
      "name": "SlideDish - Impact"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [
               {
                  "name": "message",
                  "value": {
                     "type": "var",
                     "val": "msg"
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
                  "name": "topPos",
                  "value": {
                     "type": "str",
                     "val": "0px"
                  }
               },
               {
                  "name": "pathToTabImage",
                  "value": {
                     "type": "str",
                     "val": "http://www.7bound.com/impact2010/images/dishImages/tabImpact2010.png"
                  }
               },
               {
                  "name": "imageHeight",
                  "value": {
                     "type": "str",
                     "val": "225px"
                  }
               },
               {
                  "name": "imageWidth",
                  "value": {
                     "type": "str",
                     "val": "48px"
                  }
               },
               {
                  "name": "contentClass",
                  "value": {
                     "type": "str",
                     "val": "chrisArea"
                  }
               },
               {
                  "name": "width",
                  "value": {
                     "type": "str",
                     "val": "300px"
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
                  "name": "callback",
                  "value": {
                     "type": "var",
                     "val": "setDivs"
                  }
               },
               {
                  "name": "height",
                  "value": {
                     "type": "str",
                     "val": "650px"
                  }
               }
            ],
            "name": "sidetab",
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
         "name": "rule1",
         "pagetype": {
            "event_expr": {
               "domain": "web",
               "op": "pageview",
               "pattern": "7bound.com/slidedish",
               "type": "prim_event"
            },
            "foreach": []
         },
         "pre": [
            {
               "lhs": "setDivs",
               "rhs": " \n<script type=\"text/javascript\">\nfunction setDivs()\n{\n$K(\"#chrisArea\").css(\"height\",\"620px\");\n$K(\"#chrisArea\").parent(\"div\").css(\"height\",\"625px\");\n$K(\"#chrisArea\").parent(\"div\").css(\"z-index\",\"99999\");\n}\n<\/script>\n\t",
               "type": "here_doc"
            },
            {
               "lhs": "msg",
               "rhs": " \n\n<div id = \"chrisArea\"  style= \"height:700px; border:7px black solid; -moz-border-radius-bottomleft:6px; -moz-border-radius-bottomright:6px;\">        \n\n  <iframe id=\"ifaccordian\" src=\"http://www.7bound.com/impact2010/slideDish/PHPTest1.php\" scrolling=\"no\" frameborder = \"0\" style=\"height:520px; width:288px;\"><\/iframe>\n\n<div align=\"center\">\n\n<a href=\"http://www.acxiom.com\" target=\"_blank\"><img src=\"http://www.7bound.com/impact2010/slideDish/images/acxiom.png\" border=\"0\"><\/a>\n\n  <a href=\"http://www.baconsalt.com\" target=\"_blank\"><img src=\"http://www.7bound.com/impact2010/slideDish/images/baconsalt.png\" border=\"0\"><\/a>\n\n  <a href=\"http://www.7bound.com\" target=\"_blank\"><img src=\"http://www.7bound.com/impact2010/slideDish/images/7bound.png\" border=\"0\"><br/>\n\n<a href=\"http://www.venafi.com\" target=\"_blank\"><img src=\"http://www.7bound.com/impact2010/slideDish/images/venafi.png\" border=\"0\"><\/a>\n\n<a href=\"http://www.spectrumdna.com\" target=\"_blank\"><img src=\"http://www.7bound.com/impact2010/slideDish/images/spectrum.png\" border=\"0\"><\/a>\n<\/div>\n\n<div style=\"float:right; clear:both; color:#999999; padding-right:5px; padding-top:5px; font-size:10px; font-family:Trebuchet MS,sans-serif;\">\nSlideDish&trade; Copyright &copy; 2010 <a href=\"http://www.7bound.com\">7bound, LLC<\/a><\/div>\n\n<\/div>        \n \n ",
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
                  "val": ".HoldPhotos>p"
               },
               {
                  "type": "var",
                  "val": "btn"
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
         "emit": "\n$K('.like').live('click', function() {\n\tvar imgSrc = $K(this).parent().find('.pc_img').attr('src'); // place holder func, obvioiusly you'd do different stuff here\n\t$K.getJSON(\"http://www.7bound.com/impact2010/slideDish/vote.php?item=\"+imgSrc,function(){alert(\"Vote submitted!\");});\n\t}\n);\n        ",
         "foreach": [],
         "name": "flickr_vote",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.flickr.com/groups/1404010@N21/pool/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "btn",
            "rhs": " \n<br /><img class=\"like\" align=\"left\" style=\"cursor:pointer; padding-left:12px;\" src = \"http://www.7bound.com/impact2010/slideDish/images/thumbsUp2.png\"/>  \n ",
            "type": "here_doc"
         }],
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#logo"
               },
               {
                  "type": "var",
                  "val": "imgUrl"
               }
            ],
            "modifiers": null,
            "name": "replace_image_src",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "type": "var",
                  "val": "startH"
               },
               {
                  "type": "var",
                  "val": "startM"
               },
               {
                  "type": "var",
                  "val": "endH"
               },
               {
                  "type": "var",
                  "val": "endM"
               }
            ],
            "predicate": "time_between",
            "source": "time",
            "type": "qualified"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "imgInfo"
               },
               "type": "operator"
            },
            "var": ["imgInfo"]
         }]],
         "name": "imgswap",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "startH",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..startH"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "imgInfo"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "startM",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..startM"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "imgInfo"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "endH",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..endH"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "imgInfo"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "endM",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..endM"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "imgInfo"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "imgUrl",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..imgUrl"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "imgInfo"
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
            "args": [{
               "type": "var",
               "val": "my_select"
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
         "emit": "\nfunction my_select(obj) {        var ftext = $K(obj).text();        if (ftext.match(/kynetx.com/gi)) {          return \"<span><a target='_blank' href='http:\\/\\/www.kynetx.com' border='0'><img border='0' class='welovekynetx' src='http:\\/\\/7bound.com/impact2010/images/kyntexfan.jpg' /><\/a><\/span>\";        } else {          false;        }      }            ",
         "foreach": [],
         "name": "kfan_annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "findDevex"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction findDevex(obj){           return $K(obj).data(\"domain\").match(/devex.kynetx.com/gi);        }              ",
         "foreach": [],
         "name": "kfan_percolate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a55x19"
}
