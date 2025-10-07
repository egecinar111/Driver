<#
.SYNOPSIS
    Tek bir komutla Windows bilgisayarınızdaki tüm sürücüleri günceller.

.DESCRIPTION
    Bu betik, Microsoft Update hizmetinden en son sürücü güncellemelerini aramak
    ve yüklemek için PSWindowsUpdate PowerShell modülünü kullanır. Hiç teknik bilgisi
    olmayan kullanıcılar için tasarlanmıştır: Betik kendini yönetici olarak tekrar
    çalıştırır, gerekli modülleri yükler ve tüm sürücü güncellemelerini otomatik
    olarak kurar.

    Desteklenen sistemler: Windows 10 ve Windows 11.
#>

function Complete-Script {
    param(
        [int]$ExitCode = 0
    )

    Write-Host "" # boş satır
    Write-Host "Bu pencereyi kapatmak için Enter'a basabilirsiniz." -ForegroundColor Cyan
    Read-Host | Out-Null
    exit $ExitCode
}

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Bu betik yönetici olarak çalıştırılmalıdır. Yetkili PowerShell yeniden açılıyor..." -ForegroundColor Yellow
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ErrorActionPreference = 'Stop'
Write-Host "Sürücü güncelleme sihirbazı başlatılıyor..." -ForegroundColor Cyan

try {
    # Bu oturum için komutların engellenmemesi adına ExecutionPolicy'i geçici olarak gevşet.
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

    # PowerShell Gallery'den modül indirirken TLS 1.2 kullanıldığından emin ol.
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Gerekli paket sağlayıcılarını ve modülü yükle.
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "NuGet paket sağlayıcısı yükleniyor..." -ForegroundColor Cyan
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    }

    try {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
    } catch {
        # PSGallery zaten güvenilir ise devam et.
    }

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "PSWindowsUpdate modülü indiriliyor..." -ForegroundColor Cyan
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    }

    Import-Module PSWindowsUpdate -Force

    # Microsoft Update hizmetini kayıt ettirerek sürücü güncellemelerinin listelenmesini sağla.
    Write-Host "Microsoft Update hizmeti etkinleştiriliyor..." -ForegroundColor Cyan
    Add-WUServiceManager -MicrosoftUpdate -Confirm:$false | Out-Null

    Write-Host "Sürücü güncellemeleri aranıyor. Lütfen bekleyin, bu işlem birkaç dakika sürebilir..." -ForegroundColor Cyan

    $updateResults = Get-WindowsUpdate -MicrosoftUpdate -Category Drivers -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue

    if (-not $updateResults) {
        Write-Host "Tebrikler! Tüm sürücüleriniz zaten güncel." -ForegroundColor Green
        Complete-Script -ExitCode 0
    }

    $installedDrivers = $updateResults | Where-Object { $_.IsInstalled -eq $true }
    $failedDrivers    = $updateResults | Where-Object { $_.IsInstalled -ne $true }

    if ($installedDrivers) {
        Write-Host "Aşağıdaki sürücüler başarıyla kuruldu:" -ForegroundColor Green
        $installedDrivers | Select-Object Title, KB, Size | Format-Table -AutoSize
    }

    if ($failedDrivers) {
        Write-Host "Bazı sürücüler yüklenemedi. Daha sonra tekrar deneyin ya da Windows Update ile kontrol edin:" -ForegroundColor Yellow
        $failedDrivers | Select-Object Title, KB, HResult | Format-Table -AutoSize
    }

    $needsReboot = $updateResults | Where-Object { $_.RebootRequired -eq $true }
    if ($needsReboot) {
        Write-Host "Güncellemelerin tamamlanması için bilgisayarınızı yeniden başlatmanız gerekiyor." -ForegroundColor Yellow
        Write-Host "Hazır olduğunuzda sisteminizi yeniden başlatın." -ForegroundColor Yellow
    } else {
        Write-Host "Sürücü güncellemeleri tamamlandı. Yeniden başlatma gerekmiyor." -ForegroundColor Green
    }

    Complete-Script -ExitCode 0
} catch {
    Write-Host "Beklenmeyen bir hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Ayrıntılar:" -ForegroundColor DarkYellow
    Write-Host $_ -ForegroundColor DarkGray
    Complete-Script -ExitCode 1
}
