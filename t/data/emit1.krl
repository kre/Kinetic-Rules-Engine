// Using emit as action
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*).html" setting(pagename)
        pre {

	}     

        if (x == 5)
        then 
          emit <<
pagename = pagename.replace(/-/, ' ');
 >>;
   }
}
