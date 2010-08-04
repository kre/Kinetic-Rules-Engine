{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "yahoo.com"},
      {"domain": "bing.com"}
   ],
   "global": [{
      "content": "\n    .badge {\n      height: 25px;\n    }\n  ",
      "type": "css"
   }],
   "meta": {
      "author": "Dan R. Olsen",
      "description": " \n    An app that will show a variety icons for different sites that show up search results.\n    \n    This app extends the StackOverflow fan app created by Michael Grace. (http://appdirectory.kynetx.com/app/a60x17)\n  ",
      "logging": "on",
      "name": "Search Result Indicators"
   },
   "rules": [{
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
      "emit": "\n    function my_select(obj) {      \n      var domain = $K(obj).data(\"domain\");\n            \n      if (domain.match(/stackoverflow.com/)) {        \n        return \"<img class='badge stackoverflow' src='http://dansworkshop.net/kynetx/images/stackoverflow.jpg' />\";      \n      } else if (domain.match(/google.com/)) {\n        return \"<img class='badge google' src='http://dansworkshop.net/kynetx/images/Google_G.jpg' />\";\n      } else if (domain.match(/wikipedia.org/)) {\n        return \"<img class='badge wikipedia' src='http://dansworkshop.net/kynetx/images/wikipedia-logo.jpg' />\";\n      } else if (domain.match(/youtube.com/)) {\n        return \"<img class='badge youtube' src='http://dansworkshop.net/kynetx/images/youtube.gif' />\";\n      } else if (domain.match(/about.com/)) {\n        return \"<img class='badge about' src='http://dansworkshop.net/kynetx/images/about.gif' />\";\n      } else {        \n        return false;     \n      }    \n    }         \n  ",
      "foreach": [],
      "name": "search",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a57x3"
}
