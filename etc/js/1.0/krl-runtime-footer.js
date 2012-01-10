// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later


    })($KOBJ);
})($KOBJ);

}


$KOBJ(document).ready(function() {
    /* If there is an config add or update known applications running in this browser */
    if (typeof(KOBJ_config) != "undefined") {
        KOBJ.add_config_and_run(KOBJ_config);
    }
    if (typeof(KOBJ_configs) != "undefined") {
		  KOBJ.add_configs_and_run(KOBJ_configs);
        //KOBJ.add_app_configs(KOBJ_configs);
        //KOBJ.runit();
        //    KOBJ.add_config_and_run(KOBJ_config);
    }


});
