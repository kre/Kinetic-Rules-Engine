// composable action user
ruleset foobar {
  meta {
    key floppy "world"
    use module caction1 alias foo with c = "FOO"
  }
  global {
  }
  rule test0 is active {
    select using "/test/" setting()
      pre {
      	tc = weather:tomorrow_cond_code();
	    city = geoip:city();

	  }     
    foo:x("looby loo");
  }
}
