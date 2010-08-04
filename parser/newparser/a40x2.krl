{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "bing.com"},
      {"domain": "hilton.com"},
      {"domain": "kayak.com"},
      {"domain": "accor.com"}
   ],
   "global": [{
      "content": "p.account_info    {    font-size:11px;    }        p.reservation_info    {    font-size:11px;    }        p.activity_info    {    font-size:11px;    }        p.promotion_info    {    font-size:11px;    }        .kGrowl-notification    {        z-index: 2147483583;    }        hr    {    border: 0;    width: 100%;    color: #ffffff;    background-color: #ffffff;    height: 1px;    display: block;    }    ",
      "type": "css"
   }],
   "meta": {
      "author": "Russ Babcock",
      "description": "\nAnnotates search results for Marriott properties and displays Marriott Rewards account info on various sites    \n",
      "logging": "off",
      "name": "Marriott Rewards"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": [
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "foo"
                  }
               },
               {
                  "name": "head_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               },
               {
                  "name": "tail_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {          var ftext = $K(obj).data('url');      var urllist = [  \t\"http://www.marriott.com/city/las-vegas-hotels\",  \t\"http://www.marriott.com/hotels/travel/slcut-salt-lake-city-marriott-downtown/\",  \t\"http://www.marriott.com/hotels/travel/sfodt-san-francisco-marriott-marquis\",  \t\"http://www.marriott.com/hotels/travel/slccc-salt-lake-city-marriott-city-center\",  \t\"http://www.marriott.com/hotels/travel/sfodt-san-francisco-marriott/\",  \t\"http://www.marriott.com/hotels/travel/slccc-salt-lake-city-marriott-city-center/\",  \t\"http://www.tripadvisor.com/Hotel_Review-g45963-d567617-Reviews-Marriott_s_Grand_Chateau-Las_Vegas_Nevada.html\",  \t\"http://www.expedia.com/Salt-Lake-City-Hotels-Marriott.0-0-d178302--bMarriott.Travel-Guide-Filter-Hotels\",  \t\"http://travel.yahoo.com/p-hotel-344783-jw_marriott_hotel_san_francisco-i\",  \t\"https://www.marriott.com/city/las-vegas-hotels\"        ];  \tfoundmatch = false;  \tfor(i in urllist){  \t\turl = urllist[i];  \t\tif(ftext === url){  \t\t\tfoundmatch = true;  \t\t\tbreak;  \t\t}  \t}  \tif(foundmatch){  \t\treturn \"<span><a target='_blank' href='https://www.marriott.com/signIn.mi'><img style='border-width:0px 0px 0px 0px;' class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/mhrs_logo_74x28.gif' /><\/a><\/span>\";    \t}  \telse {          false;        }      }               ",
         "foreach": [],
         "name": "search_marriott",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Hilton? Really? You have a Marriott Rewards Account..."
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#CACACA"
                  }
               },
               {
                  "name": "color",
                  "value": {
                     "type": "str",
                     "val": "#333333"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               }
            ],
            "name": "notify",
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
         "name": "hilton",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www1.hilton.com/en_US/hi/index.do",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<div id=\"account\">  \t<p class=\"account_info\"><br />  \t\tNAME: <strong>Russ Babcock<\/strong><br />  \t\tLEVEL: <strong>Marriott Rewards (2 Nights)<\/strong><br />  \t\tBALANCE: <strong>1&#44;340 points<\/strong><br />  \t\t<br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/default.mi\">My Account Overview<\/a><br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/tripPlanner.mi\">Trip Planner<\/a><br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/profile.mi\">Profile<\/a><br />  \t\t<a class=\"account\" href=\"http:\\/\\/www.marriottrewardsinsiders.marriott.com/index.jspa\">Marriott Rewards Insider<\/a>         <\/p>      <\/div>          \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Your Marriott Rewards Account"
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#CACACA"
                  }
               },
               {
                  "name": "color",
                  "value": {
                     "type": "str",
                     "val": "#333333"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               }
            ],
            "name": "notify",
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
         "name": "kayak",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.kayak.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<div id=\"account\">  \t<p class=\"account_info\"><br />  \t\tNAME: <strong>Russ Babcock<\/strong><br />  \t\tLEVEL: <strong>Marriott Rewards (2 Nights)<\/strong><br />  \t\tBALANCE: <strong>1&#44;340 points<\/strong><br />  \t\t<br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/default.mi\">My Account Overview<\/a><br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/tripPlanner.mi\">Trip Planner<\/a><br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/profile.mi\">Profile<\/a><br />  \t\t<a class=\"account\" href=\"http:\\/\\/www.marriottrewardsinsiders.marriott.com/index.jspa\">Marriott Rewards Insider<\/a>      <\/p>      <\/div>          \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Your Marriott Rewards Account"
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#CACACA"
                  }
               },
               {
                  "name": "color",
                  "value": {
                     "type": "str",
                     "val": "#333333"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "num",
                     "val": 1
                  }
               }
            ],
            "name": "notify",
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
         "name": "accor",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://accor.com/en.html",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msg",
            "rhs": " \n<div id=\"account\">  \t<p class=\"account_info\"><br />  \t\tNAME: <strong>Russ Babcock<\/strong><br />  \t\tLEVEL: <strong>Marriott Rewards (2 Nights)<\/strong><br />  \t\tBALANCE: <strong>1&#44;340 points<\/strong><br />  \t\t<br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/default.mi\">My Account Overview<\/a><br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/tripPlanner.mi\">Trip Planner<\/a><br />  \t\t<a class=\"account\" href=\"https:\\/\\/www.marriott.com/rewards/myAccount/profile.mi\">Profile<\/a><br />  \t\t<a class=\"account\" href=\"http:\\/\\/www.marriottrewardsinsiders.marriott.com/index.jspa\">Marriott Rewards Insider<\/a>              <\/p>      <\/div>          \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": [
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "foo"
                  }
               },
               {
                  "name": "head_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               },
               {
                  "name": "tail_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {          var ftext = $K(obj).data('url');      var urllist = [  \t\"http://www.marriott.com/hotels/travel/slcfa-fairfield-inn-and-suites-salt-lake-city-airport/\",  \t\"http://www.marriott.com/hotels/travel/slcfi-fairfield-inn-salt-lake-city-south/\",  \t\"http://www.marriott.com/hotels/travel/sfofs-fairfield-inn-and-suites-san-francisco-san-carlos/\",  \t\"http://www.marriott.com/hotels/travel/lasfs-fairfield-inn-and-suites-las-vegas-south/\",  \t\"http://san-francisco-hotels.travelape.com/fairfield-inn-and-stes-marriott-hotel-san-francisco.html\",  \t\"http://www.tripadvisor.com/Hotel_Review-g45963-d91814-Reviews-Fairfield_Inn_Las_Vegas_Airport-Las_Vegas_Nevada.html\",  \t\"http://travel.yahoo.com/p-hotel-350202-fairfield_inn_by_marriott_salt_lake_city_south-i\"      ];  \tfoundmatch = false;  \tfor(i in urllist){  \t\turl = urllist[i];  \t\tif(ftext === url){  \t\t\tfoundmatch = true;  \t\t\tbreak;  \t\t}  \t}  \tif(foundmatch){  \t\treturn \"<span><a target='_blank' href='https://www.marriott.com/signIn.mi'><img style='border-width:0px 0px 0px 0px;' class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/ffi_logo_71x45.gif' /><\/a><\/span>\";    \t}  \telse {          false;        }      }               ",
         "foreach": [],
         "name": "search_fairfield",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": [
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "foo"
                  }
               },
               {
                  "name": "head_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               },
               {
                  "name": "tail_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {          var ftext = $K(obj).data('url');      var urllist = [  \t\"http://www.marriott.com/hotels/travel/lasnv-residence-inn-las-vegas-convention-center/\",  \t\"http://www.marriott.com/hotels/travel/sfori-residence-inn-san-francisco-airport-oyster-point-waterfront/\",  \t\"http://www.marriott.com/hotels/travel/slctt-residence-inn-salt-lake-city-cottonwood/\",  \t\"http://www.marriott.com/hotels/travel/slcri-residence-inn-salt-lake-city-city-center/\",  \t\"http://www.tripadvisor.com/Hotel_Review-g60922-d110045-Reviews-Residence_Inn_Salt_Lake_City_City_Center-Salt_Lake_City_Utah.html\",  \t\"http://travel.yahoo.com/p-hotel-389592-residence_inn_by_marriott_las_vegas_hughes_center-i\",  \t\"http://www.all-hotels.com/residence-inn/usa/california/central_coast/san_francisco/home.htm\",      ];  \tfoundmatch = false;  \tfor(i in urllist){  \t\turl = urllist[i];  \t\tif(ftext === url){  \t\t\tfoundmatch = true;  \t\t\tbreak;  \t\t}  \t}  \tif(foundmatch){  \t\treturn \"<span><a target='_blank' href='https://www.marriott.com/signIn.mi'><img style='border-width:0px 0px 0px 0px;' class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/ri_logo_71x45.gif' /><\/a><\/span>\";    \t}  \telse {          false;        }      }               ",
         "foreach": [],
         "name": "search_residence",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": [
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "foo"
                  }
               },
               {
                  "name": "head_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               },
               {
                  "name": "tail_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {          var ftext = $K(obj).data('url');      var urllist = [  \t\"http://www.marriott.com/hotels/travel/slccy-courtyard-salt-lake-city-downtown/\",  \t\"http://www.marriott.com/hotels/travel/sfocd-courtyard-san-francisco-downtown/\",  \t\"http://www.marriott.com/hotels/travel/lasch-courtyard-las-vegas-convention-center/\",  \t\"http://www.tripadvisor.com/Hotel_Review-g33116-d223970-Reviews-Courtyard_San_Francisco_Airport_Oyster_Point_Waterfront-South_San_Francisco_California.html\",  \t\"http://www.tripadvisor.com/Hotel_Review-g45963-d294793-Reviews-Courtyard_by_Marriott_Las_Vegas_South-Las_Vegas_Nevada.html\",  \t\"http://www.tripadvisor.com/Hotel_Review-g60922-d110047-Reviews-Courtyard_by_Marriott_Salt_Lake_City_Downtown-Salt_Lake_City_Utah.html\"      ];  \tfoundmatch = false;  \tfor(i in urllist){  \t\turl = urllist[i];  \t\tif(ftext === url){  \t\t\tfoundmatch = true;  \t\t\tbreak;  \t\t}  \t}  \tif(foundmatch){  \t\treturn \"<span><a target='_blank' href='https://www.marriott.com/signIn.mi'><img style='border-width:0px 0px 0px 0px;' class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/cy_logo_71x45.gif' /><\/a><\/span>\";    \t}  \telse {          false;        }      }               ",
         "foreach": [],
         "name": "search_courtyard",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "my_select"
            }],
            "modifiers": [
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "foo"
                  }
               },
               {
                  "name": "head_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               },
               {
                  "name": "tail_image",
                  "value": {
                     "type": "str",
                     "val": ""
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction my_select(obj) {          var ftext = $K(obj).data('url');      var urllist = [  \t\"http://www.marriott.com/hotels/travel/slcsh-springhill-suites-salt-lake-city-downtown/\",  \t\"http://www.marriott.com/springhill-suites/travel.mi\",  \t\"http://www.marriott.com/hotels/travel/laspr-springhill-suites-las-vegas-convention-center/\",  \t\"http://www.tripadvisor.com/Hotel_Review-g60922-d321269-Reviews-Springhill_Suites-Salt_Lake_City_Utah.html\",  \t\"http://travel.yahoo.com/p-hotel-472523-springhill_suites_by_marriott_las_vegas_convention_center-i\",  \t\"http://www.tripadvisor.com/Hotel_Review-g60750-d268158-Reviews-SpringHill_Suites_San_Diego_Rancho_Bernardo_Scripps_Poway-San_Diego_California.html\"      ];  \tfoundmatch = false;  \tfor(i in urllist){  \t\turl = urllist[i];  \t\tif(ftext === url){  \t\t\tfoundmatch = true;  \t\t\tbreak;  \t\t}  \t}  \tif(foundmatch){  \t\treturn \"<span><a target='_blank' href='https://www.marriott.com/signIn.mi'><img style='border-width:0px 0px 0px 0px;' class='marriott' src='http://i259.photobucket.com/albums/hh303/drbabcock/Kynetx/shs_logo_71x45.jpg' /><\/a><\/span>\";    \t}  \telse {          false;        }      }               ",
         "foreach": [],
         "name": "search_springhill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "marriott_selector"
            }],
            "modifiers": null,
            "name": "percolate",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nmarriott_data = {  \t\t\"marriott.com\" : {},  \t\t\"www.marriott.com\" : {}\t\t  \t};      \tfunction marriott_selector(obj){  \t\tvar host = $K(obj).data(\"domain\");  \t\t  \t\tvar o = marriott_data[host];  \t\tif(o){  \t\t\treturn true;  \t\t} else {  \t\t\treturn false;  \t\t}  \t}\t\t              ",
         "foreach": [],
         "name": "search_percolate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|search.yahoo.com|bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a40x2"
}
