ruleset eventEx {
    rule t10 is active {
      select when web pageview url ".*"
	{
     		 noop();
	}
    }
}