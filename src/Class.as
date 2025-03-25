// c 2025-03-25
// m 2025-03-25

dictionary@ classes = dictionary();

class GameClass {
    ClassMethod@[] methods;
    string         name;

    GameClass(Json::Value@ classVal, const string &in name) {
        this.name = name;  // needs to be set before block below

        string[]@ methodNames = classVal.GetKeys();
        for (uint i = 0; i < methodNames.Length; i++) {
#if GENERATED
            ClassMethod@ method = Interceptor::CreateMethod(
#else
            ClassMethod@ method = ClassMethod(
#endif
                this,
                methodNames[i],
                classVal[methodNames[i]]
            );

            method.RegisterInterception();

            methods.InsertLast(method);
        }
    }

    void Start() final {
        for (uint i = 0; i < methods.Length; i++)
            methods[i].Start();
    }

    void Stop() final {
        for (uint i = 0; i < methods.Length; i++)
            methods[i].Stop();
    }
}

void AddClass(GameClass@ Class) {
    if (Class is null)
        return;

    if (classes.Exists(Class.name)) {
        warn("duplicate class: " + Class.name);
        return;
    }

    classes.Set(Class.name, @Class);
}
