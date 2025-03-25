// c 2025-03-20
// m 2025-03-24

// bool          capturing   = true;
const string  generated   = IO::FromStorageFolder("Generated.as");
const string  pluginColor = "\\$FFF";
const string  pluginIcon  = Icons::Code;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const float   scale       = UI::GetScale();

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

// void OnDestroyed() { Interceptor::Http::Reset(); }
// void OnDisabled()  { Interceptor::Http::Reset(); }

void OnDestroyed() { StopInterceptions(); }
void OnDisabled()  { StopInterceptions(); }

void Main() {
    LoadLookup();
    SaveLookup();

    if (IO::FileExists(generated))
        IO::Delete(generated);
    startnew(FilterLookupNoMethodsAsync);

    // Interceptor::Http::Init();

    // Interception@[] interceptions;
    // RegisterInterception("CNetScriptHttpManager", "CreateGet3", InterceptDebug);
    // RegisterInterception("CNetScriptHttpManager", "Destroy", InterceptDebug);
    // StartInterceptions();

    while (true)
        yield();
}

bool InterceptBasic(CMwStack &in stack, CMwNod@ nod) {
    const int available = stack.Count() - stack.Index() - 1;
    print(
        ORANGE + "InterceptBasic: available, nod: " + available
        + ", " + (nod is null ? "null" : Reflection::TypeOf(nod).Name)
    );
    return true;
}

bool InterceptDebug(CMwStack &in stack, CMwNod@ nod) {
    const int count = stack.Count();
    const int index = stack.Index();
    const int available = count - index - 1;

    print(
        ORANGE + "InterceptDebug: count, index, available, nod: " + count + ", " + index
        + ", " + available + ", " + (nod is null ? "null" : Reflection::TypeOf(nod).Name)
    );

    const string color = "\\$AFF";

    for (int i = 0; i < count - 1; i++) {
        print(CYAN + "=============== InterceptDebug: stack element [ " + i + " ] ===============");

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

        print("\\$F00unknown type");
    }

    return true;
}

void Render() {
    if (false
        || !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(pluginTitle, S_Enabled, UI::WindowFlags::None))
        RenderWindow();
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void RenderWindow() {
    string[]@ classNames = classes.GetKeys();
    for (uint i = 0; i < classNames.Length; i++) {
        GameClass@ Class = cast<GameClass@>(classes[classNames[i]]);

        if (UI::CollapsingHeader(Class.name + " (" + Class.methods.Length + ")")) {
            UI::Indent(50.0f);

            for (uint j = 0; j < Class.methods.Length; j++) {
                ClassMethod@ method = Class.methods[j];
                UI::Text(method.name);

                UI::SameLine();
                if (UI::Checkbox("basic##" + method.name, method.interceptionBasic.active))
                    method.interceptionBasic.Start();
                else
                    method.interceptionBasic.Stop();

                UI::SameLine();
                if (UI::Checkbox("debug##" + method.name, method.interceptionDebug.active))
                    method.interceptionDebug.Start();
                else
                    method.interceptionDebug.Stop();
            }

            UI::Indent(-50.0f);
        }
    }

    // if (UI::BeginTable("##table-classes", 8, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
    //     UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
    //     UI::TableSetupScrollFreeze(0, 1);
    //     UI::TableSetupColumn("id",     UI::TableColumnFlags::WidthFixed, scale * 40.0f);
    //     UI::TableSetupColumn("time",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
    //     UI::TableSetupColumn("method", UI::TableColumnFlags::WidthFixed, scale * 50.0f);
    //     UI::TableSetupColumn("code",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
    //     UI::TableSetupColumn("url");
    //     UI::TableSetupColumn("head",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
    //     UI::TableSetupColumn("result", UI::TableColumnFlags::WidthFixed, scale * 40.0f);
    //     UI::TableSetupColumn("json",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
    //     UI::TableHeadersRow();

    //     UI::ListClipper clipper(requests.Length);
    //     while (clipper.Step()) {
    //         for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
    //             HttpRequest@ req = requests[requests.Length - 1 - i];

    //             UI::TableNextRow();

    //             UI::TableNextColumn();
    //             UI::AlignTextToFramePadding();
    //             UI::Text(tostring(req.id.Value));

    //             UI::TableNextColumn();
    //             UI::Text(tostring(Time::Stamp - req.sentAt) + "s");
    //             if (UI::BeginItemTooltip()) {
    //                 UI::Text(Time::FormatString("%T", req.sentAt));
    //                 UI::EndTooltip();
    //             }

    //             UI::TableNextColumn();
    //             UI::Text(tostring(req.method));

    //             UI::TableNextColumn();
    //             UI::Text(req.statusCode != -1 ? tostring(req.statusCode) : "");

    //             UI::TableNextColumn();
    //             if (UI::Selectable(req.url, false))
    //                 IO::SetClipboard(req.url);
    //             if (UI::BeginItemTooltip()) {
    //                 UI::Text("copy");
    //                 UI::EndTooltip();
    //             }

    //             UI::TableNextColumn();
    //             UI::BeginDisabled(req.headers.Length == 0);
    //             if (UI::Button(Icons::Clipboard + "##headers" + i))
    //                 IO::SetClipboard(req.headers);
    //             if (UI::BeginItemTooltip()) {
    //                 UI::Text(req.headers);
    //                 UI::EndTooltip();
    //             }
    //             UI::EndDisabled();

    //             UI::TableNextColumn();
    //             UI::BeginDisabled(req.result.Length == 0);
    //             if (UI::Button(Icons::Clipboard + "##result" + i))
    //                 IO::SetClipboard(req.result);
    //             if (UI::BeginItemTooltip()) {
    //                 UI::Text(req.result);
    //                 UI::EndTooltip();
    //             }
    //             UI::EndDisabled();

    //             UI::TableNextColumn();
    //             UI::BeginDisabled(req.parsed is null || req.parsed.GetType() == Json::Type::Null);
    //             if (UI::Button(Icons::Clipboard + "##parsed" + i))
    //                 IO::SetClipboard(Json::Write(req.parsed, true));
    //             if (UI::BeginItemTooltip()) {
    //                 UI::Text(Json::Write(req.parsed, true));
    //                 UI::EndTooltip();
    //             }
    //             UI::EndDisabled();
    //         }
    //     }

    //     UI::PopStyleColor();
    //     UI::EndTable();
    // }

//     capturing = UI::Checkbox("capturing", capturing);
//     UI::SameLine();
//     if (UI::Button("clear (" + requests.Length + ")"))
//         requests = { };

//     if (UI::BeginTable("##table-reqs", 8, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
//         UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));
//         UI::TableSetupScrollFreeze(0, 1);
//         UI::TableSetupColumn("id",     UI::TableColumnFlags::WidthFixed, scale * 40.0f);
//         UI::TableSetupColumn("time",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
//         UI::TableSetupColumn("method", UI::TableColumnFlags::WidthFixed, scale * 50.0f);
//         UI::TableSetupColumn("code",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
//         UI::TableSetupColumn("url");
//         UI::TableSetupColumn("head",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
//         UI::TableSetupColumn("result", UI::TableColumnFlags::WidthFixed, scale * 40.0f);
//         UI::TableSetupColumn("json",   UI::TableColumnFlags::WidthFixed, scale * 40.0f);
//         UI::TableHeadersRow();

//         UI::ListClipper clipper(requests.Length);
//         while (clipper.Step()) {
//             for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
//                 HttpRequest@ req = requests[requests.Length - 1 - i];

//                 UI::TableNextRow();

//                 UI::TableNextColumn();
//                 UI::AlignTextToFramePadding();
//                 UI::Text(tostring(req.id.Value));

//                 UI::TableNextColumn();
//                 UI::Text(tostring(Time::Stamp - req.sentAt) + "s");
//                 if (UI::BeginItemTooltip()) {
//                     UI::Text(Time::FormatString("%T", req.sentAt));
//                     UI::EndTooltip();
//                 }

//                 UI::TableNextColumn();
//                 UI::Text(tostring(req.method));

//                 UI::TableNextColumn();
//                 UI::Text(req.statusCode != -1 ? tostring(req.statusCode) : "");

//                 UI::TableNextColumn();
//                 if (UI::Selectable(req.url, false))
//                     IO::SetClipboard(req.url);
//                 if (UI::BeginItemTooltip()) {
//                     UI::Text("copy");
//                     UI::EndTooltip();
//                 }

//                 UI::TableNextColumn();
//                 UI::BeginDisabled(req.headers.Length == 0);
//                 if (UI::Button(Icons::Clipboard + "##headers" + i))
//                     IO::SetClipboard(req.headers);
//                 if (UI::BeginItemTooltip()) {
//                     UI::Text(req.headers);
//                     UI::EndTooltip();
//                 }
//                 UI::EndDisabled();

//                 UI::TableNextColumn();
//                 UI::BeginDisabled(req.result.Length == 0);
//                 if (UI::Button(Icons::Clipboard + "##result" + i))
//                     IO::SetClipboard(req.result);
//                 if (UI::BeginItemTooltip()) {
//                     UI::Text(req.result);
//                     UI::EndTooltip();
//                 }
//                 UI::EndDisabled();

//                 UI::TableNextColumn();
//                 UI::BeginDisabled(req.parsed is null || req.parsed.GetType() == Json::Type::Null);
//                 if (UI::Button(Icons::Clipboard + "##parsed" + i))
//                     IO::SetClipboard(Json::Write(req.parsed, true));
//                 if (UI::BeginItemTooltip()) {
//                     UI::Text(Json::Write(req.parsed, true));
//                     UI::EndTooltip();
//                 }
//                 UI::EndDisabled();
//             }
//         }

//         UI::PopStyleColor();
//         UI::EndTable();
//     }
}
