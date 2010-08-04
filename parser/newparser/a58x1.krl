{
   "dispatch": [],
   "global": [{"emit": "\nKOBJ.delta = {\"www.1800flowers.com\" :                   [{\"link\":                     \"http://skymilesoffers.delta.com/shopping_other.php\",    \t\t \"text\":    \t\t \"Get discounts on flowers!\"                    }                   ]    \t\t};                           "}],
   "meta": {
      "description": "\nBBB Rules   \n",
      "logging": "off",
      "name": "BBB"
   },
   "rules": [{
      "actions": [
         {"action": {
            "args": [
               {
                  "type": "str",
                  "val": "BBB Warning"
               },
               {
                  "type": "var",
                  "val": "invite"
               }
            ],
            "modifiers": [
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               },
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               }
            ],
            "name": "notify",
            "source": null
         }},
         {"action": {
            "args": [{
               "type": "str",
               "val": "span.no_thanks"
            }],
            "modifiers": null,
            "name": "close_notification",
            "source": null
         }}
      ],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\n        ",
      "foreach": [],
      "name": "bbb_warning",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "https://rh157.azigo.net:8443/verizon/phish.jsp",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [{
         "lhs": "invite",
         "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 4pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\">    <table border=\"0\" style=\"margin-left:50px; margin-right:50px\";>  <tr>   <td><img src=\"http://media.wkrg.com/images/sized/media/news4/BBB_logo-300x461.jpg\" width=\"120px\" height=\"200px\"><\/td>    <\/tr>  <\/table>  <center>  <table border=\"0\" style=\"margin-top: 20px; align:center;\" >  <tr>  <td>This is a known <b>scam site!<\/b><\/td>  <\/tr>  <tr>  <td  style=\"align:center;\"><span style=\"align:center;\">BBB Rating: F<\/span><\/td>  <\/tr>  <\/table>  <\/center>  <\/div>  <\/p>  <\/div>     \n ",
         "type": "here_doc"
      }],
      "state": "active"
   }],
   "ruleset_name": "a58x1"
}
