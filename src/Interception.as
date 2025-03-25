// c 2025-03-21
// m 2025-03-25

// dictionary@ interceptions = dictionary();

funcdef bool ProcIntercept(CMwStack &in);
funcdef bool ProcInterceptEx(CMwStack &in, CMwNod@);

class Interception {
    bool             active = false;
    string           className;
    ProcInterceptEx@ func;
    string           procName;

    Interception(const string &in className, const string &in procName, ProcInterceptEx@ func) {
        this.className = className;
        this.procName = procName;
        @this.func = func;
    }

    ~Interception() {
        Stop();

        if (active)
            error(ToString() + ": still active after destruction");
    }

    void Start() final {
        if (active)
            return;

        try {
            Dev::InterceptProc(className, procName, func);
            active = true;
            trace(ToString() + ": start");
        } catch {
            warn(ToString() + ": start failed: " + getExceptionInfo());
        }
    }

    void Stop() final {
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

    void Toggle() final {
        if (active)
            Stop();
        else
            Start();
    }

    string ToString() final {
        return "Interception(" + className + "." + procName + ")";
    }
}

// void RegisterInterception(const string &in className, const string &in procName, ProcInterceptEx@ func) {
//     Interception@ i = Interception(className, procName, func);

//     const string id = i.ToString();
//     if (interceptions.Exists(id)) {
//         warn("already registered: " + id);
//         return;
//     }

//     interceptions.Set(id, @i);
// }

// void StartInterceptions() {
//     string[]@ ids = interceptions.GetKeys();
//     for (uint i = 0; i < ids.Length; i++)
//         cast<Interception@>(interceptions[ids[i]]).Start();
// }

void StopInterceptions() {
    // string[]@ ids = interceptions.GetKeys();
    // for (uint i = 0; i < ids.Length; i++)
    //     cast<Interception@>(interceptions[ids[i]]).Stop();

    string[]@ classNames = classes.GetKeys();
    for (uint i = 0; i < classNames.Length; i++)
        cast<GameClass@>(classes[classNames[i]]).Stop();
}

bool InterceptBasic(CMwStack &in stack, CMwNod@ nod) {
    const int available = stack.Count() - stack.Index() - 1;

    print(
        ORANGE + "InterceptBasic: available: " + available
        + ", nod: " + (nod is null ? "null" : Reflection::TypeOf(nod).Name)
    );

    return true;
}

bool InterceptDebug(CMwStack &in stack, CMwNod@ nod) {
    const int count = stack.Count();
    const int index = stack.Index();
    const int available = count - index - 1;

    print(
        ORANGE + "InterceptDebug: count: " + count + ", index: " + index
        + ", available: " + available + ", nod: " + (nod is null ? "null" : Reflection::TypeOf(nod).Name)
    );

    const string color = "\\$AFF";

    for (int i = 0; i < count - 1; i++) {
        try {
            bool current = stack.CurrentBool(i);
            print(color + "bool: " + tostring(current));
            continue;
        } catch { }

        try {
            MwFastBuffer<bool> current = stack.CurrentBufferBool(i);
            print(color + "buffer<bool>");
            continue;
        } catch { }

        try {
            MwFastBuffer<int> current = stack.CurrentBufferEnum(i);
            print(color + "buffer<enum>");
            continue;
        } catch { }

        try {
            MwFastBuffer<float> current = stack.CurrentBufferFloat(i);
            print(color + "buffer<float>");
            continue;
        } catch { }

        try {
            MwFastBuffer<MwId> current = stack.CurrentBufferId(i);
            print(color + "buffer<MwId>");
            continue;
        } catch { }

        try {
            MwFastBuffer<int> current = stack.CurrentBufferInt(i);
            print(color + "buffer<int>");
            continue;
        } catch { }

        try {
            MwFastBuffer<int3> current = stack.CurrentBufferInt3(i);
            print(color + "buffer<int3>");
            continue;
        } catch { }

        try {
            MwFastBuffer<iso4> current = stack.CurrentBufferIso4(i);
            print(color + "buffer<iso4>");
            continue;
        } catch { }

        try {
            MwFastBuffer<nat3> current = stack.CurrentBufferNat3(i);
            print(color + "buffer<nat3>");
            continue;
        } catch { }

        try {
            MwFastBuffer<CMwNod@> current = stack.CurrentBufferNod(i);
            if (current.Length == 0 || current[0] is null)
                print(color + "buffer<CMwNod@>");
            else
                print(color + "buffer<" + Reflection::TypeOf(current[0]).Name + "@>");
            continue;
        } catch { }

        try {
            MwFastBuffer<string> current = stack.CurrentBufferString(i);
            if (current.Length == 0)
                print(color + "buffer<string>");
            else {
                for (uint j = 0; j < current.Length; j++)
                    print(color + "buffer<string>[" + j + "]: " + current[j].Replace("\n", "\\n"));
            }
            continue;
        } catch { }

        try {
            MwFastBuffer<uint> current = stack.CurrentBufferUint(i);
            print(color + "buffer<uint>");
            continue;
        } catch { }

        try {
            MwFastBuffer<vec2> current = stack.CurrentBufferVec2(i);
            print(color + "buffer<vec2>");
            continue;
        } catch { }

        try {
            MwFastBuffer<vec3> current = stack.CurrentBufferVec3(i);
            print(color + "buffer<vec3>");
            continue;
        } catch { }

        try {
            MwFastBuffer<wstring> current = stack.CurrentBufferWString(i);
            if (current.Length == 0)
                print(color + "buffer<wstring>");
            else {
                for (uint j = 0; j < current.Length; j++)
                    print(color + "buffer<wstring>[" + j + "]: " + string(current[j]).Replace("\n", "\\n"));
            }
            continue;
        } catch { }

        try {
            int current = stack.CurrentEnum(i);
            print(color + "enum: "  + tostring(current));
            continue;
        } catch { }

        try {
            float current = stack.CurrentFloat(i);
            print(color + "float: " + tostring(current));
            continue;
        } catch { }

        try {
            MwId current = stack.CurrentId(i);
            print(color + "MwId: " + current.Value + ": " + current.GetName());
            continue;
        } catch { }

        try {
            int current = stack.CurrentInt(i);
            print(color + "int: " + tostring(current));
            continue;
        } catch { }

        // try {
        //     int2 current = stack.CurrentInt2(i);
        //     print(color + "int2: " + tostring(current));
        //     continue;
        // } catch { }

        try {
            int3 current = stack.CurrentInt3(i);
            print(color + "int3: " + tostring(current));
            continue;
        } catch { }

        try {
            iso4 current = stack.CurrentIso4(i);
            print(color + "iso4: " + tostring(current));
            continue;
        } catch { }

        try {
            nat3 current = stack.CurrentNat3(i);
            print(color + "nat3: " + tostring(current));
            continue;
        } catch { }

        try {
            CMwNod@ current = stack.CurrentNod(i);
            print(color + (
                current is null
                    ? "CMwNod"
                    : Reflection::TypeOf(current).Name
            ) + "@");
            continue;
        } catch { }

        try {
            string current = stack.CurrentString(i);
            print(color + "string: " + current.Replace("\n", "\\n"));
            continue;
        } catch { }

        try {
            uint current = stack.CurrentUint(i);
            print(color + "Uint: " + tostring(current));
            continue;
        } catch { }

        // try {
        //     vec2 current = stack.CurrentVec2(i);
        //     print(color + "vec2: " + tostring(current));
        //     continue;
        // } catch { }

        try {
            vec3 current = stack.CurrentVec3(i);
            print(color + "vec3: " + tostring(current));
            continue;
        } catch { }

        try {
            wstring current = stack.CurrentWString(i);
            print(color + "wstring: " + string(current).Replace("\n", "\\n"));
            continue;
        } catch { }

        warn("unknown type at " + i);
    }

    return true;
}
