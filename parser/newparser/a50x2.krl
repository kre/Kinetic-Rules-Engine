{
   "dispatch": [{"domain": "errorstack.com"}],
   "global": [],
   "meta": {
      "description": "\nWelcome message for the initial ErrorStack.com Home page.   \n",
      "logging": "off",
      "name": "ErrorStack.com Welcome"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hello Kynetx Impact 2009 Attendees!"
            },
            {
               "type": "var",
               "val": "msg"
            }
         ],
         "modifiers": null,
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
      "name": "kynetx_integration_popup_on_index_page",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.errorstack.com/$",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "msg",
         "rhs": " \n<br>ErrorStack integrates with Kynetx. <br><br>Login to find out how.   \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a50x2"
}
