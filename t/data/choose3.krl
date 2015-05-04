// actionblocks: choose
ruleset 10 {
  rule test_choose is inactive {
    select using "/identity-policy/" setting ()


    if daytime() then 
    choose my_var {
        first_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_1.inc")
	   with tags = ["gift certificate", "yellow"] and
	        delay = 30;

	second_rule_name =>
           replace("kobj_test", "/kynetx/newsletter_invite_2.inc")
	   with tags = ["discount", "blue"] and
	        draggable = true;

    }

  }

}
