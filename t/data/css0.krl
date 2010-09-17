// css in global
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

    }

    rule test0 is active {
        select using "/test/" setting()
        pre {
      	    tc = weather:tomorrow_cond_code();
	    city = geoip:city();
	}
      float("absolute", "top: 10px", "right: 10px", "url")
        with delay = 0 ;

    }
}
