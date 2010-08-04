{
   "dispatch": [],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "TestStar"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Hilton? Really? You have a Marriott Rewards Account..."
            },
            {
               "type": "var",
               "val": "msg"
            }
         ],
         "modifiers": [
            {
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            },
            {
               "name": "background_color",
               "value": {
                  "type": "str",
                  "val": "#CACACA"
               }
            },
            {
               "name": "color",
               "value": {
                  "type": "str",
                  "val": "#333333"
               }
            },
            {
               "name": "opacity",
               "value": {
                  "type": "num",
                  "val": 1
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
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "msg",
         "rhs": " \n<div id=\"account\">    \t<p class=\"account_info\"><br />    \t\tNAME: <strong>Russ Babcock<\/strong><br />    \t\tLEVEL: <strong>Marriott Rewards (2 Nights)<\/strong><br />    \t\tBALANCE: <strong>1&#44;340 points<\/strong><br />    \t\t<br />    \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/default.mi\">My Account Overview<\/a><br />    \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/tripPlanner.mi\">Trip Planner<\/a><br />    \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/profile.mi\">Profile<\/a><br />    \t\t<a class=\"account\" href=\"http:\\/\\/www.marriottrewardsinsiders.marriott.com/index.jspa\">Marriott Rewards Insider<\/a>           <\/p>        <\/div>              \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a40x7"
}
