{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "bing.com"},
      {"domain": "hilton.com"},
      {"domain": "kayak.com"},
      {"domain": "accor.com"}
   ],
   "global": [
      {
         "content": "p.account_info    {    color:#333333;    font-size:11px;    }            ",
         "type": "css"
      },
      {"emit": "\n$K(\"object\").append('<param name=\"wmode\" value=\"opaque\">');                "}
   ],
   "meta": {
      "logging": "off",
      "name": "notify overlay"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Your Marriott Rewards Account"
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
         "name": "reward_account",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "hilton.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<div id=\"account\">  \t     <p class=\"account_info\">  \t\tNAME: <strong>Russ Babcock<\/strong><br />  \t\tLEVEL: <strong>Marriott Rewards (2 Nights)<\/strong><br />  \t\tBALANCE: <strong>1,340 points<\/strong><br />  \t\t<br />  \t\t<a class=\"account\" href=\"https://www.marriott.com/rewards/myAccount/default.mi\">My Account Overview<\/a><br />  \t\t<a class=\"account\" href=\"https://www.marriott.com/rewards/myAccount/tripPlanner.mi\">Trip Planner<\/a><br />  \t\t<a class=\"account\" href=\"https://www.marriott.com/rewards/myAccount/profile.mi\">Profile<\/a><br /><br /><br /><br /><br /><br />  \t\t<a class=\"account\" href=\"http://www.marriottrewardsinsiders.marriott.com/index.jspa\"><\/a><br />\t\t  \t     <\/p>            <\/div>        \n ",
            "type": "here_doc"
         }],
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
         "emit": "\nfunction my_select(obj) {          var ftext = $K(obj).text();            if (ftext.match(/marriott.com/gi)) {           if (ftext.match(/www.tripadvisor.com/Hotel_Review-g60922-d99954-Reviews-Marriott_Salt_Lake_City_University_Park-Salt_Lake_City_Utah.html/gi)) {          return \"<img class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/marriott_logo_gray.png' />\";        }             return \"<img class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/marriott_logo_gray.png' />\";              }   else {          false;        }      }               ",
         "foreach": [],
         "name": "search_annotate",
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
   "ruleset_name": "a60x50"
}
