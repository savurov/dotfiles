# Конфиги для первого переноса

Клонирование репозитория восстанавливает все отслеживаемые файлы, но для
первого запуска Sway важны именно эти:

| Путь | Назначение | Внешние программы |
| --- | --- | --- |
| `sway/config` | бинды, запуск панели и апплетов | foot, waybar, wofi, nm-applet, blueman-applet, swaync |
| `sway/scripts/` | окна по workspace, раскладка, яркость | swaymsg, jq, tmux, ddcutil, wofi |
| `waybar/` | панель | waybar, jq, swaymsg, swaync-client |
| `foot/foot.ini` | терминал | foot, tmux |
| `mako/config` | исторический конфиг уведомлений | mako (не включён: Sway запускает swaync) |
| `nvim/` | Neovim | git, make, ripgrep, fd/fdfind и языковые инструменты |
| `lazygit/` | интерфейс Git | lazygit, git-delta |
| `fontconfig/fonts.conf` | шрифты | fontconfig |
| `gtk-3.0/`, `gtk-4.0/`, `mimeapps.list` | GTK и приложения по умолчанию | GTK, Firefox |
| `migration/home/zshrc` | шаблон конфигурации Zsh вне `.config` | zsh, starship, zsh-autosuggestions |

Необходимые ручные проверки:

- `sway/scripts/chrome.sh` запускает Google Chrome, а базовый план ставит
  Firefox ESR. Либо не используй этот биндинг, либо позднее установи Chrome.
- `sway/scripts/gpt.sh` предполагает отдельное приложение/команду — проверь
  её после переезда, не включена в базовый план.
- Яркость использует DDC/CI и `ddcutil`; для мониторов может понадобиться
  группа `i2c` или настройка udev. Не ослабляй права без проверки.
- KDE/Plasma-файлы в репозитории — исторические и не требуются Sway; не нужно
  устанавливать Plasma ради них.
- `systemd/user/firefox-launch.service` в текущем каталоге не отслеживается и
  предназначен для KWin; в Sway он не нужен.
