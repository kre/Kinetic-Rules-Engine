{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [{"emit": "\nvar gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");     $K(\"<script src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'><\/script>\").appendTo(\"body\");          KOBJ.trackEvent = function(c, a, l, v){       console.log(\"trackEvent called\");       if(typeof(KOBJ['ga']) != \"undefined\"){         KOBJ.ga._trackEvent(c, a, l, v);       } else {         var delayCommand = \"KOBJ.trackEvent('\"+c+\"','\"+a;         if(!!l) delayCommand +=\"','\"+l;         if(!!v) delayCommand +=\"','\"+v;         delayCommand += \"');\";         window.setTimeout(delayCommand, 100);       }     };         KOBJ.setupGA = function(){      if(typeof(window['_gat']) != \"undefined\"){       KOBJ.ga = _gat._getTracker(\"UA-8852157-4\");       KOBJ.ga._trackPageview();      } else {        window.setTimeout(\"KOBJ.setupGA();\", 100);      }     };     KOBJ.setupGA();                    "}],
   "meta": {
      "author": "Sam Curren",
      "description": "\ndemo of analytics reporting from within KRL     \n",
      "logging": "off",
      "name": "Google Analytics Test"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [],
         "modifiers": null,
         "name": "noop",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nKOBJ.trackEvent(\"rule\", \"fire\");     $K('#logo, #menu img').click(function(){      KOBJ.trackEvent(\"rule\", \"callback\", \"logoclick\");      alert(\"For cute logo sounds, visit Yahoo.com\");     });            ",
      "foreach": [],
      "name": "recordrulefire",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": ".*",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a8x9"
}
