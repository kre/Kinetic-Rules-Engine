{
   "dispatch": [{"domain": "cnn.com"}],
   "global": [],
   "meta": {
      "description": "\nMy App   \n",
      "logging": "off",
      "name": "Masooma"
   },
   "rules": [{
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
            "rhs": " \n<center>    <!--  <div id=\"optini_ad\" text-align: center; visibility: visible;>   <iframe id='afa96610' name='afa96610' src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/afr.php?zoneid=69&amp;cb=#{cb}' framespacing='0' frameborder='no' scrolling='no' width='300' height='250' allowtransparency='true'><a href='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/ck.php?n=a73e9e69&amp;cb=#{cb}' target='_blank'><img src='http:\\/\\/vue.us.vucdn.com/x282/www/delivery/avw.php?zoneid=69&amp;cb=#{cb}&amp;n=a73e9e69' border='0' alt='' /><\/a><\/iframe>  -->  <div id='Optini_Logo'>  <div id='Optini_Ad' align=\"center\">  <script>  var m3_u = document.location.protocol + \"//\" + \"vue.us.vucdn.com/x282/www/delivery/ajs.php\";  var m3_r = Math.floor(Math.random()*99999999999);  var zone = \"158\";   if( !document.MAX_used ) {   document.MAX_used = ',';  }    var src = \"?zoneid=\"+ zone + '&cb=' + m3_r;    if( document.MAX_used != ',' ) {   src += \"&exclude=\" + document.MAX_used;  }  \t\t\t  src += document.charset ? '&charset='+document.charset : (document.characterSet ? '&charset='+document.characterSet : '');  \t\t  src += \"&loc=\" + escape(window.location);  \t\t  if(document.referrer) {   src += \"&referer=\" + escape(document.referrer);  }    if(document.context) {   src += \"&context=\" + escape(document.context);  }    if(document.mmm_fo) {   src += \"&mmm_fo=1\";  }    src += \"&url=\" + escape(m3_u);  src = \"http:\\/\\/vuliquid.optini.com/x282/www/delivery/bridge.php\" + src;    jQuery('<scr'+'ipt/>').attr('src', src).appendTo('#Optini_Ad');    <\/script>  <\/div>  <\/div>      <\/div>    <br>    \n ",
            "type": "here_doc"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a437x3"
}
