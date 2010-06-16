// pre with JS
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()

	pre {
	  foo = <|
$K("#foo").after(#{x});
|>;
        }

        replace("test","test");
    }
}
