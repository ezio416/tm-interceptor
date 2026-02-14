dictionary@ classes = dictionary();
GameClass@[] _classes;

class GameClass {
    ClassMethod@[] methods;
    string         name;

    GameClass(Json::Value@ classVal, const string&in name) {
        this.name = name;  // needs to be set before block below

        string[]@ methodNames = classVal.GetKeys();
        for (uint i = 0; i < methodNames.Length; i++) {
            ClassMethod@ method = Interceptor::CreateMethod(
                this,
                methodNames[i],
                classVal[methodNames[i]]
            );

            method.RegisterInterception();

            methods.InsertLast(method);
        }

        methods.Sort(SortClassMethod);
    }

    void Start() final {
        for (uint i = 0; i < methods.Length; i++) {
            methods[i].Start();
        }
    }

    void Stop() final {
        for (uint i = 0; i < methods.Length; i++) {
            methods[i].Stop();
        }
    }
}

void AddClass(GameClass@ Class) {
    if (Class is null) {
        return;
    }

    if (classes.Exists(Class.name)) {
        warn("duplicate class: " + Class.name);
        return;
    }

    classes.Set(Class.name, @Class);
    _classes.InsertLast(@Class);
}
