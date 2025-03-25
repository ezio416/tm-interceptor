// c 2025-03-21
// m 2025-03-25

dictionary@ classes       = dictionary();
dictionary@ interceptions = dictionary();

funcdef bool InterceptFunc(CMwStack &in stack, CMwNod@ nod);

class MethodArgument {
    int          index = -1;
    string       name;
    ClassMethod@ parent;
    string       type;

    MethodArgument(Json::Value@ arg, ClassMethod@ parent) {
        index = int(arg["index"]);
        name = string(arg["name"]);
        type = string(arg["type"]);

        @this.parent = parent;
    }
}

class ClassMethod {
    MethodArgument@[] args;
    Interception@     interceptionBasic;
    Interception@     interceptionDebug;
    string            name;
    GameClass@        parent;
    string            returnType;

    ClassMethod(Json::Value@ method, const string &in name, GameClass@ parent) {
        Json::Value@ _args = method["args"];
        for (uint i = 0; i < _args.Length; i++)
            args.InsertLast(MethodArgument(_args[i], this));
        if (args.Length > 1)
            args.Sort(function(a, b) { return a.index < b.index; });

        if (method.HasKey("return")) {
            Json::Value@ ret = method["return"];
            if (ret.GetType() == Json::Type::String)
                returnType = string(ret);
            else
                returnType = "null";
        }

        this.name = name;
        @this.parent = parent;

        @interceptionBasic = Interception(parent.name, name, InterceptBasic);
        @interceptionDebug = Interception(parent.name, name, InterceptDebug);
    }

    void GenerateInterceptCode() {
        string code = '\nnamespace Interceptor::Class_' + parent.name + ' {\n';
        code += '    bool Method_' + name + '(CMwStack &in stack, CMwNod@ nod) {\n';

        code += '        print("========== ' + parent.name + '.' + name + ' ==========");\n';
        code += '        print("nod: " + (nod !is null ? Reflection::TypeOf(nod).Name : "unknown"));\n';

        string[] seenArgNames;

        for (uint i = 0; i < args.Length; i++) {
            MethodArgument@ arg = args[i];
            const int stackIndex = args.Length - 1 - arg.index;

            if (seenArgNames.Find(arg.name) != -1) {
                code += '\n        warn("' + arg.type + ' ' + arg.name + ': duplicate name");\n';
                continue;
            }
            seenArgNames.InsertLast(arg.name);

            if (arg.type.EndsWith("@")) {  // nod
                code += '\n        const ' + arg.type + ' ' + arg.name + ' = cast<' + arg.type + '>(stack.CurrentNod(' + stackIndex + '));\n        print("' + arg.type + ' ' + arg.name + ': " + (' + arg.name + ' !is null ? "valid" : "null"));\n';

            } else if (arg.type.Contains("::E")) {  // enum
                code += '\n        const ' + arg.type + ' ' + arg.name + ' = ' + arg.type + '(stack.CurrentEnum(' + stackIndex + '));\n        print("' + arg.type + ' ' + arg.name + ': " + tostring(' + arg.name + '));\n';

            } else if (arg.type.Contains("MwFastBuffer<")) {
                if (arg.type.Contains("<wstring>")) {
                    code += '\n        const MwFastBuffer<wstring> ' + arg.name + ' = stack.CurrentBufferWString(' + stackIndex + ');\n        print("buffer<wstring> ' + arg.name + ': length " + ' + arg.name + '.Length);\n';

                } else {
                    code += '\n        warn("' + arg.type + ' ' + arg.name + ': unsupported type");\n';
                }

            } else if (arg.type == "bool") {
                code += '\n        const bool ' + arg.name + ' = stack.CurrentBool(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + ');\n';

            } else if (arg.type == "float") {
                code += '\n        const float ' + arg.name + ' = stack.CurrentFloat(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + ');\n';

            } else if (arg.type == "int") {
                code += '\n        const int ' + arg.name + ' = stack.CurrentInt(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + ');\n';

            } else if (arg.type == "int2") {  // .CurrentInt2() doesn't exist yet
                code += '\n        warn("int2 ' + arg.name + ': unsupported type");\n';

            } else if (arg.type == "int3") {
                code += '\n        const int3 ' + arg.name + ' = stack.CurrentInt3(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + tostring(' + arg.name + '));\n';

            } else if (arg.type == "iso4") {
                code += '\n        const iso4 ' + arg.name + ' = stack.CurrentIso4(' + stackIndex + ');\n        warn("' + arg.type + ' ' + arg.name + ': unsupported type");\n';

            } else if (arg.type == "MwId") {
                code += '\n        const MwId ' + arg.name + ' = stack.CurrentId(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + '.Value + " (" + ' + arg.name + '.GetName() + ")");\n';

            } else if (arg.type == "nat3") {
                code += '\n        const nat3 ' + arg.name + ' = stack.CurrentNat3(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + tostring(' + arg.name + '));\n';

            } else if (arg.type == "string") {
                code += '\n        const string ' + arg.name + ' = stack.CurrentString(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + ');\n';

            } else if (arg.type == "uint") {
                code += '\n        const uint ' + arg.name + ' = stack.CurrentUint(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + ');\n';

            } else if (arg.type == "vec2") {  // .CurrentVec2() doesn't exist yet
                code += '\n        warn("vec2 ' + arg.name + ': unsupported type");\n';

            } else if (arg.type == "vec3") {
                code += '\n        const vec3 ' + arg.name + ' = stack.CurrentVec3(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + tostring(' + arg.name + '));\n';

            } else if (arg.type == "wstring") {
                code += '\n        const wstring ' + arg.name + ' = stack.CurrentWString(' + stackIndex + ');\n        print("' + arg.type + ' ' + arg.name + ': " + ' + arg.name + ');\n';

            } else {
                code += '\n        warn("' + arg.type + ' ' + arg.name + ': unsupported type");\n';
            }
        }

        code += "\n        return true;\n    }\n}\n";

        IO::File file(generated, IO::FileMode::Append);
        file.Write(code);
        file.Close();
    }
}

class GameClass {
    ClassMethod@[] methods;
    string         name;

    GameClass(Json::Value@ classVal, const string &in name) {
        this.name = name;  // needs to be set before block below

        string[]@ methodNames = classVal.GetKeys();
        for (uint i = 0; i < methodNames.Length; i++)
            methods.InsertLast(ClassMethod(
                classVal[methodNames[i]],
                methodNames[i],
                this
            ));

        methods.Sort(function(a, b) { return a.name < b.name; });
    }

    void StopInterceptions() {
        for (uint i = 0; i < methods.Length; i++) {
            methods[i].interceptionBasic.Stop();
            methods[i].interceptionDebug.Stop();
        }
    }
}

class Interception {
    bool           active = false;
    string         className;
    InterceptFunc@ interceptFunc;
    string         procName;

    Interception(const string &in className, const string &in procName, InterceptFunc@ interceptFunc) {
        this.className = className;
        this.procName = procName;
        @this.interceptFunc = interceptFunc;
    }

    ~Interception() {
        Stop();

        if (active)
            error(ToString() + ": still active after destruction");
    }

    void Start() {
        if (active)
            return;

        try {
            Dev::InterceptProc(className, procName, interceptFunc);
            active = true;
            trace(ToString() + ": start");
        } catch {
            warn(ToString() + ": start failed: " + getExceptionInfo());
        }
    }

    void Stop() {
        if (!active)
            return;

        try {
            Dev::ResetInterceptProc(className, procName);
            active = false;
            trace(ToString() + ": stop");
        } catch {
            warn(ToString() + ": stop failed");
        }
    }

    void Toggle() {
        if (active)
            Stop();
        else
            Start();
    }

    string ToString() {
        return "Interception(" + className + "." + procName + ")";
    }
}

void RegisterInterception(const string &in className, const string &in procName, InterceptFunc@ interceptFunc) {
    Interception@ i = Interception(className, procName, interceptFunc);

    const string id = i.ToString();
    if (interceptions.Exists(id)) {
        warn("already registered: " + id);
        return;
    }

    interceptions.Set(id, @i);
}

void StartInterceptions() {
    string[]@ ids = interceptions.GetKeys();
    for (uint i = 0; i < ids.Length; i++)
        cast<Interception@>(interceptions[ids[i]]).Start();
}

void StopInterceptions() {
    string[]@ ids = interceptions.GetKeys();
    for (uint i = 0; i < ids.Length; i++)
        cast<Interception@>(interceptions[ids[i]]).Stop();
}
