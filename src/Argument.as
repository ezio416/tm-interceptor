class MethodArgument {
    int          index      = -1;
    string       name;
    ClassMethod@ parent;
    int          stackIndex = -1;
    string       type;

    MethodArgument(Json::Value@ arg, ClassMethod@ parent) {
        index = int(arg["index"]);
        name = string(arg["name"]);
        type = string(arg["type"]);

        @this.parent = parent;
    }

    string[]@ GenerateLines() final {
        if (stackIndex == -1)
            return {};

        if (type.EndsWith("@")) {  // nod
            return {
                'const ' + type + ' const ' + name + ' = cast<' + type + '>(stack.CurrentNod(' + stackIndex + '));',
                'print("' + type + ' ' + name + ': " + (' + name + ' !is null ? "valid" : "null"));'
            };

        } else if (type.Contains("::E")) {  // enum
            return {
                'const ' + type + ' ' + name + ' = ' + type + '(stack.CurrentEnum(' + stackIndex + '));',
                'print("' + type + ' ' + name + ': " + tostring(' + name + '));'
            };

        } else if (type.Contains("MwFastBuffer<")) {
            if (type.Contains("<wstring>")) {
                return {
                    'const MwFastBuffer<wstring> ' + name + ' = stack.CurrentBufferWString(' + stackIndex + ');',
                    'print("buffer<wstring> ' + name + ': length " + ' + name + '.Length);'
                };

            } else {
                return {
                    'warn("' + type + ' ' + name + ': unsupported type");'
                };
            }

        } else if (type == "bool") {
            return {
                'const bool ' + name + ' = stack.CurrentBool(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + ' + name + ');'
            };

        } else if (type == "float") {
            return {
                'const float ' + name + ' = stack.CurrentFloat(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + ' + name + ');'
            };

        } else if (type == "int") {
            return {
                'const int ' + name + ' = stack.CurrentInt(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + ' + name + ');'
            };

        } else if (type == "int2") {  // .CurrentInt2() doesn't exist yet
            return {
                'warn("int2 ' + name + ': unsupported type");'
            };

        } else if (type == "int3") {
            return {
                'const int3 ' + name + ' = stack.CurrentInt3(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + tostring(' + name + '));'
            };

        } else if (type == "iso4") {
            return {
                'const iso4 ' + name + ' = stack.CurrentIso4(' + stackIndex + ');',
                'warn("' + type + ' ' + name + ': unsupported type");'
            };

        } else if (type == "MwId") {
            return {
                'const MwId ' + name + ' = stack.CurrentId(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + ' + name + '.Value + " (" + ' + name + '.GetName() + ")");'
            };

        } else if (type == "nat3") {
            return {
                'const nat3 ' + name + ' = stack.CurrentNat3(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + tostring(' + name + '));'
            };

        } else if (type == "string") {
            return {
                'const string ' + name + ' = stack.CurrentString(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + ' + name + '.Replace("\\n", "\\\\n"));'
            };

        } else if (type == "uint") {
            return {
                'const uint ' + name + ' = stack.CurrentUint(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + ' + name + ');'
            };

        } else if (type == "vec2") {  // .CurrentVec2() doesn't exist yet
            return {
                'warn("vec2 ' + name + ': unsupported type");'
            };

        } else if (type == "vec3") {
            return {
                'const vec3 ' + name + ' = stack.CurrentVec3(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + tostring(' + name + '));'
            };

        } else if (type == "wstring") {
            return {
                'const wstring ' + name + ' = stack.CurrentWString(' + stackIndex + ');',
                'print("' + type + ' ' + name + ': " + string(' + name + ').Replace("\\n", "\\\\n"));'
            };

        } else {
            return {
                'warn("' + type + ' ' + name + ': unsupported type");'
            };
        }
    }
}
