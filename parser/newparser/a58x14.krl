{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "maps.google.com"},
      {"domain": "senate.gov"},
      {"domain": "borders.com"},
      {"domain": "flickr.com"},
      {"domain": "imdb.com"},
      {"domain": "movies.com"}
   ],
   "global": [{"emit": "\nfunction attributesType(attribute,optional,authorities) {    \tthis.attribute = attribute;    \tthis.optional=optional;    \tthis.authorities=authorities;    }            function ABX_getABX(dev, appId) {     try {      if (true){         var abx = new ActiveXObject(\"abx2_0.CAXClass\");                      return abx;      } else if (AZIGO.DOM.isMozilla) {       return new ABXAddIn();      }     } catch(ex){      alert(ex.description);     };    }        function getAbxAddIn() {     if (AZIGO.DOM.abxAddIn == null) {      AZIGO.DOM.abxAddIn = ABX_getABX( 'azigo.com', 'form-filler');     }     return AZIGO.DOM.abxAddIn;    }        function getExtAttributes(rp,audience,attrs,where,tokenTypes,onReady) {      var addIn = getAbxAddIn();      addIn.cleanURL = AZIGO.DOM.cleanURL;          addIn.getExtAttributes(rp,\"\",attrs.attribute, attrs.optional,attrs.authorities,\"\", \"\", \"\", \"\");      var retVal = new returnType(addIn.RetValAttribute, addIn.RetValValue);      return retVal;    }        function createCookie(name,value,days) {            if (days) {    \t\tvar date = new Date();    \t\tdate.setTime(date.getTime()+(days*24*60*60*1000));    \t\tvar expires = \"; expires=\"+date.toGMTString();    \t}    \telse var expires = \"\";    \tdocument.cookie = name+\"=\"+value+expires+\"; path=/\";    }        function readCookie(name) {    \tvar nameEQ = name + \"=\";    \tvar ca = document.cookie.split(';');    \tfor(var i=0;i < ca.length;i++) {    \t\tvar c = ca[i];    \t\twhile (c.charAt(0)==' ') c = c.substring(1,c.length);    \t\tif (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);    \t}    \treturn null;    }        function eraseCookie(name) {    \tcreateCookie(name,\"\",-1);    }                        "}],
   "meta": {
      "description": "\nABX Demo   \n",
      "logging": "off",
      "name": "ABX Demo"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "<img src='https://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
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
         "emit": "\nif(readCookie(\"KOBJ_senate\") != null) {    \t    }      goToState = function(){            zipcode = \"02494\";          createCookie(\"KOBJ_senate\",\"thanks\",1);              top.location=\"http://senate.gov/general/contact_information/senators_cfm.cfm?State=\"+state;      }           ",
         "foreach": [],
         "name": "senate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "senate.gov",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\">    <table border=\"0\">  <tr>   <td><span style=\"color: #72BDCA; font-weight:bold;\">Senate.gov<\/span><\/td>   <td><\/td>    <\/tr>  <\/table>    <table border=\"0\" style=\"margin-top: 20px;\" >  <tr>  <td><span>Senators in your state<\/span><\/td>   <td>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/GreenGoButton.png\" width=\"120px\" onclick=\"goToState()\"><\/span>   <\/td>  <\/tr>  <\/table>  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr align=\"center\">   <td colspan=\"2\" align=\"center\">    <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:17px;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>   <\/td>  <\/tr>  <\/table>    <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "<img src='https://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
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
         "emit": "\nif(readCookie(\"KOBJ_flickr\") != null) {    \t    }      goToState = function(){              var state = \"MA\";          var city = \"Needham\";          createCookie(\"KOBJ_flickr\",\"thanks\",1);              top.location=\"http://www.flickr.com/places/USA/\"+state+\"/\"+city;      }           ",
         "foreach": [],
         "name": "flickr",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "flickr.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\">    <table border=\"0\">  <tr>   <td><span style=\"color: #72BDCA; font-weight:bold;\">Flickr<\/span><\/td>   <td><\/td>    <\/tr>  <\/table>    <table border=\"0\" style=\"margin-top: 20px;\" >  <tr>  <td><span>Photos near you<\/span><\/td>   <td>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/GreenGoButton.png\" width=\"120px\" onclick=\"goToState();\"><\/span>   <\/td>  <\/tr>  <\/table>  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr align=\"center\">   <td colspan=\"2\" align=\"center\">    <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:17px;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>   <\/td>  <\/tr>  <\/table>    <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "<img src='https://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
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
         "emit": "\nif(readCookie(\"KOBJ_borders\") != null) {    \t    }       goToState = function(){        var attribute = new attributesType(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?#bZipCode\", false, \"\");      var zipcode = getExtAttributes(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?\", '', attribute, '', '', '').value;        createCookie(\"KOBJ_borders\",\"thanks\",1);            top.location=\"http://www.borders.com/online/store/LocatorResults?zipCode=\"+zipcode+\"&within=50&all_stores=10&currentPage=1&rpp=10\";  }           ",
         "foreach": [],
         "name": "borders",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "borders.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\">    <table border=\"0\">  <tr>   <td><span style=\"color: #72BDCA; font-weight:bold;\">Borders<\/span><\/td>   <td><\/td>    <\/tr>  <\/table>    <table border=\"0\" style=\"margin-top: 20px;\" >  <tr>  <td><span>Find a Borders near you<\/span><\/td>   <td>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/GreenGoButton.png\" width=\"120px\" onclick=\"goToState()\"><\/span>   <\/td>  <\/tr>  <\/table>  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr align=\"center\">   <td colspan=\"2\" align=\"center\">    <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:17px;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>   <\/td>  <\/tr>  <\/table>    <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "<img src='https://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
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
         "emit": "\ngoToState = function(){        var zipcode = \"02494\";      top.location=\"http://www.google.com/movies?hl=en&near=\"+zipcode;  }           ",
         "foreach": [],
         "name": "imdb",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.imdb.com|^http://www.movies.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\">    <table border=\"0\">  <tr>   <td><span style=\"color: #72BDCA; font-weight:bold;\">Movies<\/span><\/td>   <td><\/td>    <\/tr>  <\/table>    <table border=\"0\" style=\"margin-top: 20px;\" >  <tr>  <td><span>Find theaters and showtimes near you<\/span><\/td>   <td>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/GreenGoButton.png\" width=\"120px\" onclick=\"goToState()\"><\/span>   <\/td>  <\/tr>  <\/table>  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr align=\"center\">   <td colspan=\"2\" align=\"center\">    <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:17px;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>   <\/td>  <\/tr>  <\/table>    <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "<img src='https://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
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
         "emit": "\nif(readCookie(\"KOBJ_maps\") != null) {    \t    }      goToState = function(){            var attributeA = new attributesType(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?#bAddress1\", false, \"\");          var attributeS = new attributesType(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?#bState\", false, \"\");          var attributeC = new attributesType(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?#bCity\", false, \"\");          var attributeZ = new attributesType(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?#bZipCode\", false, \"\");              var staddr = getExtAttributes(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?\", '', attributeA, '', '', '').value;          var city = getExtAttributes(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?\", '', attributeC, '', '', '').value;          var state = getExtAttributes(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?\", '', attributeS, '', '', '').value;          var zipcode = getExtAttributes(\"https://www.staples.com/office/supplies/StaplesGuestCheckout?\", '', attributeZ, '', '', '').value;                createCookie(\"KOBJ_maps\",\"thanks\",1);              top.location=\"http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=\"+staddr+\"+\"+city+\"+\"+state+\"+\"+zipcode;      }             ",
         "foreach": [],
         "name": "maps",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "maps.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\">    <table border=\"0\">  <tr>   <td><span style=\"color: #72BDCA; font-weight:bold;\">Maps<\/span><\/td>   <td><\/td>    <\/tr>  <\/table>    <table border=\"0\" style=\"margin-top: 20px;\" >  <tr>  <td><span>Go to your home<\/span><\/td>   <td>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/GreenGoButton.png\" width=\"120px\" onclick=\"goToState()\"><\/span>   <\/td>  <\/tr>  <\/table>  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr align=\"center\">   <td colspan=\"2\" align=\"center\">    <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:17px;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>   <\/td>  <\/tr>  <\/table>    <\/div>  \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a58x14"
}
