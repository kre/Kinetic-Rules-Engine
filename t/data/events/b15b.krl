ruleset 1 {
    rule test0 is active {
        select when inbound_call from #foo#
                before(pageview url #custserv_page.html# and
                pageview url #homepage.html#)
                within 3 hours
        {
                noop();
        }
    }
}

