}

/* If there is an config add or update known applications running in this browser */
if (typeof(KOBJ_config) != "undefined")
{
    KOBJ.add_config_and_run(KOBJ_config);
}
if (typeof(KOBJ_configs) != "undefined")
{
    KOBJ.add_app_configs(KOBJ_configs);
    KOBJ.runit();
    //    KOBJ.add_config_and_run(KOBJ_config);
}


