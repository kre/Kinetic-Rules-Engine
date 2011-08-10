// composite events
ruleset 10 {
    rule test0 is active {
	select when pageview url #mid.html#
              between(pageview url #first.html#,
                      pageview url #last.html#)
	noop();
    }
}
