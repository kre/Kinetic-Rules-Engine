{
   "dispatch": [{"domain": "www.google.com"}],
   "global": [],
   "meta": {
      "logging": "off",
      "name": "Cedar Fort"
   },
   "rules": [
      {
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
         "emit": "\nvar isbn = $K(\"body\").search(/([-0-9xX ]{13}$)(?:[0-9]+[- ]){3}[0-9]*[xX0-9]$/);        function isValidISBN (isbn) {      isbn = isbn.replace(/[^\\dX]/gi, '');      if(isbn.length != 10){        return false;      }      var chars = isbn.split('');      if(chars[9].toUpperCase() == 'X'){        chars[9] = 10;      }      var sum = 0;      for (var i = 0; i < chars.length; i++) {        sum += ((10-i) * parseInt(chars[i]));      };      return ((sum % 11) == 0);    }                   ",
         "foreach": [],
         "name": "isbn",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#body"
               },
               {
                  "type": "var",
                  "val": "carousel"
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
         "name": "carousel",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "carousel",
            "rhs": " \n<iframe scrolling=\"no\" frameborder=\"0\" style=\"width: 990px; height: 256px;\" src=\"http://www.cedarfort.com/kahuga/carousel.jsp\" />  \t\n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "cedarFortAnnotate"
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
         "emit": "\nvar count = 0;  function cedarFortAnnotate(obj){  \t  \tif($K(obj).data(\"domain\") == \"www.shatteredsilencebook.com\"){  \t\tcount++;  \t\treturn '<div id=\"cedarFort'+count+'\"><a href=\"http://cedarfort.com/#{selector%3A%22.ldsba-body%22%2Cmodule%3A%22/ldsba/productDetail.module%22%2Cparameters%3A{product%3A%2220067762%22}}\"><img src=\"http://cedarfort.com/67_214_247_219/ldsba/store/LogoCedarFort.png\" /><\/a><\/div>';    \t}    }              ",
         "foreach": [],
         "name": "annotation",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|www.bing.com|search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x66"
}
