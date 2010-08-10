{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "americanrepertorytheatre.com"},
      {"domain": "createacook.com"},
      {"domain": "decordova.org"},
      {"domain": "directtire.com"},
      {"domain": "elephantwalk.com"},
      {"domain": "freshhair.com"},
      {"domain": "gentlegiant.com"},
      {"domain": "goddardhouse.org"},
      {"domain": "inmanoasis.com"},
      {"domain": "innuwindow.com"},
      {"domain": "internationalbike.com"},
      {"domain": "landrys.com"},
      {"domain": "one2onebodyscapes.com"},
      {"domain": "portersquarebooks.com"},
      {"domain": "sullivantire.com"},
      {"domain": "ata.com"},
      {"domain": "backbaybicycles.com"},
      {"domain": "barefoot-books.com"},
      {"domain": "barnesandnoble.com"},
      {"domain": "beaconhillathleticclub.com"},
      {"domain": "bicyclebills.net"},
      {"domain": "bodymechanics.biz"},
      {"domain": "borders.com"},
      {"domain": "bostonbodyworker.com"},
      {"domain": "bostonculinaryarts.com"},
      {"domain": "brooklinebooksmith.com"},
      {"domain": "cambridge culinary.com"},
      {"domain": "cambridgebicycle.com"},
      {"domain": "chezhenri.com"},
      {"domain": "communitybicycle.com"},
      {"domain": "coreypark.com"},
      {"domain": "culinaryunderground.com"},
      {"domain": "curiousg.com"},
      {"domain": "cycleloft.com"},
      {"domain": "easternstandardboston.com"},
      {"domain": "ems.com"},
      {"domain": "exhalespa.com"},
      {"domain": "farinas.com"},
      {"domain": "fitness together.com"},
      {"domain": "gargoylesrestaurant.com"},
      {"domain": "gentlemovers.com"},
      {"domain": "ginzaboston.com"},
      {"domain": "goldsgym.com"},
      {"domain": "harvard.bkstore.com"},
      {"domain": "harvard.com "},
      {"domain": "hcstudioinc.com"},
      {"domain": "healthworksfitness.com"},
      {"domain": "hsacupunctureandmassage.com"},
      {"domain": "isaacsrelocation.com"},
      {"domain": "marathonmoving.com"},
      {"domain": "michaelsmovers.com"},
      {"domain": "mysportsclub.com"},
      {"domain": "nebookfair.com"},
      {"domain": "newbury.edu"},
      {"domain": "newtonvillebooks.com"},
      {"domain": "nicksmovingco.com"},
      {"domain": "olympiamoving.com"},
      {"domain": "performancebike.com"},
      {"domain": "petitrobertbistro.com"},
      {"domain": "precisionmovingcompany.com"},
      {"domain": "providencehouse.org"},
      {"domain": "pyaraaveda.com"},
      {"domain": "quadcycles.com"},
      {"domain": "rei.com"},
      {"domain": "rogerson.org"},
      {"domain": "seldelaterre.com"},
      {"domain": "skimarket.com"},
      {"domain": "solearestaurant.com"},
      {"domain": "specialforcesmoving.com"},
      {"domain": "springhouseinfo.org"},
      {"domain": "stairhoppers.com"},
      {"domain": "station8jp.com"},
      {"domain": "stellabellatoys.com"},
      {"domain": "templebarcambridge.com"},
      {"domain": "tempobistro.com"},
      {"domain": "tuscangrillwaltham.com"},
      {"domain": "vikingmoving.com"},
      {"domain": "wheelworks.com"}
   ],
   "global": [
      {
         "cachable": 1,
         "datatype": "JSON",
         "name": "wbur",
         "source": "http://service.azigo.com/updates/kynetx/datasets/wbur.json",
         "type": "dataset"
      },
      {
         "cachable": 1,
         "datatype": "JSON",
         "name": "wburc",
         "source": "http://service.azigo.com/updates/kynetx/datasets/wburct.json",
         "type": "dataset"
      },
      {
         "cachable": 1,
         "datatype": "JSON",
         "name": "wburds",
         "source": "http://service.azigo.com/updates/kynetx/datasets/wbur.json",
         "type": "datasource"
      },
      {
         "cachable": 0,
         "datatype": "JSON",
         "name": "wbur_search",
         "source": "http://test.azigo.com:9183/solr/nutch?",
         "type": "datasource"
      },
      {
         "content": ".wbur_round {    \tcursor:pointer;     \tcursor:hand;     \tline-height:20px;    \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat right top;     \tpadding-right:16px;     \tvertical-align:middle;    \tdisplay:block;     \tdisplay:inline-block;     \tdisplay:-moz-inline-box;      }        .wbur_round span {     \tbackground: white url(http:\\/\\/www.azigo.com\\/images\\/smgreenbar.jpg) no-repeat left top;    \theight:21px;    \tdisplay:block;    \tdisplay:inline-block;    \tpadding-left:16px; line-height:20px;    }    \ta.wbur_round {color:#FFF !important; font-size:90%; font-weight:bold; text-decoration:none;}    \ta.wbur_round:visited {color:#FFF !important;}    \ta.wbur_round:visited span {color:#FFF !important;}    \ta.wbur_round:hover {background-position:right -21px;}            a.wbur_round:hover span {background-position:left -21px;}            a.astyle:link {text-decoration:underline; color:#0000FF;}            a.astyle:hover {text-decoration:none; color: #000099;}    ",
         "type": "css"
      },
      {"emit": "\nfunction createCookie(name,value,days) {            if (days) {    \t\tvar date = new Date();    \t\tdate.setTime(date.getTime()+(days*24*60*60*1000));    \t\tvar expires = \"; expires=\"+date.toGMTString();    \t}    \telse var expires = \"\";    \tdocument.cookie = name+\"=\"+value+expires+\"; path=/\";    }        function readCookie(name) {    \tvar nameEQ = name + \"=\";    \tvar ca = document.cookie.split(';');    \tfor(var i=0;i < ca.length;i++) {    \t\tvar c = ca[i];    \t\twhile (c.charAt(0)==' ') c = c.substring(1,c.length);    \t\tif (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);    \t}    \treturn null;    }        function eraseCookie(name) {    \tcreateCookie(name,\"\",-1);    }                    "}
   ],
   "meta": {
      "logging": "off",
      "name": "WBUR Dev"
   },
   "rules": [{
      "actions": null,
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": null,
      "foreach": [],
      "name": "wbur",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "^http://www.google.com(?:/search|/webhp|/(?:\\?|$))|^http://search.yahoo.com|^http://search.live.com|^http://search.msn.com",
         "type": "prim_event",
         "vars": []
      }},
      "pre": [
         {
            "lhs": "caller",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "caller"
               }],
               "predicate": "env",
               "source": "page",
               "type": "qualified"
            },
            "type": "expr"
         },
         {
            "lhs": "search_query",
            "rhs": {
               "args": [
                  {
                     "args": null,
                     "name": null,
                     "obj": {
                        "type": "var",
                        "val": "caller"
                     },
                     "type": "operator"
                  },
                  {
                     "args": [
                        null,
                        null
                     ],
                     "op": "*",
                     "type": "prim"
                  }
               ],
               "op": "/",
               "type": "prim"
            },
            "type": "expr"
         }
      ],
      "state": "active"
   }],
   "ruleset_name": "a37x7"
}
