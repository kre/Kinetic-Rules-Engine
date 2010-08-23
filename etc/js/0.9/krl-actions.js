

KOBJ.raise_event_action = function (uniq, event_name, config) {
    var app = KOBJ.get_application(config.rid);
    app.raise_event(event_name,config["parameters"],config["app_id"]);
};

