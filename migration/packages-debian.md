# Пакеты Debian 13

Устанавливай блоки последовательно. Debian Stable выбран сознательно:
системные компоненты обновляются через APT, а быстро меняющиеся языковые
инструменты — изолированно через mise/uv.

## Основа Sway/Wayland

```sh
sudo apt install \
  sway foot waybar wofi sway-notification-center clipman \
  xwayland xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  wl-clipboard grim slurp jq \
  network-manager network-manager-gnome \
  bluetooth bluez blueman \
  pipewire-audio wireplumber pavucontrol \
  swayidle swaylock swaybg \
  ddcutil tmux zsh git-delta \
  fonts-jetbrains-mono fonts-noto-color-emoji
```

Включи сеть и Bluetooth:

```sh
sudo systemctl enable --now NetworkManager bluetooth
```

Если Wi-Fi не заработал после установки:

```sh
sudo apt install firmware-iwlwifi
sudo reboot
```

Не добавляй `contrib` и `non-free` «на всякий случай»: для firmware нужен
отдельный `non-free-firmware`. Проверить `/etc/apt/sources.list.d/debian.sources`:
в строке `Components:` должны быть как минимум `main non-free-firmware`.

## Редактор и базовые CLI-инструменты

```sh
sudo apt install \
  neovim ripgrep fd-find fzf make gcc g++ \
  unzip xz-utils tar shellcheck \
  lazygit htop btop starship zsh-autosuggestions
```

В Debian бинарник поиска файлов называется `fdfind`; если плагинам Neovim
нужен именно `fd`, добавь в `~/.local/bin` симлинк:

```sh
mkdir -p ~/.local/bin
ln -s /usr/bin/fdfind ~/.local/bin/fd
```

Neovim сам скачает lazy.nvim и плагины при первом запуске. Для LuaSnip и
Telescope в текущем конфиге нужны `make` и компилятор — они есть в блоке выше.

## Firefox и Docker

```sh
sudo apt install firefox-esr
```

Для Docker выбираем официальный Docker APT repository, а не смешиваем его с
`docker.io`: он даёт актуальные Engine, Buildx и `docker compose`. Следуй
официальной инструкции <https://docs.docker.com/engine/install/debian/> и
установи:

```sh
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

Затем выйди из TTY и войди снова, проверь `docker run hello-world` и
`docker compose version`. Группа `docker` фактически даёт root-подобный
доступ; добавляй в неё только свой локальный аккаунт.

Podman — альтернативный daemonless контейнерный движок, совместимый с
большинством Docker-команд. Он не нужен: план рассчитан на Docker.

## Современные Python и Node.js

Debian Python оставь системным: `python3` и APT-пакеты не трогай через pip.
Для проектов используй uv:

```sh
sudo apt install python3 python3-venv pipx
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Перелогинься или добавь `~/.local/bin` в `PATH`; затем:

```sh
uv python install 3.13
uv init example-python
```

Для Node.js используй mise: он закрепляет версии по проектам и не засоряет APT.
Установщик и инструкция: <https://mise.jdx.dev/getting-started.html>.
После проверки инструкции установи и активируй его:

```sh
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
exec zsh
```

Затем:

```sh
mise use --global node@lts
corepack enable
```

Это даёт современный Node LTS и pnpm/yarn через Corepack. Глобальные npm-пакеты
ставь редко; `prettier` и `prettierd` лучше хранить зависимостями проектов.

## Инструменты для LSP и форматирования Neovim

Текущий конфиг ожидает clangd, basedpyright, gopls, Stylua, Ruff и Prettier.
Ставь их только если работаешь с соответствующим языком:

```sh
sudo apt install clangd golang-go
uv tool install basedpyright
uv tool install ruff
mise use --global go@latest
npm install --global @fsouza/prettierd prettier @johnnymorganz/stylua-bin
```

Проверь `Mason` в Neovim: он может установить часть LSP самостоятельно.
Не смешивай два источника одного инструмента без причины.
