// c 2025-03-25
// m 2025-03-26

class ClassMethod {
    MethodArgument@[] args;
    Interception@     interception;
    string            name;
    GameClass@        parent;
    string            returnType;

    ClassMethod(GameClass@ parent, const string &in name, Json::Value@ method) {
        @this.parent = parent;
        this.name = name;

        Json::Value@ _args = method["args"];
        for (uint i = 0; i < _args.Length; i++)
            args.InsertLast(MethodArgument(_args[i], this));

        if (method.HasKey("return")) {
            Json::Value@ ret = method["return"];

            if (ret.GetType() == Json::Type::String)
                returnType = string(ret);
            else
                returnType = "null";
        }
    }

    bool get_active() final {
        return interception !is null && interception.active;
    }

    string[]@ GenerateLines() final {
        uint     count = 0;
        string[] lines;

        lines.InsertLast('');
        lines.InsertLast('namespace Interceptor::Class_' + parent.name + ' {');

        lines.InsertLast(Indent(
            'class Method_' + name + ' : ClassMethod {',
            ++count
        ));
        lines.InsertLast(Indent(
            'Method_' + name + '(GameClass@ parent, const string &in name, Json::Value@ method) {',
            ++count
        ));
        lines.InsertLast(Indent(
            'super(parent, name, method);',
            ++count
        ));
        lines.InsertLast(Indent('}', --count));

        lines.InsertLast('');
        lines.InsertLast(Indent(
            'void RegisterInterception() override {',
            count
        ));
        lines.InsertLast(Indent(
            'RegisterInterception(Intercept_' + name + ');',
            ++count
        ));
        lines.InsertLast(Indent('}', --count));
        lines.InsertLast(Indent('}', --count));

        lines.InsertLast('');
        lines.InsertLast(Indent(
            'bool Intercept_' + name + '(CMwStack &in stack, CMwNod@ nod) {',
            count
        ));
        lines.InsertLast(Indent(
            'print("========== ' + parent.name + '.' + name + ' ==========");',
            ++count
        ));
        lines.InsertLast(Indent(
            'print("nod: " + (nod !is null ? Reflection::TypeOf(nod).Name : "unknown"));',
            count
        ));

        string[] seenArgNames;

        for (uint i = 0; i < args.Length; i++) {
            MethodArgument@ arg = args[i];
            arg.stackIndex = args.Length - 1 - arg.index;

            if (seenArgNames.Find(arg.name) != -1) {
                lines.InsertLast('');
                lines.InsertLast(Indent(
                    'warn("' + arg.type + ' ' + arg.name + ': duplicate argument name");',
                    count
                ));
                continue;
            }
            seenArgNames.InsertLast(arg.name);

            lines.InsertLast('');

            string[]@ argLines = arg.GenerateLines();
            for (uint j = 0; j < argLines.Length; j++) {
                lines.InsertLast(Indent(argLines[j], count));
            }
        }

        lines.InsertLast('');
        lines.InsertLast(Indent('return true;', count));
        lines.InsertLast(Indent('}', --count));
        lines.InsertLast('}');

        return lines;
    }

    private string Indent(const string &in text, uint count) {
        string indent;
        for (uint i = 0; i < count; i++)
            indent += "\t";

        return indent + text;
    }

    void RegisterInterception() {
        RegisterInterception(Interception::Debug);
    }

    protected void RegisterInterception(ProcInterceptEx@ func) final {
        @interception = Interception(parent.name, name, func);
    }

    void Start() final {
        if (interception !is null)
            interception.Start();
    }

    void Stop() final {
        if (interception !is null)
            interception.Stop();
    }
}
