// directives and raw actions
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
	}     

        raw_action() with
	  js = <|
function(uniq, cb, config) {
  $K("#foo").after(#{b});
  cb();
}
|>;

    }
}

