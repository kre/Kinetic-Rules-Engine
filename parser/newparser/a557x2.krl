{
   "dispatch": [
      {"domain": "*.aculis.com"},
      {"domain": "*.google.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nAdvert for Aculis   \n",
      "logging": "off",
      "name": "Aculis_Advertisement"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Aculis - Your one stop tech shop"
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
      "name": "advert_rule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "msg",
         "rhs": " \n<div>  <a style=\"color:white;\" href=\"http://aculis.com\">   <img width=\"90%\" height=\"90%\" src=\"http://i285.photobucket.com/albums/ll70/kaxx77/img_pos_1_dallas_lab_1.jpg\" /> <br>   Get all your technology needs fulfilled at Aculis <\/a>   <\/div>      \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a557x2"
}
