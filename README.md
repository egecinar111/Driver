# Tek Hareketle Sürücü Güncelleme Aracı

Bu depo, bilgisayar hakkında hiçbir şey bilmeyen birinin bile Windows 10 veya Windows 11 üzerinde tüm sürücüleri tek seferde güncellemesine yardım edecek basit bir PowerShell betiği içerir.

## Gereksinimler
- Windows 10 ya da Windows 11
- İnternet bağlantısı
- Yönetici yetkisi (betik bunu otomatik olarak istemeye çalışır)

## Nasıl Kullanılır?
1. Sağ üstteki **Code** butonuna tıklayın ve **Download ZIP** seçeneğini kullanarak bu depoyu bilgisayarınıza indirin.
2. İndirdiğiniz `.zip` dosyasına sağ tıklayın ve **Tümünü ayıkla...** seçeneği ile klasöre çıkartın.
3. Açılan klasörün içinde `scripts` adlı klasörü bulun.
4. `update-drivers.ps1` dosyasına sağ tıklayın ve **PowerShell ile çalıştır** seçeneğini seçin.
   - Eğer PowerShell betiğini doğrudan çalıştırmanıza izin vermezse, dosyayı seçip üst menüden **Daha fazla göster > PowerShell ile çalıştır** adımlarını izleyin.
5. Windows sizden yönetici izni isterse **Evet** butonuna tıklayın.
6. Betik otomatik olarak:
   - Gerekli araçları indirir,
   - Microsoft Update üzerinden en güncel sürücüleri bulur,
   - Uygun olanları yükler.
7. İşlem tamamlandığında betik size sürücülerin başarıyla kurulup kurulmadığını ve yeniden başlatma gerekip gerekmediğini bildirir.
8. Pencerede "Enter'a bas" uyarısını gördüğünüzde **Enter** tuşuna basarak pencereyi kapatabilirsiniz.

> **Not:** Bazı sürücülerin yüklenmesi için bilgisayarınızı yeniden başlatmanız gerekebilir. Betik bunu açıkça belirtir.

## Betiğin Ne Yaptığı
- Yönetici olarak tekrar başlar (gerekirse).
- PowerShell'in gerekli paket sağlayıcısını ve `PSWindowsUpdate` modülünü indirir.
- Microsoft Update hizmetini etkinleştirir.
- Sadece **Sürücüler** kategorisindeki güncellemeleri kabul edip yükler.
- Sonuçları özetler ve gerekirse yeniden başlatma uyarısı verir.

## Sorun Giderme
- Microsoft Update servisi kapatılmışsa, betiği çalıştırmadan önce Windows Update ayarlarından etkinleştirin.
- İşletim sisteminiz Windows 7/8 ise bu betik desteklenmez.
- Güvenlik yazılımınız PowerShell betiklerinin çalışmasını engelliyorsa, geçici olarak izin vermeniz gerekebilir.

Herhangi bir adımda takılırsanız, PowerShell penceresindeki renkli açıklamaları takip ederek ne yapmanız gerektiğini görebilirsiniz.
