ruleset cs_test_authz {
    meta {
        name "Test App Authorization"
        author "Phil Windley"
        description <<
Contains an authz directive; for testing purposes on KRE     
>>
        authz require user        logging off    
    }
    rule test_rule_1 is active {
        select using "/foo/bar.html" setting()

        notify("This is a test", "If you can see this, you're authorized");
    }

}
