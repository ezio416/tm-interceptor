const string  generatedFileStorage = IO::FromStorageFolder("_Generated.as");
bool          generating           = false;
const string  pluginColor          = "\\$FFF";
const string  pluginIcon           = Icons::Code;
Meta::Plugin@ pluginMeta           = Meta::ExecutingPlugin();
const string  pluginTitle          = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const string  pluginPath           = pluginMeta.SourcePath;
const string  generatedFileSource  = pluginPath + "/src/_Generated.as";
const string  tomlFile             = pluginPath + "/info.toml";

void OnDestroyed() {
    Interception::StopAll();
}

void OnDisabled()  {
    Interception::StopAll();
}

void Main() {
    LoadLookup();
    SaveLookup();

    FilterLookupNoMethodsAsync();
    GenerateCodeAsync();
}

void Render() {
    if (false
        or !S_Enabled
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_HideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

    if (UI::Begin(pluginTitle, S_Enabled)) {
        RenderWindow();
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void RenderWindow() {
    const float scale = UI::GetScale();

#if GENERATED
    if (UI::Button("UnApply")) {
        UnApplyGenerated();
    }
#else
    if (UI::Button("Apply")) {
        ApplyGenerated();
    }
#endif

    if (generating) {
        UI::SameLine();
        UI::TextDisabled("generating...");
    }

    for (uint i = 0; i < _classes.Length; i++) {
        GameClass@ Class = _classes[i];

        if (UI::CollapsingHeader(Class.name + " (" + Class.methods.Length + ")")) {
            UI::Indent(scale * 25.0f);

            UI::BeginDisabled(false
#if !GENERATED
                or true
#endif
                or generating
            );

            for (uint j = 0; j < Class.methods.Length; j++) {
                ClassMethod@ method = Class.methods[j];

                if (UI::Checkbox(method.name + "##" + Class.name, method.active)) {
                    method.Start();
                } else {
                    method.Stop();
                }
            }

            UI::EndDisabled();

            UI::Indent(scale * -25.0f);
        }
    }
}

void GenerateCodeAsync() {
    if (generating) {
        return;
    }

    generating = true;

    const uint64 start = Time::Now;
    trace("generating");

#if TMNEXT || MP4 || TURBO
    string exe = cast<CTrackMania>(GetApp()).ManiaPlanetScriptAPI.ExeVersion;
#elif FOREVER
    string exe = "unknown";
#endif

    string gen = '// Automatically generated at ' + Time::FormatStringUTC('%FT%TZ', Time::Stamp)
        + ' for exe version ' + exe;

#if TMNEXT
    gen += ' (NEXT)';
#elif MP4
    gen += ' (MP4)';
#elif TURBO
    gen += ' (TURBO)';
#elif UNITED_FOREVER
    gen += ' (UNITED_FOREVER)';
#elif NATIONS_FOREVER
    gen += ' (NATIONS_FOREVER)';
#endif

    gen += '\n';

    string CreateMethod = '#if GENERATED\nnamespace Interceptor {\n\tClassMethod@ ' +
        'CreateMethod(GameClass@ parent, const string&in name, Json::Value@ method) {\n';

    string[]@ classNames = classes.GetKeys();
    for (uint i = 0; i < classNames.Length; i++) {
        GameClass@ Class = cast<GameClass>(classes[classNames[i]]);

        for (uint j = 0; j < Class.methods.Length; j++) {
            ClassMethod@ method = Class.methods[j];

            gen += string::Join(method.GenerateLines(), '\n');

            CreateMethod += '\t\tif (parent.name == "' + Class.name + '" and name == "' + method.name
            + '")\n\t\t\treturn Interceptor::Class_' + Class.name + '::Method_' + method.name + '(parent, name, method);\n\n';
        }

        gen += '\n';

        yield();
    }

    CreateMethod += '\t\treturn null;\n\t}\n}\n#endif\n';

    IO::File file(generatedFileStorage, IO::FileMode::Write);
    file.Write(gen + '\n' + CreateMethod);
    file.Close();

    generating = false;

    trace("generated after " + (Time::Now - start) + "ms");
}

void ApplyGenerated() {
    if (IO::FileExists(generatedFileStorage)) {
        IO::Copy(generatedFileStorage, generatedFileSource);
    } else {
        warn("no file generated yet");
    }

    IO::File toml(tomlFile, IO::FileMode::Read);
    string contents = toml.ReadToEnd();
    toml.Close();

    toml.Open(IO::FileMode::Write);
    toml.Write(contents.Replace("#defines", "defines"));
    toml.Close();

    Meta::ReloadPlugin(pluginMeta);
}

void UnApplyGenerated() {
    if (IO::FileExists(generatedFileSource)) {
        IO::Delete(generatedFileSource);
    }

    IO::File toml(tomlFile, IO::FileMode::Read);
    string contents = toml.ReadToEnd();
    toml.Close();

    toml.Open(IO::FileMode::Write);
    toml.Write(contents.Replace("defines", "#defines"));
    toml.Close();

    Meta::ReloadPlugin(pluginMeta);
}

#if !GENERATED
namespace Interceptor {
    ClassMethod@ CreateMethod(GameClass@ parent, const string&in name, Json::Value@ method) {
        return ClassMethod(parent, name, method);
    }
}
#endif
