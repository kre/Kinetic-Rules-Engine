ruleset foo {
    rule bar {
	select when web checkoutcomplete setting()
	pre {
		amount = page:env("amount");
	} 
	notify("Payment Complete","You paid");
	}
}