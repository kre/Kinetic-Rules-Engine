{
   "dispatch": [{"domain": "google.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "description": "\nexample app for form fill     \n",
      "logging": "on",
      "name": "Gmail form fill"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Almost there"
            },
            {
               "type": "str",
               "val": "Most of the form has been filled out for you. Fill in the remainder and continue."
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
      "emit": "\n$K(\"input#FirstName\").val(\"Mike\");    $K(\"input#LastName\").val(\"Grace\");    $K(\"input#Email\").val(\"KynetxRocksMySocks\");    $K(\"input#Passwd\").val(\"MuZUxGdc4F4Z%3})Ji2M#>JMrY9ao.?MzpDW4E+23%f^Tb26jN\");    $K(\"input#PasswdAgain\").val(\"MuZUxGdc4F4Z%3})Ji2M#>JMrY9ao.?MzpDW4E+23%f^Tb26jN\");    $K(\"input#SecondaryEmail\").val(\"YouWishYouKnewSoYouCouldSpamMe@Example.com\");    getAvailableNames();    $K(\"select#questions\").focus()          ",
      "foreach": [],
      "name": "new_account_form_fill",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "https://www.google.com/accounts/NewAccount\\.*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a60x56"
}
