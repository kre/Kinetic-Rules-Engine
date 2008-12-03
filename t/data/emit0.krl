// Using emit before action
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*).html" setting(pagename)
        pre {

	}     

        emit <<
pagename = pagename.replace(/-/, ' ');
>>
        replace("test",pagename);
    }
}
