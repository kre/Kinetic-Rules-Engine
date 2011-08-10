ruleset 1 {
    rule test0 is active {
	select when inbound_call from #(.*)# setting (num)
	after twilio sms_received where from.match("/#{num}/".as("regexp"))
	within 1 hour
                noop();
    }
}

