{
   "dispatch": [],
   "global": [
      {
         "cachable": {
            "period": "seconds",
            "value": "5"
         },
         "datatype": "JSON",
         "name": "diegoevents",
         "source": "http://pipes.yahoo.com/pipes/pipe.run?_id=eab72a01b7076f8bc91edc54dbcc062d&_render=json",
         "type": "dataset"
      },
      {
         "content": "\n        .divInfo { display:none; }        \n        #main { border: 5px black solid; padding: 10px; background-color: #FFF; font-size: 12px; margin: 0px; text-align: left; font-family: Arial, \"Halvetica Neue\", Halvetica; line-height: 18px; }        \n        #ulist ul { margin: 0px; padding: 0px; list-style-type: none; }    \n        #ulist li { margin: 0px; padding-bottom: 3px; text-transform: uppercase; font-weight: bold; } \n        #ulist li a { color: #000; text-decoration: none; font-size: 14px; font-family:\"Lucida Grande\", \"Lucida Sans Unicode\", Verdana, Arial, Helvetica, sans-serif; }    \n        #ulist li a:hover { color: #F00; }        \n        #a p { border-bottom:1px solid #CCC; padding: 10px; }        \n        .frame { height:350px; overflow:-moz-scrollbars-vertical; overflow-y:auto; margin:5px 0px; }        \n        #sponsor {margin: 200px 0px; }   \n        #sponsor img { margin: 25px 25px; }     \n        ",
         "type": "css"
      }
   ],
   "meta": {
      "author": "Mark Mugleston",
      "description": " MashWorx Convention Application ",
      "keys": {"twitter": {
         "consumer_key": "QBTDFxelRf3VIx6CAXig",
         "consumer_secret": "lP4D9IAFPEI2hkv2QuiXC1XJWRm1n7w1ZJDXoZiao"
      }},
      "logging": "off",
      "name": "Convention App"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": [
            {
               "name": "message",
               "value": {
                  "type": "var",
                  "val": "msg"
               }
            },
            {
               "name": "topPos",
               "value": {
                  "type": "str",
                  "val": "0px"
               }
            },
            {
               "name": "tabColor",
               "value": {
                  "type": "str",
                  "val": ""
               }
            },
            {
               "name": "backgroundColor",
               "value": {
                  "type": "str",
                  "val": "white"
               }
            },
            {
               "name": "imageHeight",
               "value": {
                  "type": "str",
                  "val": "253px"
               }
            },
            {
               "name": "imageWidth",
               "value": {
                  "type": "str",
                  "val": "43px"
               }
            },
            {
               "name": "pathToTabImage",
               "value": {
                  "type": "str",
                  "val": "http://www.mashworx.com/images/mash-tab.png"
               }
            },
            {
               "name": "width",
               "value": {
                  "type": "str",
                  "val": "325px"
               }
            },
            {
               "name": "height",
               "value": {
                  "type": "str",
                  "val": "400px"
               }
            }
         ],
         "name": "sidetab",
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
      "name": "tab",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "title",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[0].y:title"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "link",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[0].link"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "description",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[0].description"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "title2",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[1].y:title"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "link2",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[1].link"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "description2",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[1].description"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "title2",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[2].y:title"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "link2",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[2].link"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "description2",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "$.value.items[2].description"
               }],
               "name": "ick",
               "obj": {
                  "type": "var",
                  "val": "diegoevents"
               },
               "type": "operator"
            },
            "type": "expr"
         },
         {
            "lhs": "msg",
            "rhs": "    \n<script type=\"text/javascript\">\n            function ToggleList(IDS) {      \n              HideRange('ulist','div',IDS);      \n              var CState = document.getElementById(IDS);      \n  \n              if (CState.style.display != \"block\") { \n                CState.style.display = \"block\"; }                                      \n                else { CState.style.display = \"none\"; }    \n              }    \n  \n            function HideRange(sect,elTag,IDS) {      \n              var ContentObj = document.getElementById(sect);      \n              var AllContentDivs = ContentObj.getElementsByTagName(elTag);      \n              for (i=0; i<AllContentDivs.length; i++) {        \n                if (IDS != AllContentDivs[i].id) { AllContentDivs[i].style.display=\"none\"; }      \n              }   \n            }\n<\/script>   \n               \n<div id=\"main\">    \n  <ul id=\"ulist\" style=\"list-style-type:none; margin: 0; padding: 0;\">    \n    <li><a href=\"#\" onclick=\"ToggleList('a');return false\">Agenda<\/a><\/li>        \n\t\t<div id=\"a\" class=\"divInfo frame\" style=\"border: 1px solid #CCC;\">    \t\n\t\t\t<p style=\"font-size: 13px; font-weight: bold;\">June 10, 2010<\/p>\n\t\t\t<p><strong>8:00 am - Keynote<\/strong><br/>App Showcase & Contest Winners. Learn how different developers have used MashWorx to create powerful and unique apps.<br/><span style=\"color:#00F; font-style:italic;\">Ron E. Porter<br/>Mashworx COO<\/span><img src=\"http://mashworx.com/images/star.png\" style=\"padding-left: 10px;\" /><\/p>            \n\t\t\t<p><strong>10:00 am - Keynote<\/strong><br/>App Showcase & Contest Winners. Learn how different developers have used MashWorx to create powerful and unique apps.<br/><span style=\"color:#00F; font-style:italic;\">Ron E. Porter<br/>Mashworx COO<\/span><img src=\"http://mashworx.com/images/star.png\" style=\"padding-left: 10px;\" /><\/p>            \n\t\t\t<p><strong>12:00 am - Lunch<\/strong><\/p>            \n\t\t\t<p><strong>2:00 pm - Workshop<\/strong><br/>App Showcase & Contest Winners. Learn how different developers have used MashWorx to create powerful and unique apps.<br/><span style=\"color:#00F; font-style:italic;\">Ron E. Porter<br/>Mashworx COO<\/span><img src=\"http://mashworx.com/images/star.png\" style=\"padding-left: 10px;\" /><\/p>            \n\t\t\t<p><strong>4:00 pm - Workshop<\/strong><br/>App Showcase & Contest Winners. Learn how different developers have used MashWorx to create powerful and unique apps.<br/><span style=\"color:#00F; font-style:italic;\">Ron E. Porter<br/>Mashworx COO<\/span><img src=\"http://mashworx.com/images/star.png\" style=\"padding-left: 10px;\" /><\/p>            \n\t\t\t<p><strong>6:00 am - Dinner<\/strong><br/>Dinner is at \"The Roof\" at Temple Square in Salt Lake City. Directions <a href=\"http://www.templesquarehospitality.com/restaurants/roof.php\">can be found here<\/a>.<\/p>\n  <\/div>       \t\n\t\n\t<li><a href=\"#\" onclick=\"ToggleList('d');return false\">Map & Information<\/a><\/li>        \n\t\t<div id=\"d\" class=\"divInfo frame\" style=\"border: 1px solid #CCC; padding:10px;\">\n\t\t  <ol style=\"padding: 10px; margin-left: 10px;\">\n\t\t    <li><a href=\"http://mashworx.com/images/comiccon-map.jpg\">Floor map<\/a><\/li>\n\t\t    <li><a href=\"http://mashworx.com/images/comiccon-bathrooms.jpg\">Bathroom location<\/a><\/li>\n\t\t    <li><a href=\"http://mashworx.com/docs/test.doc\">Terms<\/a><\/li>\n\t\t    <li><a href=\"http://mashworx.com/docs/test.doc\">Conditions<\/a><\/li>\n\t\t  <\/ol>\n\t\t  <p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<\/p>\n\t\t  <p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<\/p>\n\t\t  \n  <\/div>   \n\t\n\t<li><a href=\"#\" onclick=\"ToggleList('b');return false\">Twitter<\/a><\/li>        \n\t\t<div id=\"b\" class=\"divInfo frame\" style=\"border: 1px solid #CCC; padding: 10px;\">\n      <p><a href=\"http://twitter.com/slaveboyfilms\"><img src=\"http://img.tweetimag.es/i/slaveboyfilms_n\" alt=\"slaveboyfilms\" align=\"left\" style=\"padding-right:10px;\"/>slaveboyfilms<\/a>Comic Con scam! Avoid Elite Locations at all costs when booking hotelshttp:\\/\\/www.comic-con.org/cci/Â\u202022 hours ago<\/p>\n      <p><a href=\"http://twitter.com/satinephoenix\"><img src=\"http://img.tweetimag.es/i/satinephoenix_n\" alt=\"satinephoenix\" align=\"left\" style=\"padding-right:10px;\"/>satinephoenix<\/a>COMIC CON: BEWARE OF Hotel Booking company: ELITE Locations:<strong><a href=\"http://www.comic-con.org/cci/\" rel=\"nofollow\" title=\"http://www.comic-con.org/cci/\">http:\\/\\/bit.ly/3NAxPT<\/a><\/strong>Â\u2020<a href=\"http://twitter.com/satinephoenix/status/14716091738\">23 hours ago<\/a><\/p>\n      <p><a href=\"http://twitter.com/Lenidec\"><img src=\"http://img.tweetimag.es/i/Lenidec_n\" alt=\"Lenidec\" align=\"left\" style=\"padding-right:10px;\" />Lenidec<\/a>RT @<a href=\"http://twitter.com/weight__loss\" rel=\"nofollow\">weight__loss<\/a>: Diet Weight Loss CA Weight Loss Consultant /Sales - Granada Hills CA - the premier weight loss ...<a href=\"http://www.comic-con.org/ape/index.shtml\" rel=\"nofollow\" title=\"http://www.comic-con.org/ape/index.shtml\"><\/p>\n      <p><a href=\"http://twitter.com/Justin_Marsh\"><img src=\"http://img.tweetimag.es/i/Justin_Marsh_n\" alt=\"Justin_Marsh\" align=\"left\" style=\"padding-right:10px;\" />Justin_Marsh<\/a>Whos going COMICON 2010 this year?Â\u2020<strong><a href=\"http://www.comic-con.org/\" rel=\"nofollow\" >http:\\/\\/www.comic-con.org/<\/a><\/strong>Â\u2020<a href=\"http://twitter.com/Justin_Marsh/status/14651393492\">1 day ago<\/a><\/p>\n      <p><a href=\"http://twitter.com/ryandow\"><img src=\"http://img.tweetimag.es/i/ryandow_n\" alt=\"ryandow\" align=\"left\" style=\"padding-right:10px;\"  />ryandow<\/a>Im kind of on the fence about going to APE this year.<strong><a href=\"http://www.comic-con.org/ape/\" rel=\"nofollow\" title=\"http://www.comic-con.org/ape/\">http:\\/\\/www.comic-con.org/ape/<\/a><\/strong>Â\u2020<a href=\"http://twitter.com/ryandow/status/14641963524\">2 days ago<\/a><\/p>\n  <\/div>   \n\t\t\n\t<li><a href=\"#\" onclick=\"ToggleList('c');return false\">Event Photos<\/a><\/li>       \n\t\t<div id=\"c\" class=\"divInfo frame\" style=\"border: 1px solid #CCC; padding: 10px;\">\n\t\t  <b style=\"font-size: 13px; padding-bottom: 10px;\">Current Favorite<\/b> \n\t\t  <img src=\"http://mashworx.com/images/comiccon-girl.jpg\" />\n\t\t  <a href=\"http://flickr.com\"><img src=\"http://mashworx.com/images/up.jpg\" border=\"0\" style=\"padding-right: 5px;\" /><\/a><a href=\"http://flickr.com\">Vote for this photo<\/a>\n\t\t<\/div>    \n\t\t \n <li><a href=\"#\" onclick=\"ToggleList('e');return false\">Feedback<\/a><\/li>        \n\t\t<div id=\"e\" class=\"divInfo frame\" style=\"border: 1px solid #CCC; padding: 10px;\">\n\t\t  <form action=\"http://mashworx.com/scripts/sendemail.php\" method=\"post\">\n\t\t    <label>Speaker\n        <select name=\"speaker\" id=\"speaker\" style=\"padding: 5px; width: 250px; font-family: Helvetica, san-serif; margin: 0; border: 2px solid #ccc;\">\n          <option>Ron Porter<\/option>\n          <option>Mark Mugleston<\/option>\n          <option>Steve Jobs<\/option>\n          <option>Batman<\/option>\n          <option>Super Woman<\/option>\n        <\/select>\n      <\/label>\n      Your Name: <br><input type=\"text\" name=\"realname\" style=\"padding: 5px; width: 250px; font-family: Helvetica, san-serif; margin: 0; border: 2px solid #ccc;\"><br>\n      Your Email: <br><input type=\"text\" name=\"email\" style=\"padding: 5px; width: 250px; font-family: Helvetica, san-serif; margin: 0; border: 2px solid #ccc;\"><br>\n      Your Comments: <br><textarea name=\"comments\" rows=\"5\" cols=\"27\" style=\"padding: 5px; width: 250px; font-family: Helvetica, san-serif; margin: 0; border: 2px solid #ccc;\"><\/textarea><br><br>\n      <input type=\"submit\" value=\"Submit\" style=\"width: 100px; color: #7dd238; font-weight: normal; font-family: arial; text-transform: uppercase; background-color: #101010; text-decoration: none; \">\n\t\t  <\/form>\n\t\t<\/div>   \n\t\t\n <li><a href=\"#\" onclick=\"ToggleList('f');return false\">Resturants<\/a><\/li>        \n\t\t<div id=\"f\" class=\"divInfo frame\" style=\"border: 1px solid #CCC; padding: 10px;\">description 3<\/div>   \n\t\t \n <li><a href=\"#\" onclick=\"ToggleList('g');return false\">Events<\/a><\/li>        \n\t\t<div id=\"g\" class=\"divInfo frame\" style=\"border: 1px solid #CCC; padding: 10px;\" ><div id=\"g_inner\"><\/div><\/div>    \n  <\/ul>        \n  \n  <div id=\"sponsor\" align=\"center\" style=\"margin-top: 10px;\">        \n\t<a href=\"http://wwwmashworx.com\" target=\"blank\"><img src=\"http://www.mashworx.com/clients/mashvent/acxiom.png\" style=\"margin: 5px 5px;\"><\/a>        \n\t<a href=\"http://wwwmashworx.com\" target=\"blank\"><img src=\"http://www.mashworx.com/clients/mashvent/azigo.png\" style=\"margin: 5px 5px;\"><\/a>        \n\t<a href=\"http://wwwmashworx.com\" target=\"blank\"><img src=\"http://www.mashworx.com/clients/mashvent/7bound.png\" style=\"margin: 5px 5px;\"><\/a>        \n\t<a href=\"http://wwwmashworx.com\" target=\"blank\"><img src=\"http://www.mashworx.com/clients/mashvent/mw.png\" style=\"margin: 5px 5px;\"><\/a>        \n\t<a href=\"http://wwwmashworx.com\" target=\"blank\"><img src=\"http://www.mashworx.com/clients/mashvent/fft.png\" style=\"margin: 5px 5px;\"><\/a>        \n\t<p align=\"right\" style=\"font-size: 11px; margin-top: 10px; padding: 0;\">Conference Mash&reg; by <a href=\"http://mashworx.com\" target=\"blank\">MashWorx<\/a>    \n  <\/div>        \n<\/div>   \n\n",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a659x1"
}
