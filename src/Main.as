const string  generatedFileStorage = IO::FromStorageFolder("_Generated.as");
const string  pluginColor          = "\\$FFF";
const string  pluginIcon           = Icons::Code;
Meta::Plugin@ pluginMeta           = Meta::ExecutingPlugin();
const string  pluginTitle          = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const string  pluginPath           = pluginMeta.SourcePath;
const string  generatedFileSource  = pluginPath + "/src/_Generated.as";
const string  tomlFile             = pluginPath + "/info.toml";
const float   scale                = UI::GetScale();

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

    if (UI::Begin(pluginTitle, S_Enabled, UI::WindowFlags::None)) {
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
#if GENERATED
    if (UI::Button("UnApply")) {
        UnApplyGenerated();
    }
#else
    if (UI::Button("Apply")) {
        ApplyGenerated();
    }
#endif

    for (uint i = 0; i < _classes.Length; i++) {
        GameClass@ Class = _classes[i];

        if (UI::CollapsingHeader(Class.name + " (" + Class.methods.Length + ")")) {
            UI::Indent(scale * 25.0f);

            for (uint j = 0; j < Class.methods.Length; j++) {
                ClassMethod@ method = Class.methods[j];

                if (UI::Checkbox(method.name + "##" + Class.name, method.active)) {
                    method.Start();
                } else {
                    method.Stop();
                }
            }

            UI::Indent(scale * -25.0f);
        }
    }
}

void GenerateCodeAsync() {
    const uint64 start = Time::Now;
    trace("generating");

    string gen = '// Automatically generated at ' + Time::FormatStringUTC('%FT%TZ', Time::Stamp)
        + ' for exe version ' + GetApp().SystemPlatform.ExeVersion + '\n'
    ;

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
