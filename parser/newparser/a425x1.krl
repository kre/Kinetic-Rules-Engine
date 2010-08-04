{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "www.youtube.com"}
   ],
   "global": [{
      "content": ".content    {        color:#FFFFFF;    \tfont-family:Arial, Helvetica, sans-serif;    \tfont-size:12px;    \tpadding:5px;    }         .content a:link    {    \tcolor: #FFFFFF;    \tfont-weight:bold;    \ttext-decoration:none;    }         .content a:hover    {    \tcolor: #FFFF00;    \tfont-weight:bold;    \ttext-decoration: underline;    }         .content a:visited    {    \tcolor: #FFFF00;    \tfont-weight:bold;    \ttext-decoration:none;    }         .content a:visited:hover    {    \tcolor: #FFFF00;    \tfont-weight:bold;    \ttext-decoration: underline;    }                 ",
      "type": "css"
   }],
   "meta": {
      "description": "\nYoutube Connect   \n",
      "logging": "off",
      "name": "StageGold"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Great News!"
               },
               {
                  "type": "var",
                  "val": "msg"
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
         "name": "rule_one",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<div >                  <p class=\"content\" >You've just found Custom Youtube Video Players Available On: <a href=\"http://www.stagegold.com\">StageGold<\/a><\/p>              <\/div>      \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Great News!"
               },
               {
                  "type": "var",
                  "val": "msg"
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
         "name": "rule_two",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.youtube.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<div >                  <p class=\"content\" >Fun Custom Youtube Video Players Available On: <a href=\"http://www.stagegold.com\">StageGold<\/a><\/p>              <\/div>      \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a425x1"
}
