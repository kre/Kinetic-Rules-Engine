// composite events
ruleset 10 {
  rule is_expression1 is active {
    select when pageview where
    		url.match(re/search/);
    		time:strftime(time:now(),"%H",{'tz':'America/New_York'}) > 16;
    		(7>5);
    		url.replace(re/search/,"SuperSearch");
    		time:new();
    		(foo_what_where_did_that_var_come_from == 1) setting (foo_what_where_did_that_var_come_from,thang1, thang2, thang3, thistime)
	{
		noop();
	}
    }
}
