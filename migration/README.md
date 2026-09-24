# Переезд на Debian 13 (Trixie)

Этот каталог — минимальный, воспроизводимый план для этого ПК: Debian Stable,
TTY в качестве первой точки входа и Sway/Wayland поверх него. Он не переносит
данные, профили браузера, токены, SSH/GPG-ключи или пароли.

## Что сохранить до форматирования

1. Убедиться, что все нужные изменения отправлены в этот репозиторий:
   `git status && git push`.
2. Сохранить отдельно пользовательские данные, которые нужны вне этого
   репозитория: `~/Documents`, проекты, `~/.ssh`, GPG-ключи, Firefox-профиль
   (если нужен), ключи доступа к сервисам и резервные коды 2FA.
3. Скачать актуальный Debian 13 amd64 **netinst** ISO с
   <https://www.debian.org/distrib/> и проверить SHA512SUM/подпись.

## Установка с флешки

В установщике создай обычного пользователя с правами sudo. В выборе software
не выбирай ни одного desktop environment: после перезагрузки должна быть TTY.
Сетевой доступ по Ethernet удобнее, но официальный образ Debian 13 умеет
предлагать firmware для устройств во время установки.

Для этого ПК обнаружены Intel Alder Lake-N CNVi Wi-Fi (драйвер `iwlwifi`) и
Realtek Ethernet RTL8111. Wi-Fi требует `firmware-iwlwifi`, которое находится
в компоненте `non-free-firmware`; Bluetooth часто использует firmware той же
Intel-карты. Это firmware, а не закрытый драйвер.

## Первый вход в TTY

```sh
sudo apt update
sudo apt full-upgrade
sudo apt install sudo git ca-certificates curl
git clone https://github.com/savurov/dotfiles.git ~/.config
```

Если `~/.config` уже существует, сначала сравни его содержимое, а не делай
слепое копирование. Затем выполни команды из [packages-debian.md](packages-debian.md).
Первый запуск сессии вручную:

```sh
dbus-run-session sway
```

Когда всё заработает, автологин/графический display manager можно добавить
отдельно; сейчас он намеренно не является частью базовой установки.

## После первого запуска Sway

Проверь: терминал foot, Waybar, Wofi, звук, Wi-Fi, Bluetooth, скриншот
`Mod+i`, буфер обмена, раскладку и яркость. Конфиг запускает `nm-applet`,
`blueman-applet`, `swaync`, `wl-paste` и `clipman`; все они включены
в план. `mako/config` сохранён в репозитории, но текущий Sway запускает
swaync, поэтому mako не устанавливается, чтобы не было двух notification daemon.

## Что находится рядом

- [packages-debian.md](packages-debian.md) — выбранные пакеты, команды и
  Debian-аналоги.
- [hardware.md](hardware.md) — зафиксированное оборудование и firmware.
- [arch-explicit-packages.txt](arch-explicit-packages.txt) — полный снимок
  явных пакетов старой Arch-системы; справочный, не для массовой установки.
- [arch-foreign-packages.txt](arch-foreign-packages.txt) — отдельно AUR и
  сторонние пакеты, которые потребуют осознанной замены или ручной установки.
- [config-manifest.md](config-manifest.md) — какие конфиги реально нужны для
  базовой Sway-среды.

Источники: [установка Debian](https://www.debian.org/releases/stable/installmanual),
[firmware в Debian](https://wiki.debian.org/Firmware),
[Docker Engine для Debian](https://docs.docker.com/engine/install/debian/).
