# eyezon-sdk


# Сборка и установка SDK
1. Запустить скрипт build.sh в папке с SDK (EyezonSDK/build.sh)
2. По завершению работы команды в папке EyezonSDK появится папка build, в которой лежит собранная библиотека в формате .xcframework
3. Этот файлик (папку) нужно добавлять в сам проект, в настройках проекта General - Frameworks, Libraries, and Embedded Content
4. Теперь где нужно делаем `import EyezonSDK`

# Работа c SDK
1. Для предоставления нашей сдк девайс токена устройства нужно в методе:
`func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) `
Вызвать  `Eyezon.instance.initMessaging(apnsData: deviceToken)`

2. Открытие кнопки выглядит следующим образом:
`Eyezon.instance.initSdk(area: selectedServer) { [weak self, predefinedData] in
    let eyezonWebViewController = Eyezon.instance.openButton(data: predefinedData, broadcastReceiver: self)
    self?.navigationController?.pushViewController(eyezonWebViewController, animated: true)
}`
- где `broadcastReceiver` это объект реализующий протокол `EyezonBroadcastReceiver`
- `selectedServer` - сервер клиента
- `Eyezon.instance.openButton` - отдает UIViewController в котором находится наша вебвью с нашей логикой

