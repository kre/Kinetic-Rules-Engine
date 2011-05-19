ruleset eventEx {
    rule t10 is active {
      select when mail sent from "visa.com$"
	{
     		 noop();
	}
    }
}