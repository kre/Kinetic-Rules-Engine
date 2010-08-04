{
   "dispatch": [
      {"domain": "facebook.com"},
      {"domain": "google.com"},
      {"domain": "kynetx.com"},
      {"domain": "twitter.com"},
      {"domain": "stackexchange.com"},
      {"domain": "fogbugz.com"}
   ],
   "global": [
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "analytx",
         "source": "http://analytx.kobj.net:5000/data/kns_totals",
         "type": "datasource"
      },
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "yahoo_pipes",
         "source": "http://pipes.yahoo.com/pipes/pipe.run",
         "type": "datasource"
      },
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "accounts",
         "source": "https://accounts.kynetx.com/api/0.1/stats",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "15"
         },
         "datatype": "JSON",
         "name": "devex_latest_users",
         "source": "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fitsoktomakemistakes.com%2Fdevex_newest_users.html%22%20and%20xpath%3D'%2F%2Fdiv%5B%40class%3D%22user-info%22%5D%2F%2Fdiv%5B%40class%3D%22user-details%22%5D%2F%2Fa'%20limit%205&format=json&callback=",
         "type": "dataset"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "5"
         },
         "datatype": "JSON",
         "name": "devex_latest_questions",
         "source": "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fitsoktomakemistakes.com%2Fdevex_newest_questions.html%22%20and%20xpath%3D'%2F%2Fa%5B%40class%3D%22question-hyperlink%22%5D'%20limit%204&format=json&diagnostics=false&callback=",
         "type": "dataset"
      },
      {
         "content": "#Kynetx_conference_content * {      margin: 0;      padding: 0;      border: 0;      outline: 0;      font-size:24px;      font-size: 100%;      font-weight:normal;      vertical-align: baseline;      background: transparent;      color: #000;      font-family:arial,sans-serif;      direction: ltr;      line-height: 1;      letter-spacing: normal;      text-align: left;       text-decoration: none;      text-indent: 0;      text-shadow: none;      text-transform: none;      vertical-align: baseline;      white-space: normal;      word-spacing: normal;      font: normal normal normal medium/1 sans-serif ;      list-style: none;      clear: none;    }        #kpi_header { font-size: 30px; color: #184a6f; padding-left: 5px }    #Kynetx_conference_content { border: solid 2px #184a6f }    .kpi_metric, .kpi_metric * { float: left }    .kpi_metric { width: 100% }    .kpi_metric h3 { width: 195px; margin: 0; padding-top:17px !important;}    .kpi_metric img { margin-top: -20px}    .media_updates { padding-left: 12px }    .media_updates h3 { padding-top: 0 !important}    .media_updates img { margin: 0; padding: 6px 0 0 12px !important }    .img_wrap { width: 50px; height: 45px}    .pad_top { padding-top: 13px !important }    #Kynetx_conference_content a { color:#0A94D6 !important }    .kpi_metric p { width: 195px }    .unanswered ul li a { font-size: 12px !important}    .full { width: 100% !important; padding-left: 14px !important }    ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Michael Grace",
      "description": "\nKynetx internal command center/dashboard to keep employees up to date on goals and latest changes    \n",
      "logging": "on",
      "name": "Kynetx Command Center"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "handle"
         }]},
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n(function($){      $.fn.tabSlideOut = function(callerSettings) {          var settings = $.extend({              tabHandle: '.handle',              speed: 300,               action: 'click',              tabLocation: 'left',              topPos: '200px',              leftPos: '20px',              fixedPosition: false,              positioning: 'absolute',              pathToTabImage: null,              imageHeight: null,              imageWidth: null,              onLoadSlideOut: false                                 }, callerSettings||{});            settings.tabHandle = $(settings.tabHandle);          var obj = this;          if (settings.fixedPosition === true) {              settings.positioning = 'fixed';          } else {              settings.positioning = 'absolute';          }                            if (document.all && !window.opera && !window.XMLHttpRequest) {              settings.positioning = 'absolute';          }                                                  if (settings.pathToTabImage != null) {              settings.tabHandle.css({              'background' : 'url('+settings.pathToTabImage+') no-repeat',              'width' : settings.imageWidth,              'height': settings.imageHeight              });          }                    settings.tabHandle.css({               'display': 'block',              'textIndent' : '-99999px',              'outline' : 'none',              'position' : 'absolute'          });                    obj.css({              'line-height' : '1',              'position' : settings.positioning          });                      var properties = {                      containerWidth: parseInt(obj.outerWidth(), 10) + 'px',                      containerHeight: parseInt(obj.outerHeight(), 10) + 'px',                      tabWidth: parseInt(settings.tabHandle.outerWidth(), 10) + 'px',                      tabHeight: parseInt(settings.tabHandle.outerHeight(), 10) + 'px'                  };                    if(settings.tabLocation === 'top' || settings.tabLocation === 'bottom') {              obj.css({'left' : settings.leftPos});              settings.tabHandle.css({'right' : 0});          }                    if(settings.tabLocation === 'top') {              obj.css({'top' : '-' + properties.containerHeight});              settings.tabHandle.css({'bottom' : '-' + properties.tabHeight});          }            if(settings.tabLocation === 'bottom') {              obj.css({'bottom' : '-' + properties.containerHeight, 'position' : 'fixed'});              settings.tabHandle.css({'top' : '-' + properties.tabHeight});                        }                    if(settings.tabLocation === 'left' || settings.tabLocation === 'right') {              obj.css({                  'height' : properties.containerHeight,                  'top' : settings.topPos              });                            settings.tabHandle.css({'top' : -1});          }                    if(settings.tabLocation === 'left') {              obj.css({ 'left': '-' + properties.containerWidth});              settings.tabHandle.css({'right' : '-' + properties.tabWidth});          }            if(settings.tabLocation === 'right') {              obj.css({ 'right': '-' + properties.containerWidth});              settings.tabHandle.css({'left' : '-' + properties.tabWidth});                            $('html').css('overflow-x', 'hidden');          }                              settings.tabHandle.click(function(event){              event.preventDefault();          });                    var slideIn = function() {                            if (settings.tabLocation === 'top') {                  obj.animate({top:'-' + properties.containerHeight}, settings.speed).removeClass('open');              } else if (settings.tabLocation === 'left') {                  obj.animate({left: '-' + properties.containerWidth}, settings.speed).removeClass('open');              } else if (settings.tabLocation === 'right') {                  obj.animate({right: '-' + properties.containerWidth}, settings.speed).removeClass('open');              } else if (settings.tabLocation === 'bottom') {                  obj.animate({bottom: '-' + properties.containerHeight}, settings.speed).removeClass('open');              }                            };                    var slideOut = function() {                            if (settings.tabLocation == 'top') {                  obj.animate({top:'-3px'},  settings.speed).addClass('open');              } else if (settings.tabLocation == 'left') {                  obj.animate({left:'-3px'},  settings.speed).addClass('open');              } else if (settings.tabLocation == 'right') {                  obj.animate({right:'-3px'},  settings.speed).addClass('open');              } else if (settings.tabLocation == 'bottom') {                  obj.animate({bottom:'-3px'},  settings.speed).addClass('open');              }          };            var clickScreenToClose = function() {              obj.click(function(event){                  event.stopPropagation();              });                            $(document).click(function(){                  slideIn();              });          };                    var clickAction = function(){              settings.tabHandle.click(function(event){                  if (obj.hasClass('open')) {                      slideIn();                  } else {                      slideOut();                  }              });                            clickScreenToClose();          };                    var hoverAction = function(){              obj.hover(                  function(){                      slideOut();                  },                                    function(){                      slideIn();                  });                                    settings.tabHandle.click(function(event){                      if (obj.hasClass('open')) {                          slideIn();                      }                  });                  clickScreenToClose();                            };                    var slideOutOnLoad = function(){              slideIn();              setTimeout(slideOut, 500);          };                            if (settings.action === 'click') {              clickAction();          }                    if (settings.action === 'hover') {              hoverAction();          }                    if (settings.onLoadSlideOut) {              slideOutOnLoad();          };                };  })($K);      if(!KOBJ.conference){  $K(\"body\").append(msg);    $K('#Kynetx_conference_content').tabSlideOut({tabHandle: '.handle','pathToTabImage':'http:\\/\\/kynetx.michaelgrace.org\\/analytx.jpg',imageHeight: '125px',imageWidth: '36px',tabLocation: 'right',speed: 300,action: 'click',topPos: '100px',fixedPosition: true});    KOBJ.conference = true;            $K(\"#stack_items\").replaceWith(\"<p><a target='_blank' href='http://kynetx.stackexchange.com'>\" + stack_items.length + \" updates since yesterday.<\/a><\/p>\");        }            ",
         "foreach": [],
         "name": "pullout_dashboard",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "an",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "rel_range",
                           "rhs": {
                              "type": "str",
                              "val": "yesterday"
                           }
                        },
                        {
                           "lhs": "ruleset_id",
                           "rhs": {
                              "type": "str",
                              "val": "kynetx_all"
                           }
                        },
                        {
                           "lhs": "kpi",
                           "rhs": {
                              "type": "str",
                              "val": "rse"
                           }
                        },
                        {
                           "lhs": "temporal",
                           "rhs": {
                              "type": "str",
                              "val": "day"
                           }
                        },
                        {
                           "lhs": "format",
                           "rhs": {
                              "type": "str",
                              "val": "table"
                           }
                        }
                     ]
                  }],
                  "predicate": "analytx",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "rse",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$[0].RSE"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "an"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "rse_spark",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "num_range",
                           "rhs": {
                              "type": "str",
                              "val": "1-7"
                           }
                        },
                        {
                           "lhs": "ruleset_id",
                           "rhs": {
                              "type": "str",
                              "val": "kynetx_all"
                           }
                        },
                        {
                           "lhs": "kpi",
                           "rhs": {
                              "type": "str",
                              "val": "rse"
                           }
                        },
                        {
                           "lhs": "temporal",
                           "rhs": {
                              "type": "str",
                              "val": "day"
                           }
                        },
                        {
                           "lhs": "format",
                           "rhs": {
                              "type": "str",
                              "val": "table"
                           }
                        }
                     ]
                  }],
                  "predicate": "analytx",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "kpi",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "_id",
                           "rhs": {
                              "type": "str",
                              "val": "c1eba3311827f4f16bf847f2ed09b0d1"
                           }
                        },
                        {
                           "lhs": "_render",
                           "rhs": {
                              "type": "str",
                              "val": "json"
                           }
                        }
                     ]
                  }],
                  "predicate": "yahoo_pipes",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "dash_title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "dash_item_count",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.count"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "dash_items",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "rse_goal",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items.[0].goal"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "rsep",
               "rhs": {
                  "args": [
                     {
                        "type": "num",
                        "val": 100
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "rse"
                           },
                           {
                              "type": "var",
                              "val": "rse_goal"
                           }
                        ],
                        "op": "/",
                        "type": "prim"
                     }
                  ],
                  "op": "*",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "rsept",
               "rhs": {
                  "args": [
                     {
                        "type": "var",
                        "val": "rsep"
                     },
                     {
                        "type": "num",
                        "val": 100
                     }
                  ],
                  "op": "*",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "var_actual",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.vars"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "accounts"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "var_goal",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items.[1].goal"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "varp",
               "rhs": {
                  "args": [
                     {
                        "type": "num",
                        "val": 100
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "var_actual"
                           },
                           {
                              "type": "var",
                              "val": "var_goal"
                           }
                        ],
                        "op": "/",
                        "type": "prim"
                     }
                  ],
                  "op": "*",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "account_actual",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.accounts"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "accounts"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "account_goal",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items.[3].goal"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "accountp",
               "rhs": {
                  "args": [
                     {
                        "type": "num",
                        "val": 100
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "account_actual"
                           },
                           {
                              "type": "var",
                              "val": "account_goal"
                           }
                        ],
                        "op": "/",
                        "type": "prim"
                     }
                  ],
                  "op": "*",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "apps_goal",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items.[4].goal"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "apps_actual",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items.[4].actual"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "kpi"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "appsp",
               "rhs": {
                  "args": [
                     {
                        "type": "num",
                        "val": 100
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "apps_actual"
                           },
                           {
                              "type": "var",
                              "val": "apps_goal"
                           }
                        ],
                        "op": "/",
                        "type": "prim"
                     }
                  ],
                  "op": "*",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "stack_feed",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "_id",
                           "rhs": {
                              "type": "str",
                              "val": "b00c5cc14f05fcb64c41a30a5b9f49d4"
                           }
                        },
                        {
                           "lhs": "_render",
                           "rhs": {
                              "type": "str",
                              "val": "json"
                           }
                        }
                     ]
                  }],
                  "predicate": "yahoo_pipes",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "stack_items",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.value.items"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "stack_feed"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "twitter_search",
               "rhs": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "_id",
                           "rhs": {
                              "type": "str",
                              "val": "ea795214a1defa5ab087aca3c0a3ee35"
                           }
                        },
                        {
                           "lhs": "_render",
                           "rhs": {
                              "type": "str",
                              "val": "json"
                           }
                        }
                     ]
                  }],
                  "predicate": "yahoo_pipes",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "tweet_count",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.count"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "twitter_search"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "account_stats",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.accounts"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "accounts"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "user1",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[0].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_users"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "user2",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[1].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_users"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "user3",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[2].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_users"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "user4",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[3].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_users"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "user5",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[4].content"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_users"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "q1",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[0]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_questions"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "q2",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[1]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_questions"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "q3",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[2]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_questions"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "q4",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$.query.results.a[3]"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "devex_latest_questions"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "msg",
               "rhs": " \n<div style=\"width: 250px; background: #fff; z-index: 9000;\" id=\"Kynetx_conference_content\" class=\"KOBJ_reset\">  \t<a class=\"handle\" href=\"#\">Content<\/a>  \t<h2 class=\"left\" id=\"kpi_header\">#{dash_title}<\/h2>  \t<div class=\"kpi_metric\"><img src=\"http://chart.apis.google.com/chart?chs=50x50&cht=gom&chd=t:#{100*rse/rse_goal}\"/><h3>RSE/day<\/h3><img class=\"kpi_sparkline\" src=\"#\"/><p>#{rse} of #{rse_goal}<\/p><\/div>  \t<div class=\"kpi_metric\"><img src=\"http://chart.apis.google.com/chart?chs=50x50&cht=gom&chd=t:#{varp}\"/><h3>VAR<\/h3><p>#{var_actual} of #{var_goal}<\/p><\/div>  \t<div class=\"kpi_metric\"><img src=\"http://chart.apis.google.com/chart?chs=50x50&cht=gom&chd=t:#{accountp}\"/><h3>Signups<\/h3><p>#{account_actual} of #{account_goal}<\/p><\/div>  \t<div class=\"kpi_metric\"><img src=\"http://chart.apis.google.com/chart?chs=50x50&cht=gom&chd=t:#{appsp}\"/><h3>Live Developer Apps<\/h3><p>#{apps_actual} of #{apps_goal}<\/p><\/div>  \t<div class=\"kpi_metric media_updates pad_top\" ><div class=\"img_wrap\"><img src=\"http://kynetx.michaelgrace.org/kynetx_stack.jpg\"/><\/div><h3>Kynetx.stack updates<\/h3><p id=\"stack_items\">changes<\/p><\/div>  \t<div class=\"kpi_metric media_updates\" ><div class=\"img_wrap\"><img src=\"http://kynetx.michaelgrace.org/kynetx_stack.jpg\"/><\/div><h3>Latest Devex Users<\/h3><p id=\"stack_items\"><a href=\"http://devex.kynetx.com/users?tab=newest\">#{user1}, #{user2}, #{user3}, #{user4}, #{user5}<\/a><\/p><\/div>  \t<div class=\"kpi_metric media_updates unanswered  pad_top\" ><h3 class=\"full\">Unanswered Devex Questions<\/h3>  \t\t<ul>  \t\t\t<li><a href=\"http://devex.kynetx.com#{q1.href}\">#{q1.content}<\/a><\/li>  \t\t\t<li><a href=\"http://devex.kynetx.com#{q2.href}\">#{q2.content}<\/a><\/li>  \t\t\t<li><a href=\"http://devex.kynetx.com#{q3.href}\">#{q3.content}<\/a><\/li>  \t\t\t<li><a href=\"http://devex.kynetx.com#{q4.href}\">#{q4.content}<\/a><\/li>\t\t\t  \t\t<\/ul><\/div>  \t<div class=\"kpi_metric media_updates  pad_top\"><div class=\"img_wrap\"><img src=\"http://kynetx.michaelgrace.org/twitter_small.jpg\"/><\/div><h3>Twitter<\/h3><p><a target=\"_blank\" href=\"http://search.twitter.com/search?q=kynetx\">#{tweet_count} tweets since yesterday<\/a><\/p><\/div>    <\/div>  \t\t\t  \t\n ",
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
                  "val": "Current Domain"
               },
               {
                  "type": "var",
                  "val": "page_data"
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
         "name": "daily_notification",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "page_domain",
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
               "lhs": "page_protocol",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "protocol"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "page_hostname",
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
               "lhs": "page_tld",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "tld"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "page_port",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "port"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "page_path",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "path"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "page_query",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "query"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "page_data",
               "rhs": " \n<p>Domain: #{page_domain}<\/p>      <p>Protocol: #{page_protocol}<\/p>      <p>Hostname: #{page_hostname}<\/p>      <p>TLD: #{page_tld}<\/p>      <p>Port: #{page_port}<\/p>      <p>Path: #{page_path}<\/p>      <p>Query: #{page_query}<\/p>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "inactive"
      }
   ],
   "ruleset_name": "a60x9"
}
