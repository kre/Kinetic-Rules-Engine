{
   "dispatch": [],
   "global": [
      {
         "cachable": {
            "period": "minutes",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "dsYahooWeather",
         "source": "http://weather.yahooapis.com/forecastrss",
         "type": "datasource"
      },
      {
         "cachable": {
            "period": "minutes",
            "value": "1"
         },
         "datatype": "JSON",
         "name": "dsYahooWoeid",
         "source": "http://query.yahooapis.com/v1/public/yql",
         "type": "datasource"
      },
      {
         "lhs": "city",
         "rhs": {
            "args": [],
            "predicate": "city",
            "source": "geoip",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "lhs": "state",
         "rhs": {
            "args": [],
            "predicate": "state",
            "source": "geoip",
            "type": "qualified"
         },
         "type": "expr"
      },
      {
         "content": "div#kGrowl div#WeatherList {        background-color: #e56e1b;        margin: 2px;        clear: both;      }    ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Chris Jensen",
      "description": "\nYahoo Weather     \n",
      "logging": "on",
      "name": "Yahoo Weather"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "args": [
                     {
                        "type": "str",
                        "val": "Yahoo! Weather <br />"
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "city"
                           },
                           {
                              "type": "var",
                              "val": "state"
                           }
                        ],
                        "op": "+",
                        "type": "prim"
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               },
               {
                  "type": "var",
                  "val": "InitializedDiv"
               }
            ],
            "modifiers": [
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "green"
                  }
               },
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
                     "val": 0.8
                  }
               }
            ],
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
         "name": "initialize",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "InitializedDiv",
            "rhs": " \n<div id=\"WeatherList\">  <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#WeatherList"
               },
               {
                  "type": "var",
                  "val": "InitializedNotifyList"
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
         "name": "populate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "appendUrl",
               "rhs": {
                  "args": [
                     {
                        "type": "str",
                        "val": "?q=select%20*%20from%20geo.places%20where%20text%3D%22"
                     },
                     {
                        "args": [
                           {
                              "type": "var",
                              "val": "city"
                           },
                           {
                              "args": [
                                 {
                                    "type": "str",
                                    "val": "%20"
                                 },
                                 {
                                    "args": [
                                       {
                                          "type": "var",
                                          "val": "state"
                                       },
                                       {
                                          "type": "str",
                                          "val": "%22&format=xml"
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
                     }
                  ],
                  "op": "+",
                  "type": "prim"
               },
               "type": "expr"
            },
            {
               "lhs": "woeidData",
               "rhs": {
                  "args": [{
                     "type": "var",
                     "val": "appendUrl"
                  }],
                  "predicate": "dsYahooWoeid",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "woeid",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..woeid.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "woeidData"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "weatherData",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "?w=#{woeid}&u=f"
                  }],
                  "predicate": "dsYahooWeather",
                  "source": "datasource",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "temp",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..yweather$condition.@temp"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "weatherData"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "text",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..yweather$condition.@text"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "weatherData"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "imgsrc",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..image.url.$t"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "weatherData"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "InitializedNotifyList",
               "rhs": " \n<div style = 'background-color:#ffee8c;margin:3px;'>          <a href = ''>  \t           #{text} - #{temp}          <\/a>  \t<img src=\"#{imgsrc}\"/>        <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a55x9"
}
