NIXXSCRIPT — BLADE SPIN x OPAH | GITHUB EDITION
================================================

STRUKTUR
--------
Loader/Main.lua
BladeSpin/Info/UserInfo.lua
BladeSpin/Teleport/PlayerTeleport.lua
BladeSpin/System/SystemTools.lua
BladeSpin/Server/ServerTools.lua
BladeSpin/GameActions/GameActions.lua
BladeSpin/Credits/Credits.lua
Opah/ESP/ESP.lua
Opah/Info/RadarPasscode.lua
Opah/Misc/MovementVisual.lua
Opah/Auto/KeyEscape.lua
Integrations/Telegram/TelegramLogger.lua

CARA PUSH KE GITHUB
-------------------
1. Buat repository publik bernama: NixxScript
2. Upload SEMUA isi folder project ini ke root repository.
3. Pastikan branch bernama: main.
4. Buka Loader/Main.lua dan ganti GITHUB_USERNAME dengan username GitHub kamu.
5. Commit perubahan tersebut.
6. Ambil URL Raw loader dengan format:
   https://raw.githubusercontent.com/USERNAME/NixxScript/main/Loader/Main.lua
7. Jalankan loader melalui executor yang mendukung game:HttpGet dan loadstring.

SEMUA MODUL
-----------
Loader mengambil modul satu per satu menggunakan URL Raw GitHub.
Folder GitHub tetap dipertahankan; jangan mengubah nama folder/file kecuali
kamu juga mengubah path di Loader/Main.lua.

TELEGRAM LOGGER — PENTING
-------------------------
Integrasi Telegram dipisahkan di:
Integrations/Telegram/TelegramLogger.lua

Modul ini nonaktif secara default dan meminta persetujuan melalui toggle.
Modul hanya mengirim username Roblox, user ID, dan Place ID ke endpoint relay
HTTPS privat yang kamu kelola. Modul tidak mengambil IP, kota, ISP, atau nama
executor. Isi RELAY_URL dengan endpoint relay privat milikmu.

JANGAN menyimpan Telegram bot token di repository publik atau LocalScript/
executor. Buat relay backend privat dan simpan token sebagai environment
secret di hosting backend. Token bot yang sebelumnya tertanam pada Pastebin
sudah terekspos: segera revoke token tersebut melalui BotFather dan buat token
baru. Jangan gunakan lagi token lama.

CATATAN FITUR
-------------
- Tidak ada GUI AZZURA; UI utama menggunakan WindUI dan bernama NixxScript.
- Menu dibuat dahulu, modul diunduh paralel sesudahnya.
- Setiap modul harus mengembalikan `function(ctx) ... end`.
- Unlock All Swords dan Auto Farm Coins/XP dari source Blade tidak dijalankan
  karena implementasi sumber memalsukan reward lewat remote server.
- Bypass Admin sumber melakukan kick pada pemain sendiri; tidak dipindahkan.
- Fitur Opah tetap memiliki ESP, radar/passcode, movement, dan auto key/escape.
- Script belum diuji langsung di Roblox/executor. Kompatibilitas API WindUI,
  executor, dan struktur game dapat memerlukan penyesuaian.
