// Using emit as action in a block
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*).html" setting(pagename)
        pre {

	}     


    if daytime() 
    then every {

       fizz => alert("Hey!");

       fuzz => emit <<
pagename = pagename.replace(/-/, ' ');
 >> ;
      
       alert("world!");


    }
  }
}

