// composite events
ruleset 10 {
    rule test0 is active {
        select when web  pageview "/2009/04/" setting(a) or
                    web  pageview "/2009/05/" setting(b) 
               before web pageview "/2009/06/"
          foreach [0,1,2] setting(x)
  	    noop();
    }
}
