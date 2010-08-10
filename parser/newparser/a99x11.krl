{
   "dispatch": [
      {"domain": "cnn.com"},
      {"domain": "facebook.com"},
      {"domain": "bing.com"},
      {"domain": "google.com"}
   ],
   "global": [],
   "meta": {
      "description": "\nThe Ellen Show   \n",
      "logging": "off",
      "name": "WB/Ellen"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#medium_rectangle"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
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
         "name": "cnn_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.cnn.com/|http://www.cnn.com/?.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<center>  <br>  <span class=\"optini_ad_slug\">  <font class=\"optini_ad_slug_font\" size=\"-2\" face=\"Arial\">ADVERTISEMENT<\/font>  <br/>  <\/span>  <div id=\"optini_ad\" text-align: center; visibility: visible;> <!-- VuLiquid Invocation Code goes here -->  <iframe id='a7d2a869' name='a7d2a869' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=40&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='300' height='250' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a1362a26&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=40&amp;cb=#{cb}&amp;n=a1362a26' border='0' alt='' /><\/a><\/iframe>  <\/div>    <br>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "var",
                  "val": "selector"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "after",
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
         "name": "google_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "selector",
               "rhs": " \n\"font[size=-1]:first,#footer_about_igoogle_link,#flp\"\n ",
               "type": "here_doc"
            },
            {
               "lhs": "content",
               "rhs": " \n<!---->  <center>  <div id=\"optini_content\">  <!-- vuLiquid Invocation code goes here -->  <!---->  <iframe id='a081d6c7' name='a081d6c7' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=56&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='468' height='60' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a7706e9b&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=56&amp;cb=#{cb}&amp;n=a7706e9b' border='0' alt='' /><\/a><\/iframe>  <\/div>  <\/center>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#home_sidebar"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
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
         "name": "facebook_com_homepage",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "facebook.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<div id=\"Optini_Logo\">  <!--  \t    <div class=\"UIHomeBox UITitledBox\" id=\"Logo_Zone\" style=\"margin-bottom: 0px;\">                   <!-- Put Logo Content Here -->              <\/div>  \t\t<div class=\"UITitledBox_Content\" style=\"text-align: center;\">  \t\t    <img src=\"#logo_src\" alt=\"Logo\" /><a href=\"#\"><img src=\"http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x53/image4.jpg\" alt=\"Become a Fan\" style=\"margin-top: -10px; margin-bottom: 10px;\" /><\/a>  \t\t<\/div>  -->  \t<\/div>              <div class=\"UITitledBox_TitleBar\"><\/div>              <div class=\"UITitledBox_TitleBar\">  \t         <span class=\"UITitledBox_Title\">  \t\t\tHighlights  \t\t <\/span>  \t    <\/div>  \t\t\t\t  \t    <div class=\"optini_content\">              <!-- VuLiquid invocation code goes here -->                <!---->                  <iframe id='aac5dd4d' name='aac5dd4d' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=41&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='300' height='250' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a5590d2f&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=41&amp;cb=#{cb}&amp;n=a5590d2f' border='0' alt='' /><\/a><\/iframe>    \t    <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#results_area"
               },
               {
                  "type": "var",
                  "val": "content"
               }
            ],
            "modifiers": null,
            "name": "prepend",
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
         "name": "bing_com_search_results",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.bing.com/.*q=.*&.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "cb",
               "rhs": {
                  "args": [{
                     "type": "num",
                     "val": 999999999999
                  }],
                  "predicate": "random",
                  "source": "math",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "content",
               "rhs": " \n<center>  <br>  <span class=\"optini_ad_slug\">  <font class=\"optini_ad_slug_font\" size=\"-2\" face=\"Arial\">ADVERTISEMENT<\/font>  <br/>  <\/span>    <div id=\"optini_ad\" text-align: center; visibility: visible;>  <!---->    <iframe id='ac423d2c' name='ac423d2c' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=55&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='468' height='60'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a82c7e47&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=55&amp;cb=#{cb}&amp;n=a82c7e47' border='0' alt='' /><\/a><\/iframe>      <\/div>  <\/center>  <br>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a99x11"
}
