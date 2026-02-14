funcdef bool ProcIntercept(CMwStack&in);
funcdef bool ProcInterceptEx(CMwStack&in, CMwNod@);

class Interception {
    bool             active = false;
    string           className;
    ProcInterceptEx@ func;
    string           procName;

    Interception(const string&in className, const string&in procName, ProcInterceptEx@ func) {
        this.className = className;
        this.procName = procName;
        @this.func = func;
    }

    ~Interception() {
        Stop();

        if (active) {
            error(ToString() + ": still active after destruction");
        }
    }

    void Start() final {
        if (active) {
            return;
        }

        try {
            Dev::InterceptProc(className, procName, func);
            active = true;
            trace(ToString() + ": start");
        } catch {
            warn(ToString() + ": start failed: " + getExceptionInfo());
        }
    }

    void Stop() final {
        if (!active) {
            return;
        }

        try {
            Dev::ResetInterceptProc(className, procName);
            active = false;
            trace(ToString() + ": stop");
        } catch {
            warn(ToString() + ": stop failed");
        }
    }

    void Toggle() final {
        if (active) {
            Stop();
        } else {
            Start();
        }
    }

    string ToString() final {
        return "Interception(" + className + "." + procName + ")";
    }
}

namespace Interception {
    void StopAll() {
        string[]@ classNames = classes.GetKeys();
        for (uint i = 0; i < classNames.Length; i++) {
            cast<GameClass>(classes[classNames[i]]).Stop();
        }
    }

    bool Basic(CMwStack&in stack, CMwNod@ nod) {
        const int count = stack.Count();
        const int index = stack.Index();
        const int available = count - index - 1;

        print(
            ORANGE + "Interception::Basic: count: " + count + ", index: " + index
            + ", available: " + available + ", nod: " + (nod is null ? "null" : Reflection::TypeOf(nod).Name)
        );

        return true;
    }

    bool Debug(CMwStack&in stack, CMwNod@ nod) {
        const int count = stack.Count();
        const int index = stack.Index();
        const int available = count - index - 1;

        print(
            ORANGE + "Interception::Debug: count: " + count + ", index: " + index
            + ", available: " + available + ", nod: " + (nod is null ? "null" : Reflection::TypeOf(nod).Name)
        );

        const string color = "\\$FAA";

        for (int i = 0; i < count - 1; i++) {
            try {
                print(color + "  bool: " + stack.CurrentBool(i));
                continue;
            } catch { }

            try {
                MwFastBuffer<bool> current = stack.CurrentBufferBool(i);
                print(color + "  buffer<bool>");
                continue;
            } catch { }

            try {
                MwFastBuffer<int> current = stack.CurrentBufferEnum(i);
                print(color + "  buffer<enum>");
                continue;
            } catch { }

            try {
                MwFastBuffer<float> current = stack.CurrentBufferFloat(i);
                print(color + "  buffer<float>");
                continue;
            } catch { }

            try {
                MwFastBuffer<MwId> current = stack.CurrentBufferId(i);
                print(color + "  buffer<MwId>");
                continue;
            } catch { }

            try {
                MwFastBuffer<int> current = stack.CurrentBufferInt(i);
                print(color + "  buffer<int>");
                continue;
            } catch { }

            try {
                MwFastBuffer<int3> current = stack.CurrentBufferInt3(i);
                print(color + "  buffer<int3>");
                continue;
            } catch { }

            try {
                MwFastBuffer<iso4> current = stack.CurrentBufferIso4(i);
                print(color + "  buffer<iso4>");
                continue;
            } catch { }

            try {
                MwFastBuffer<nat3> current = stack.CurrentBufferNat3(i);
                print(color + "  buffer<nat3>");
                continue;
            } catch { }

            try {
                MwFastBuffer<CMwNod@> current = stack.CurrentBufferNod(i);
                if (false
                    or current.Length == 0
                    or current[0] is null
                ) {
                    print(color + "  buffer<CMwNod@>");
                } else {
                    print(color + "  buffer<" + Reflection::TypeOf(current[0]).Name + "@>");
                }
                continue;
            } catch { }

            try {
                MwFastBuffer<string> current = stack.CurrentBufferString(i);
                print(color + "  buffer<string>");
                for (uint j = 0; j < current.Length; j++) {
                    print("    " + color + current[j].Replace("\n", "\\n"));
                }
                continue;
            } catch { }

            try {
                auto current = stack.CurrentBufferUint(i);
                print(color + "  buffer<uint>");
                continue;
            } catch { }

            try {
                MwFastBuffer<vec2> current = stack.CurrentBufferVec2(i);
                print(color + "  buffer<vec2>");
                continue;
            } catch { }

            try {
                MwFastBuffer<vec3> current = stack.CurrentBufferVec3(i);
                print(color + "  buffer<vec3>");
                continue;
            } catch { }

            try {
                MwFastBuffer<wstring> current = stack.CurrentBufferWString(i);
                print(color + "  buffer<wstring>");
                for (uint j = 0; j < current.Length; j++) {
                    print("    " + color + string(current[j]).Replace("\n", "\\n"));
                }
                continue;
            } catch { }

            try {
                print(color + "  enum: "  + stack.CurrentEnum(i));
                continue;
            } catch { }

            try {
                print(color + "  float: " + stack.CurrentFloat(i));
                continue;
            } catch { }

            try {
                MwId current = stack.CurrentId(i);
                print(color + "  MwId: " + current.Value + ": " + current.GetName());
                continue;
            } catch { }

            try {
                print(color + "  int: " + stack.CurrentInt(i));
                continue;
            } catch { }

            // try {
            //     print(color + "int2: " + tostring(stack.CurrentInt2(i)));
            //     continue;
            // } catch { }

            try {
                print(color + "  int3: " + tostring(stack.CurrentInt3(i)));
                continue;
            } catch { }

            try {
                iso4 current = stack.CurrentIso4(i);
                print(color + "  iso4");
                continue;
            } catch { }

            try {
                print(color + "  nat3: " + tostring(stack.CurrentNat3(i)));
                continue;
            } catch { }

            try {
                CMwNod@ current = stack.CurrentNod(i);
                print(color + (
                    current is null
                        ? "  CMwNod"
                        : Reflection::TypeOf(current).Name
                ) + "@");
                continue;
            } catch { }

            try {
                print(color + "  string: " + stack.CurrentString(i).Replace("\n", "\\n"));
                continue;
            } catch { }

            try {
                print(color + "  uint: " + stack.CurrentUint(i));
                continue;
            } catch { }

            // try {
            //     print(color + "vec2: " + tostring(stack.CurrentVec2(i)));
            //     continue;
            // } catch { }

            try {
                print(color + "  vec3: " + tostring(stack.CurrentVec3(i)));
                continue;
            } catch { }

            try {
                print(color + "  wstring: " + string(stack.CurrentWString(i)).Replace("\n", "\\n"));
                continue;
            } catch { }

            warn("  unknown/unsupported type");
        }

        return true;
    }
}
