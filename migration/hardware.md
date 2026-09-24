# Оборудование, замеченное на Arch

Снимок сделан 2026-09-24.

| Устройство | Идентификатор | Debian |
| --- | --- | --- |
| CPU | Intel N150, x86_64, 4 потока | штатное ядро Debian |
| GPU | Intel Alder Lake-N, PCI `8086:46d4`, драйвер `i915` | штатное ядро/Mesa; отдельный проприетарный драйвер не нужен |
| Wi-Fi | Intel Alder Lake-N PCH CNVi, PCI `8086:54f0` | `firmware-iwlwifi`, модуль `iwlwifi` |
| Ethernet | Realtek RTL8111/8168/8211/8411, PCI `10ec:8168` | модуль ядра `r8169`; отдельный пакет обычно не нужен |
| Bluetooth | не удалось определить через USB из sandbox | установить `bluez blueman`; для Intel Wi-Fi/BT сначала проверить `firmware-iwlwifi` |

Проверка после установки:

```sh
lspci -nnk | grep -A3 -Ei 'network|wireless|ethernet'
rfkill list
nmcli device
bluetoothctl show
journalctl -b -k | grep -iE 'iwlwifi|bluetooth|firmware'
```

Если Bluetooth не видит адаптер, сначала обнови систему, затем проверь
`firmware-iwlwifi`. Для редких Broadcom-адаптеров может потребоваться
`bluez-firmware`; это не предполагается заранее, потому что чипсет не
определён надёжно.

Справка Debian: <https://wiki.debian.org/Firmware> и
<https://wiki.debian.org/BluetoothUser>.

## Текущая схема диска

Один SSD `/dev/sda` (476.9 GiB): ESP `/dev/sda1` на 2 GiB (FAT) и корневой
раздел `/dev/sda2` на оставшееся место (ext4). UUID намеренно не сохранены:
после чистой установки они изменятся. Перед разметкой в установщике перепроверь
имя диска и его размер — они могут отличаться при подключённых USB-накопителях.
