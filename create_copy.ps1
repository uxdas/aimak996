param(
    [Parameter(Mandatory=$true)]
    [string]$NewName
)

# Проверяем, что передано новое название
if ([string]::IsNullOrEmpty($NewName)) {
    Write-Host "Использование: .\create_copy.ps1 -NewName 'Новое название'"
    Write-Host "Пример: .\create_copy.ps1 -NewName 'Ош 996'"
    exit 1
}

$NewNameLower = $NewName.ToLower() -replace ' ', '_'
$NewDir = "..\$NewNameLower"

# Создаем новую директорию
New-Item -ItemType Directory -Force -Path $NewDir

# Копируем все файлы
Copy-Item -Path * -Destination $NewDir -Recurse -Force

# Переходим в новую директорию
Set-Location $NewDir

# Заменяем название в pubspec.yaml
(Get-Content pubspec.yaml) -replace 'name: aimak996', "name: $NewNameLower" | Set-Content pubspec.yaml

# Заменяем название в main.dart
(Get-Content lib/main.dart) -replace "title: 'Аймак 996'", "title: '$NewName'" | Set-Content lib/main.dart

# Заменяем название в splash_screen.dart
(Get-Content lib/screens/splash_screen.dart) -replace "'Аймак 996'", "'$NewName'" | Set-Content lib/screens/splash_screen.dart

# Заменяем название в about_screen.dart
(Get-Content lib/features/about/about_screen.dart) -replace 'Аймак 996', $NewName | Set-Content lib/features/about/about_screen.dart

# Заменяем название в developer_screen.dart
(Get-Content lib/features/about/developer_screen.dart) -replace "'Aimak 996'", "'$NewName'" | Set-Content lib/features/about/developer_screen.dart

# Заменяем название в файлах переводов
(Get-Content assets/translations/ru.json) -replace '"app_title": "Аймак 996"', "`"app_title`": `"$NewName`"" | Set-Content assets/translations/ru.json
(Get-Content assets/translations/ky.json) -replace '"app_title": "Аймак 996"', "`"app_title`": `"$NewName`"" | Set-Content assets/translations/ky.json
(Get-Content assets/translations/ru.json) -replace '"company_name": "Аймак 996"', "`"company_name`": `"$NewName`"" | Set-Content assets/translations/ru.json
(Get-Content assets/translations/ky.json) -replace '"company_name": "Аймак 996"', "`"company_name`": `"$NewName`"" | Set-Content assets/translations/ky.json

Write-Host "Копия проекта создана в директории: $NewDir"
Write-Host "Не забудьте:"
Write-Host "1. Проверить все изменения в файлах"
Write-Host "2. Обновить иконки и изображения"
Write-Host "3. Обновить package name в Android и iOS настройках"
Write-Host "4. Обновить bundle identifier в iOS настройках" 