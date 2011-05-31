ruleset eventExLegacy {
    rule t10 is active {
      select when explicit foo
	{
     		 noop();
	}
    }
}