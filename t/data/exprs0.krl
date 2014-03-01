// test a bunch of expressions
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {

	  x = 5 ;
	  x = (6-5);
	  x = 6 - 5;
          x = y - 1;
          x = -5;
          x = -(4+5);
          x = 0.9;
          x = -0.9;
          x = -.9;
	  x = "test";
          x = "1234567890";
	  x = true;
	  x = false;
//	  x = re/f|g+/i;
	  x = foo(5);
	  x = foo(5,"hello");
	  x = (4 + 5);
          x = ((4 + 5) * 6);
          x = (4 + (5 * 6));
          x = (x || y);
          x = (xyz && zyx);
          x = ((pdq || xyz) && zyx);
          x = (pdq || (xyy && zyx));
	  x = (x == 0);
	  x = (x != 0);
	  x = (x >= 0);
	  x = (x <= 0);
	  x = (x eq "hello");
	  x = (x neq "hello");
	  x = ((x < 5) || (y > 3));
          x = foo:bar(x,y,z);
          x = [3,4,5];
          x = {"x": 3, "y" : "hello"};
	  x = {"x": [3,4,5],
 	       "y": {"x": "hello",
	             "y": "world"}};
	  x = [{"x":5}];
	  x = [{"x":-5}];
          x = ent:vv;
	  x = app:vv;
	  x = current ent:vv;
	  x = history ex ent:vv;
	  x = history (3+4) ent:vv;
	  x = history ((3+4)*6) ent:vv;
	  x = {"x": f:x(5),
	       "f": function(x){x}};

	  x = ((weather(y) || twitter:authorized()) && false);
	  x = ent:bar within 3 days;
//	  x = ent:bar like re/f|goo+/ within 3 days;
	  x = seen "hello" in ent:foo;
	  x = seen "hello" in ent:foo within 4 weeks;
	  x = seen "hello" before "world" in ent:bar;
	  x = seen "hello" after "world" in ent:bar;
	  x = (not true);
	  x = ((not true) == false);
	  x = (not (true == false));
	  x = (((not x) || (not y)) == (not (x && y)));
	  x = a[5];
	  x = vari[(x+6)];
	  x = myHash{"d"};
	  x = myHash{[a, 1.1]};
	}
	alert("Hello");

    }
}
