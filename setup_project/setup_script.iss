; Скрипт Inno Setup для создания установщика Calculator App
; Аналог RPM пакета для Windows

[Setup]
; Основные параметры приложения (аналог Name, Version, Release в RPM)
AppName=Calculator App
AppVersion=1.0.0
AppVerName=Calculator App 1.0.0
AppPublisher=
AppPublisherURL=
AppSupportURL=
AppUpdatesURL=

; Параметры установки
DefaultDirName={pf}\Calculator App
DefaultGroupName=Calculator App
AllowNoIcons=yes
LicenseFile=
InfoBeforeFile=app\readme.txt
OutputDir=output
OutputBaseFilename=calculator-app-setup-1.0.0
Compression=lzma
SolidCompression=yes
SetupIconFile=

; Поддержка архитектур
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Права администратора
PrivilegesRequired=admin

; Языки (аналог Summary(ru) в RPM)
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

; Описание для английского языка
[CustomMessages]
english.AppDescription=Advanced calculator application with basic and scientific functions.
russian.AppDescription=Расширенное приложение калькулятор с базовыми и научными функциями.

; Файлы для установки (аналог секции %files в RPM)
[Files]
; Основные файлы приложения
Source: "app\index.html"; DestDir: "{app}"; Flags: ignoreversion
Source: "app\style.css"; DestDir: "{app}"; Flags: ignoreversion
Source: "app\script.js"; DestDir: "{app}"; Flags: ignoreversion
Source: "app\readme.txt"; DestDir: "{app}"; Flags: ignoreversion isreadme

; Иконки в меню Пуск (аналог создания shortcuts)
[Icons]
Name: "{group}\Calculator App"; Filename: "{app}\index.html"; IconFilename: "{sys}\shell32.dll"; IconIndex: 137
Name: "{group}\Readme"; Filename: "{app}\readme.txt"
Name: "{group}\Uninstall Calculator App"; Filename: "{uninstallexe}"
Name: "{commondesktop}\Calculator App"; Filename: "{app}\index.html"; IconFilename: "{sys}\shell32.dll"; IconIndex: 137; Tasks: desktopicon

; Опциональные задачи
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

; Запуск после установки
[Run]
Filename: "{app}\readme.txt"; Description: "View Readme"; Flags: postinstall shellexec skipifsilent unchecked
Filename: "{app}\index.html"; Description: "Launch Calculator App"; Flags: postinstall nowait shellexec; WorkingDir: "{app}"

; Код для дополнительной настройки
[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
  MsgBox('Начинается установка Calculator App' + #13#10 + 
         'Version: 1.0.0' + #13#10 + 
         'Расширенное приложение калькулятор', mbInformation, MB_OK);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    MsgBox('Установка успешно завершена!' + #13#10 + 
           'Приложение установлено в: ' + ExpandConstant('{app}'), 
           mbInformation, MB_OK);
  end;
end;