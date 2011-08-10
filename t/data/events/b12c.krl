// composite events
ruleset 10 {
    rule test0 is active {
	select when inbound_call
              from #(\d{3})\d+# setting(area_code)
    		between(pageview url #custserv_page.html#,
            		pageview url #homepage.html#)
	noop();
    }
}
