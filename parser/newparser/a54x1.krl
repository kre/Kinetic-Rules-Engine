{
   "dispatch": [{"domain": "ipac.slco.lib.ut.us"}],
   "global": [],
   "meta": {
      "author": "Steve Spigarelli",
      "description": "\nShow availability for items at the Salt Lake County Library    \n",
      "logging": "off",
      "name": "Salt Lake County Item Availability"
   },
   "rules": [{
      "actions": [{"action": {
         "args": [
            {
               "type": "str",
               "val": "Current Availability"
            },
            {
               "type": "str",
               "val": "#{spignet.get_libitem_availability()}"
            }
         ],
         "modifiers": [{
            "name": "sticky",
            "value": {
               "type": "bool",
               "val": "true"
            }
         }],
         "name": "notify",
         "source": null
      }}],
      "blocktype": "every",
      "callbacks": null,
      "cond": {
         "type": "bool",
         "val": "true"
      },
      "emit": "\nvar DVD = 2;    var BOOK = 1;    var AUDIOBOOK = 3;      var availability = \"no availability determined\";    var holds = 0;    var available = 0;    var format = null;      var spignet = {      get_libitem_availability: function() {        $K(\"td\").each(function() {          if ($K(this).text().match(/^Holds/)) {            holds = $K(this).parent().text().match(/\\d+/);          }          if ($K(this).text().match(/^Available/)) {            available = $K(this).parent().text().match(/\\d+/);          }          if (format == null && $K(this).parent().text().match(/^Format/)) {            if ($K(this).parent().html().match(/ipac_dvd\\.jpg/)) {              format = DVD;            }            else if ($K(this).parent().html().match(/ipac_book_icon\\.gif/)) {              format = BOOK;            }          }        });          if (available > 0) {                  if (holds < available) {            availability = \"Available Now\";          }                  else if (available >= holds/2) {            availability = \"Short Wait\";          }                  else if (available < holds/2) {            availability = \"Long Wait\";          }        }        console.log(availability);        return availability;      }    };          ",
      "foreach": [],
      "name": "slc_book_dvd_availability",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://ipac\\.slco\\.lib\\.ut\\.us\\/.*link=",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a54x1"
}
