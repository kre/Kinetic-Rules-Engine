// callback, success and click
ruleset 10 {
  rule accept_offer is active {
    select using "/identity-policy/" setting ()

    pre {
     tc = weather:tomorrow_cond_code();
     city = geoip:city();
    }

    if djia_down_more_than(10) then 
      replace("kobj_test", "/kynetx/newsletter_invite.inc");

    callbacks {
      success {
        click id="rssfeed" triggers clear ent:page_counter ;
        click class="newsletter" triggers ent:page_counter += 1 from 1
      } 


    }

  }
}
