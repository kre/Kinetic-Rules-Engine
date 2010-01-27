// css in global with other
ruleset 10 {

    global {
        css <<
body {
  background-color: #ffffff;
}

h1,h2,h3,hr {
  color:black; 
}

a:link    {color:black}
a:visited {color:black}
a:active  {color:mediumblue}
a:hover   {color:mediumblue}

>>;

       dataset foo_data <- "http://www.foo.com/data.json" cachable for 20 minutes;


    }

    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}     
      alert("hello");

    }
}
