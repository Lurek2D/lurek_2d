# Analiza: Standalone Build Lurek2D na Linux i Windows

Aby Lurek2D działał jako w pełni niezależna aplikacja (standalone) na docelowych maszynach bez konieczności instalowania dodatkowych pakietów przez użytkownika, musimy odpowiednio podejść do procesu budowania, w szczególności do linkowania bibliotek systemowych. Lurek2D wykorzystuje wgpu (Vulkan/DX12), winit (X11/Wayland), rodio (ALSA/WASAPI) oraz mlua.

## 1. Windows
Na systemie Windows problem zależności jest najmniej odczuwalny, ponieważ Lurek2D korzysta natywnie z DirectX 12 i systemowych bibliotek Windows API (user32, kernel32) czy WASAPI dla dźwięku.
Jedynym problemem jest często brak bibliotek środowiska uruchomieniowego C++ (MSVC / `VCRUNTIME140.dll`).

**Rozwiązanie:** 
Aby skompilować Lurek2D z wbudowanym środowiskiem wykonawczym (statically linked C runtime), wystarczy dodać odpowiednią flagę przy budowaniu:
```powershell
$env:RUSTFLAGS="-C target-feature=+crt-static"
cargo build --release
```
Alternatywnie, można dodać do pliku `.cargo/config.toml`:
```toml
[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "target-feature=+crt-static"]
```
Dzięki temu plik `.exe` będzie całkowicie niezależny i uruchomi się od razu na świeżym systemie Windows 10/11.

## 2. Linux
Problem z `GLIBC_2.43 not found` wynika stąd, że plik binarny został skompilowany na nowej dystrybucji Linuksa (która posiada najnowszą wersję biblioteki C, tzw. glibc). W przeciwieństwie do Windowsa, glibc nie pozwala na linkowanie statyczne (musl pozwala, ale sprawia problemy z wgpu/X11/Vulkan). 

Binarki skompilowane na starszym glibc uruchomią się na nowszym (glibc jest wstecznie kompatybilne), ale **nigdy na odwrót**. 

### Biblioteki współdzielone (dynamiczne) wymagane przez Lurek2D na Linux:
Ponieważ Lurek2D używa `winit`, `wgpu` (Vulkan) i `rodio` (ALSA), standardowy build dynamicznie linkuje:
* `libc.so.6`, `libm.so.6`, `libgcc_s.so.1`, `libpthread.so.0` (Podstawowe - zależą od glibc)
* `libX11.so.6`, `libXcursor.so.1`, `libXrandr.so.2`, `libXi.so.6` (Zależności okien X11)
* `libwayland-client.so.0` (Zależności Wayland)
* `libxkbcommon.so.0` (Klawiatura)
* `libvulkan.so.1` (Zależność sterownika graficznego)
* `libasound.so.2` (Dźwięk)

### Rozwiązanie na `GLIBC_2.43 not found`:
Aby rozwiązać problem glibc i pokryć większość systemów, plik binarny pod Linuksa musi być budowany na **najstarszej wspieranej dystrybucji**. Najpowszechniejszą praktyką jest budowanie aplikacji na **Ubuntu 20.04 (Focal)** w kontenerze Docker lub poprzez GitHub Actions (`ubuntu-20.04`). Posiada ona `glibc 2.31`, więc gra uruchomi się na każdym systemie nowszym niż Ubuntu 20.04 / Debian 11.

## 3. Tworzenie IMAGE APP (AppImage) dla Linuxa
Aby dostarczyć grę dla Linuksa jako jeden plik "kliknij-i-graj" (AppImage), który wewnątrz zawiera wszystkie nietypowe zależności (np. `libasound`, gdyby brakowało na systemie), musimy użyć narzędzia `linuxdeploy`. AppImage korzysta z wcześniej wspomnianej reguły: musi być budowany na starszym systemie operacyjnym (np. Ubuntu 20.04).

### Kroki do stworzenia AppImage z Lurek2D:

1. **Przygotowanie binarki**
   Kompilujemy silnik w środowisku ze starym glibc:
   ```bash
   cargo build --profile dist
   ```

2. **Pobranie linuxdeploy**
   ```bash
   wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
   chmod +x linuxdeploy-x86_64.AppImage
   ```

3. **Stworzenie struktury AppDir**
   Aplikacja potrzebuje pliku `.desktop` oraz ikony. Tworzymy przykładowy plik `lurek2d.desktop`:
   ```ini
   [Desktop Entry]
   Name=Lurek2D Game
   Exec=lurek2d
   Icon=lurek2d
   Type=Application
   Categories=Game;
   ```

4. **Budowanie pliku AppImage**
   Używamy `linuxdeploy` do stworzenia katalogu AppDir. Narzędzie to automatycznie przeanalizuje naszą binarkę, skopiuje potrzebne biblioteki .so (oprócz czarnej listy jak glibc czy sterowniki Vulkan, by zachować kompatybilność) i spakuje to w 1 plik:
   ```bash
   ./linuxdeploy-x86_64.AppImage --appdir AppDir \
      --executable target/dist/lurek2d \
      --desktop-file lurek2d.desktop \
      --icon plik_ikony.png \
      --output appimage
   ```

W wyniku tego polecenia powstanie plik np. `Lurek2D_Game-x86_64.AppImage`. Użytkownik nadaje mu prawa do wykonywania (`chmod +x`) i może włączyć dwukrotnym kliknięciem, bez konieczności instalowania w systemie bibliotek (ponieważ są zaszyte wewnątrz pliku, a glibc jest na tyle stare, że pasuje do jego systemu).
