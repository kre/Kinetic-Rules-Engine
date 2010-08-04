{
   "dispatch": [{"domain": ".*"}],
   "global": [{"emit": "\nfunction createCookie(name,value,days) {            if (days) {    \t\tvar date = new Date();    \t\tdate.setTime(date.getTime()+(days*24*60*60*1000));    \t\tvar expires = \"; expires=\"+date.toGMTString();    \t}    \telse var expires = \"\";    \tdocument.cookie = name+\"=\"+value+expires+\"; path=/\";    }        function readCookie(name) {    \tvar nameEQ = name + \"=\";    \tvar ca = document.cookie.split(';');    \tfor(var i=0;i < ca.length;i++) {    \t\tvar c = ca[i];    \t\twhile (c.charAt(0)==' ') c = c.substring(1,c.length);    \t\tif (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);    \t}    \treturn null;    }        function eraseCookie(name) {    \tcreateCookie(name,\"\",-1);    }                "}],
   "meta": {
      "description": "\nCiti Demo   \n",
      "logging": "off",
      "name": "Citi - Private Pass Card"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": ""
            },
            {
               "type": "var",
               "val": "msg"
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
               "name": "text_color",
               "value": {
                  "type": "str",
                  "val": "#000000"
               }
            },
            {
               "name": "background_color",
               "value": {
                  "type": "str",
                  "val": "#CCCCCC"
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
      }}],
      "blocktype": "every",
      "callbacks": {"success": [{
         "attribute": "class",
         "trigger": null,
         "type": "click",
         "value": "KOBJ_privatePass"
      }]},
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nif(readCookie(\"KOBJ_privatePass\") != null) {    \treturn;      }      else {  \tcreateCookie(\"KOBJ_privatePass\",\"privatePass\");      }            ",
      "foreach": [],
      "name": "annoyingpopup",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "linkedin.com",
         "type": "prim_event",
         "vars": []
      }},
      "post": {
         "cons": [{
            "type": "log",
            "what": {
               "type": "str",
               "val": "thanks"
            }
         }],
         "type": "fired"
      },
      "pre": [
         {
            "lhs": "msg",
            "rhs": " \n<div style=\"margin-top: 15px; opacity: 1.0; padding: 20px 10px 40px 10px; -moz-border-radius: 5px; background-color: #FAFAFA; color:#000; text-align: center; float:center; align:center; border: 1px solid black\">    <center>       <span style=\"font-family:sans-serif;font-size:large;color:#666666\">CITI&copy; PRIVATE PASS&copy;<\/span>    <\/center>    <a href=\"http://www.citiprivatepass.com/#/landings/lan_U2\">       <img src=\"http://www.azigo.com/sales-demo/PrivatePassAd.jpg\" width=\"210px\" style=\"border-style: none; margin-right:5px;\">    <\/a>  <!--    <div style=\"text-align: left; float:left; align:left; width: 100%; margisn-top:-40px; \">       <img src=\"http://www.azigo.com/sales-demo/CitiLogo.png\" height=\"34px\">      <\/div>  -->    <div style=\"text-align: right; float:right; align:right; width: 100%\">         <img align=\"right\" src=\"http://www.azigo.com/sales-demo/PoweredByAzigo.png\">    <\/div>  <\/div>  \n ",
            "type": "here_doc"
         },
         {
            "lhs": "msgtitle",
            "rhs": {
               "type": "str",
               "val": ""
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a58x16"
}
