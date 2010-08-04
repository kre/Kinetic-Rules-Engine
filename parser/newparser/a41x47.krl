{
   "dispatch": [{"domain": "facebook.com"}],
   "global": [],
   "meta": {
      "description": "\nAdds ads to Facebook   \n",
      "logging": "off",
      "name": "Facebook Ads"
   },
   "rules": [{
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
      "emit": "\nif($K(\"#home_left_column\").length) {  \t$K(\"#home_left_column\").before('<iframe frameborder=\"0\" width=\"740px\" scrolling=\"no\" src=\"http://www.caandb.com/kynetx/googleads.html\">Please update your browser!<\/iframe>');  } else if($K(\"#tab_content\").length) {  \t$K(\"#tab_content\").before('<iframe frameborder=\"0\" width=\"740px\" scrolling=\"no\" src=\"http://www.caandb.com/kynetx/googleads.html\">Please update your browser!<\/iframe>');  }            ",
      "foreach": [],
      "name": "facebook",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "www.facebook.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a41x47"
}
