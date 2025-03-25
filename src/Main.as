// c 2025-03-20
// m 2025-03-25

const string  pluginColor = "\\$FFF";
const string  pluginIcon  = Icons::Code;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  generatedFileSource = pluginMeta.SourcePath + "/src/Generated.as";
const string  generatedFileStorage = IO::FromStorageFolder("Generated.as");
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const float   scale       = UI::GetScale();

void OnDestroyed() { StopInterceptions(); }
void OnDisabled()  { StopInterceptions(); }

void Main() {
    LoadLookup();
    SaveLookup();

    FilterLookupNoMethodsAsync();
    GenerateCodeAsync();
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
            UI::Indent(scale * 25.0f);

            for (uint j = 0; j < Class.methods.Length; j++) {
                ClassMethod@ method = Class.methods[j];

                if (UI::Checkbox(method.name + "##" + Class.name, method.active))
                    method.Start();
                else
                    method.Stop();
            }

            UI::Indent(scale * -25.0f);
        }
    }
}

void GenerateCodeAsync() {
    const uint64 start = Time::Now;
    trace("generating");

    string gen = '// Automatically generated at ' + Time::FormatStringUTC('%F:%Tz', Time::Stamp)
        + ' for exe version ' + GetApp().SystemPlatform.ExeVersion + '\n'
    ;

    string CreateMethod = 'namespace Interceptor{\n\tClassMethod@ CreateMethod(GameClass@ parent, const string &in name, Json::Value@ method) {\n';

    string[]@ classNames = classes.GetKeys();
    for (uint i = 0; i < classNames.Length; i++) {
        GameClass@ Class = cast<GameClass@>(classes[classNames[i]]);

        for (uint j = 0; j < Class.methods.Length; j++) {
            ClassMethod@ method = Class.methods[j];

            gen += string::Join(method.GenerateLines(), '\n');

            CreateMethod += '\t\tif (parent.name == "' + Class.name + '" && name == "' + method.name + '")\n\t\t\treturn Interceptor::Class_' + Class.name + '::Method_' + method.name + '(parent, name, method);\n';
        }

        gen += '\n';

        yield();
    }

    CreateMethod += '\n\t\treturn null;\n\t}\n}\n';

    IO::File file(generatedFileStorage, IO::FileMode::Write);
    file.Write(gen + '\n' + CreateMethod);
    file.Close();

    trace("generated after " + (Time::Now - start) + "ms");
}
