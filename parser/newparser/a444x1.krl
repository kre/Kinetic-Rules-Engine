{
   "dispatch": [
      {"domain": "mormonentrepreneur.net"},
      {"domain": "www.mormonentrepreneur.net"}
   ],
   "global": [],
   "meta": {
      "author": "Karl L. Greenwood",
      "description": "\nContext-sensitive additional content for the online publication Mormon Entrepreneur.    \n",
      "logging": "off",
      "name": "ME-Plus"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "#sidebar"
            },
            {
               "type": "var",
               "val": "me_plus_content"
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
      "name": "issue_3_paul_allen",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "mormonentrepreneur.net/issue-3/paul-allen/",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "me_plus_content",
         "rhs": " \n<h3>ME-PLUS RELATED CONTENT:<\/h3>  <a href=\"http://sites.google.com/site/mormonentplus/files/Holland_Jeffrey_09_1988.pdf\" target=\"_blank\"><img src=\"http://sites.google.com/site/mormonentplus/files/Speeches-Holland.png\"><\/a><br />  <a href=\"http://ilpubs.stanford.edu:8090/361/1/1998-8.pdf\" target=\"_blank\"><img src=\"http://sites.google.com/site/mormonentplus/files/page_brin.png\"><\/a>  \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a444x1"
}
