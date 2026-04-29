# Maxine Hardware Documentation

## Bill of Materials

Full component list for one complete Maxine system (wearable + bedside units).

| Component | Description | Qty | Unit Cost | Total | Status |
|---|---|---|---|---|---|
| ESP32-WROOM-32E dev board | MCU for both units | 2 | $7.00 | $14.00 | Required |
| MAX30102 module | Heart rate + SpO₂ | 2 | $5.00 | $10.00 | Required |
| GY-906 MLX90614 | IR non-contact temperature | 1 | $8.00 | $8.00 | Required |
| GY-521 MPU-6050 | IMU for respiration | 1 | $3.00 | $3.00 | Required |
| BP cuff UART module | Oscillometric blood pressure | 1 | $32.00 | $32.00 | Required |
| Waveshare 4.2" e-paper | Bedside display | 1 | $18.00 | $18.00 | Required |
| Micro SD card module | SPI data logging | 1 | $4.00 | $4.00 | Recommended |
| 32GB micro SD card | Class 10 FAT32 | 1 | $8.00 | $8.00 | Recommended |
| 5V 2A USB-C adapter | Bedside power | 1 | $8.00 | $8.00 | Required |
| 3.7V LiPo 2000mAh | Wearable battery | 1 | $12.00 | $12.00 | Optional |
| 830pt breadboard + jumpers | Prototyping | 1 | $10.00 | $10.00 | Required |
| Soldering iron kit | Header pins | 1 | $15.00 | $15.00 | Recommended |
| **Total** | | | | **~$142** | |

---

## Wiring — Wearable Unit

### Shared I2C bus (SDA=21, SCL=22)

```
ESP32           MAX30102        MPU-6050
------          --------        --------
3.3V    ──────► VIN             VCC
GND     ──────► GND     ──────► GND
GPIO 21 ──────► SDA     ──────► SDA
GPIO 22 ──────► SCL     ──────► SCL
```

### Battery monitoring (voltage divider → ADC)

```
LiPo (+) ──── 100kΩ ──── GPIO 35
                     |
                   100kΩ
                     |
                    GND
```

> LiPo full = 4.2V → pin sees 2.1V. LiPo dead = 3.0V → pin sees 1.5V.
> ESP32 ADC range with ATTN_11DB = 0–3.6V. No additional clamping needed.

---

## Wiring — Bedside Unit

### Shared I2C bus (SDA=21, SCL=22)

```
ESP32           MLX90614
------          --------
3.3V    ──────► VCC
GND     ──────► GND
GPIO 21 ──────► SDA
GPIO 22 ──────► SCL
```

### E-paper display (SPI2 / VSPI)

```
ESP32           Waveshare 4.2"
------          --------------
3.3V    ──────► VCC
GND     ──────► GND
GPIO 23 ──────► DIN  (MOSI)
GPIO 18 ──────► CLK  (SCK)
GPIO 5  ──────► CS
GPIO 17 ──────► DC
GPIO 16 ──────► RST
GPIO 4  ──────► BUSY
```

### Blood pressure cuff (UART2)

```
ESP32           BP module
------          ---------
5V      ──────► VIN  (most cuff modules need 5V)
GND     ──────► GND
GPIO 17 ──────► RX   (module TX)
GPIO 16 ──────► TX   (module RX)
```

> Note: GPIO 16/17 are shared with e-paper RST/DC in the default config.
> If both are used simultaneously, reassign BP UART to GPIO 25/26.

### Micro SD card (SPI)

```
ESP32           SD module
------          ---------
3.3V    ──────► VCC
GND     ──────► GND
GPIO 23 ──────► MOSI  (shared SPI bus)
GPIO 19 ──────► MISO
GPIO 18 ──────► SCK   (shared SPI bus)
GPIO 5  ──────► CS    (share with e-paper or use GPIO 13)
```

---

## I2C Address Map

| Device | Default I2C Address |
|---|---|
| MAX30102 | 0x57 |
| MLX90614 | 0x5A |
| MPU-6050 | 0x68 |
| SSD1306 OLED (if used) | 0x3C |

All four devices can share a single I2C bus without conflict.

---

## Recommended enclosures

*(STL files coming — see [`hardware/enclosures/`](enclosures/))*

- **Wearable:** wrist strap with velcro, 60×40×18mm pocket for ESP32 + MAX30102 + LiPo
- **Bedside:** tabletop stand, 120×90×40mm, e-paper face-up, USB-C entry at rear

---

## Power budget (wearable unit)

| Component | Current draw |
|---|---|
| ESP32 (active, BLE) | ~160mA |
| MAX30102 (active) | ~1.2mA |
| MPU-6050 (active) | ~3.9mA |
| **Total active** | **~165mA** |
| 2000mAh LiPo | **~12 hours runtime** |

Deep sleep (ESP32 + sensors off, BLE inactive): ~10µA. Not used in current firmware — planned for v0.3.
