// c 2025-03-22
// m 2025-03-26

Json::Value@ lookup     = Json::Object();
const string lookupFile = IO::FromDataFolder("OpenplanetNext.json");

void LoadLookup() {
    const uint64 start = Time::Now;
    trace("loading lookup.json...");

    if (!IO::FileExists(lookupFile)) {
        warn("not found: " + lookupFile);
        return;
    }

    Json::Value@ file = Json::FromFile(lookupFile);

    Json::Value@ ns = file.Get("ns");
    string[]@ namespaces = ns.GetKeys();
    for (uint i = 0; i < namespaces.Length; i++) {
        Json::Value@ thisNs = ns.Get(namespaces[i]);
        string[]@ classes = thisNs.GetKeys();
        for (uint j = 0; j < classes.Length; j++) {
            const string className = classes[j];
            Json::Value@ thisClass = thisNs.Get(className);
            lookup[className] = thisClass;
        }
    }

    trace("loaded lookup.json after " + (Time::Now - start) + "ms");
}

void SaveLookup() {
    const uint64 start = Time::Now;
    trace("saving lookup.json...");

    Json::ToFile(IO::FromStorageFolder("lookup.json"), lookup, true);

    trace("saved lookup.json after " + (Time::Now - start) + "ms");
}

void FilterLookupNoMethodsAsync() {
    const uint64 start = Time::Now;
    trace("filtering lookup...");

    Json::Value@ lookupWithMethods = Json::Object();

    string[]@ classNames = lookup.GetKeys();
    for (uint i = 0; i < classNames.Length; i++) {
        const string className = classNames[i];

        Json::Value@ object = lookup.Get(className);
        if (false
            || object is null
            || object.GetType() != Json::Type::Object
            || !object.HasKey("m")
        )
            continue;

        Json::Value@ members = object.Get("m");
        if (false
            || members is null
            || members.GetType() != Json::Type::Array
            || members.Length == 0
        )
            continue;

        Json::Value@ someClass = Json::Object();

        for (uint j = 0; j < members.Length; j++) {
            Json::Value@ member = members[j];

            // if (member.HasKey("a") && member.HasKey("r")) {
            if (member.HasKey("t")) {
                Json::Value@ type = member["t"];

                if (type.GetType() == Json::Type::Number
                    // && (int(type) == 0 || int(type) == 1)
                ) {
                    Json::Value@ method = Json::Object();

                    method["args"] = Json::Array();
                    if (member["a"].GetType() == Json::Type::String) {
                        string[]@ args = string(member["a"]).Split(",");
                        for (uint k = 0; k < args.Length; k++) {
                            const string arg = args[k].Trim();
                            string[]@ parts = arg.Split(" ");
                            if (parts.Length == 2) {
                                Json::Value@ argument = Json::Object();
                                argument["index"] = k;
                                argument["type"] = Json::Value(parts[0]);
                                argument["name"] = Json::Value(parts[1]);
                                method["args"].Add(argument);
                            }
                        }
                    }
                    // method["args"] = member["a"];

                    // method["name"]   = member["n"];
                    method["return"] = member["r"];

                    // someClass.Add(method);
                    someClass[string(member["n"])] = method;
                }
            }
        }

        if (someClass.Length > 0)
            lookupWithMethods[className] = someClass;
    }

    Json::ToFile(
        IO::FromStorageFolder("lookupWithMethods.json"),
        lookupWithMethods,
        true
    );

    trace("filtered + saved lookup after " + (Time::Now - start) + "ms");
    yield();
    const uint64 start2 = Time::Now;

    string[]@ classNamesFiltered = lookupWithMethods.GetKeys();
    for (uint i = 0; i < classNamesFiltered.Length; i++) {
        AddClass(GameClass(
            lookupWithMethods[classNamesFiltered[i]],
            classNamesFiltered[i]
        ));

        yield();
    }

    _classes.Sort(SortGameClass);

    trace("built classes after " + (Time::Now - start2) + "ms");
}
