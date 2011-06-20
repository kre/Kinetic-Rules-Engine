ruleset cs_test_1 {
    meta {
        name "CS Test 2"
        author "Phil Windley"
        description <<
Ruleset that the eval servers use for self testing (cs.t)    
>>
        logging off    

    }
    dispatch {
        domain "www.windley.com"
        domain "www.kynetx.com"
    }
    global {
  //      dataset public_timeline <- "http://twitter.com/statuses/public_timeline.json";
  //      dataset cached_timeline <- "http://twitter.com/statuses/public_timeline.json" cachable;
        emit << var foobar = 4;    >>;
        }
    rule test_rule_1 is active {
        select using "/foo/bar.html" setting()

        pre {
        }
                replace("#kynetx_12", "/kynetx/google_ad.inc");
    }
    rule test_rule_2 is active {
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
        select when pageview "/archives/(\d+)/foo.html" setting (year)

                notify("Rule 4", "bar");
    }
    rule test_rule_5 is active {
        select when pageview "bar.html" before
            pageview "/archives/(\d+)/foo.html" setting (year)

                notify("Rule 5", "foo");
    }
    rule test_rule_and is active {
        select when pageview "and1.html" and
            pageview "and2.html"

                notify("Testing And", "foo");
    }
    rule test_rule_or is active {
        select when pageview "or(1).html" setting (num) or
            pageview "or(2).html" setting (num)

                notify("Or Test Rule", "foo");
    }
    rule test_rule_then is active {
        select when pageview "then(1).html" setting (one) then
            pageview "then(2).html" setting (two)

                notify("Test Rule Then", "foo");
    }
    rule test_rule_between is active {
        select when pageview "mi(d).html" setting (b) between(pageview "firs(t).html" setting (a), pageview "las(t).html" setting (c))


                notify("Between Test Rule", "foo");
    }
    rule test_rule_notbetween is active {
        select when pageview "mi(d)n.html" setting (b) not between(pageview "firs(t)n.html" setting (a), pageview "las(t)n.html" setting (c))


                notify("Not Between Test Rule", "foo");
    }
    rule test_rule_submit is active {
        select when web submit "#my_form" setting (my_form)

                noop();
    }
    rule test_rule_google_1 is active {
        select using "google.com/(search)" setting (search)

                noop();
    }
    rule test_rule_google_2 is active {
        select using "google.com" setting ()

                noop();
    }
    // email test rules
    rule email_received is active {
    select when mail received
    pre {}
    email:forward() with
      address = "pjw@kynetx.com" and
      msg_id = 15;
    }
  
    rule email_sent is active {
      select when mail sent
      pre {}
      email:send() with
        to = "qwb@kynetx.com" and
        msg_id = 35;
    }
  
    rule email_received_from is active {
      select when mail received from "(.*)@windley.com" setting(mail_id)
    
      pre {
       rp = page:param("msg").uc();
      }
    
     email:forward() with
       address = mail_id and
        return_path = rp and
        msg_id = 25;
    }

    // .org instead of .com to distinguish emails
    rule email_received_multi is active {
      select when mail received from "(.*)@windley.org" to "swf@fulling.org" subj "Hey (\w+)" setting(mail_id, name)

      email:forward() with
        address = mail_id and
        name = name and
        msg_id = 27;
   }

rule test_explicit is active {
      select when explicit fuzzer foo "bar"
      append("#my_div", "Hello!");
    }
}