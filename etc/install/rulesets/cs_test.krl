ruleset cs_test {
    meta {
        name "CS Test 1"
        author "Phil Windley"
        description <<
Ruleset that the eval servers use for self testing (cs.t)     
>>
        logging off    
        key errorstack "192345"
        key googleanalytics  "fg593940"
        key twitter {
          "consumer_key": 5837874827498274939,
          "consumer_secret" : "3HNb7NfdadadadahdajdhgajlkjakldaMtLahvkMt6Std5SO0"
        }

    }
    dispatch {
        domain "www.google.com"
        domain "www.yahoo.com" -> "cs_test_1"
        domain "www.live.com"
    }
    global {
        dataset public_timeline <- "http://twitter.com/statuses/public_timeline.json";        
        dataset cached_timeline <- "http://twitter.com/statuses/public_timeline.json" cachable;
        emit <<
var foobar = 4;                >>
;    }
    rule test_rule_1 is active {
        select using "/([^/]+)/bar.html" setting (x)

        replace("#kynetx_12", "/kynetx/google_ad.inc");
    }
    rule test_rule_2 is active {
        select using "/foo/bazz.html" setting ()

        pre {
        }
        if referer:search_engine_referer()
        then
            every {
                float("absolute", "top: 10px", "right: 10px", ("http://frag.kobj.net/widgets/weather.pl?zip=" + (zip + ("&city=" + (city + ("&state=" + state))))))
                with
                        delay = 0 and
                        draggable = true and
                        effect = "appear";
                float("kynetx_12", "/kynetx/google_ad.inc");
            }
        
    }
    rule test_rule_3 is inactive {
        select using "/foo/bazz.html" setting()

        pre {
        }
        if referer:search_engine_referer()
        then
            every {
                float("absolute", "top: 10px", "right: 10px", ("http://frag.kobj.net/widgets/weather.pl?zip=" + (zip + ("&city=" + (city + ("&state=" + state))))))
                with
                        delay = 0 and
                        draggable = true and
                        effect = "appear";
                float("kynetx_12", "/kynetx/google_ad.inc");
            }
        
    }
    rule test_rule_4 is active {
      select when pageview "/fizzer/fuzzer.html"
      noop();
      always {
        raise explicit event fuzzer for cs_test_1 
           with foo = "bar" 
            and fop = "bop"
      }
    }
    
  rule test_error_1 {
    select when system error
    pre {}
   noop();
  }

  rule test_error_2 {
  select when system error genus "operator"
  pre {}
 noop();
}

}

