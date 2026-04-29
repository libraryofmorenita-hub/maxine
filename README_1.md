# Maxine — Open Patient Monitoring

**Open-source bedside vital signs monitor for research, education, and personal use.**

> ⚠️ **Not a medical device.** Maxine has not been cleared by the FDA and is not intended for clinical diagnosis, treatment, or monitoring in any medical setting. All readings are for personal awareness and research purposes only. Always consult a licensed medical professional for health decisions.

---

## What is Maxine?

Maxine is a wireless, modular, bedside patient monitoring system built on the ESP32 microcontroller and MicroPython. It monitors heart rate, SpO₂, temperature, blood pressure, and respiratory rate — displaying them on a low-power e-paper screen and streaming them via Bluetooth LE.

It began as a clinical question: after building a voice-activated hospital bed control system for quadriplegic patients in Puerto Rico (sponsored by [Volunteers for Medical Engineering](https://vme.org)), we asked — *what comes after the bed?* Maxine is the answer we're still building.

**"Maxine" is the trigger word the original VME bed listens for. We carried the name forward.**

---

## Architecture

Maxine is a two-unit system:

```
┌─────────────────────────┐        BLE        ┌─────────────────────────┐
│     Wearable unit       │ ◄───────────────► │     Bedside unit        │
│  (patient-worn)         │                   │  (mains-powered)        │
│                         │                   │                         │
│  MAX30102  HR + SpO₂    │                   │  MLX90614  Temperature  │
│  MPU-6050  Respiration  │                   │  BP cuff   Blood press. │
│  LiPo battery           │                   │  E-paper display        │
│  ESP32-WROOM-32E        │                   │  SD card logging        │
│                         │                   │  ESP32-WROOM-32E        │
└─────────────────────────┘                   └─────────────────────────┘
```

---

## Hardware — Bill of Materials (~$120 total)

| Component | Part | Cost |
|---|---|---|
| ESP32-WROOM-32E (×2) | SDATEKIT dev board | ~$14 |
| MAX30102 pulse oximeter | KOOBOOK 2-pack | ~$10 |
| MLX90614 IR temp sensor | GY-906 | ~$8 |
| MPU-6050 IMU | GY-521 3-pack | ~$9 |
| Blood pressure cuff (UART) | Oscillometric module | ~$25–40 |
| Waveshare 4.2" e-paper | EPD 4.2 V2 | ~$18 |
| Micro SD card module | SPI 3.3V | ~$7 |
| 32GB micro SD card | Class 10 | ~$8 |
| 5V 2A USB-C power supply | Wall adapter | ~$8 |
| 3.7V LiPo 2000mAh | JST connector | ~$12 (optional) |
| Breadboard + jumper kit | 830pt | ~$10 |

See [`hardware/BOM.md`](hardware/BOM.md) for full details, wiring diagrams, and pin assignments.

---

## Firmware Structure

```
firmware/
├── shared/               # Copied to BOTH ESP32 units
│   ├── base.py           # BaseSensor abstract class
│   ├── sensor_manager.py # SensorManager: register, boot, tick, dispatch
│   └── ble_protocol.py   # Shared BLE UUIDs + packet encoding
│
├── wearable/             # Flashed to the patient-worn ESP32
│   ├── main.py           # Entry point: sensor bridge + BLE peripheral
│   ├── ble_peripheral.py # GATT server, advertises as "Maxine-W"
│   └── sensors/
│       ├── heart_rate.py # MAX30102 driver (HR + SpO₂)
│       ├── temperature.py# MLX90614 driver (IR non-contact)
│       └── respiration.py# MPU-6050 / ADC strain gauge driver
│
└── bedside/              # Flashed to the bedside ESP32
    ├── main.py           # Entry point: BLE central + display + logging
    ├── blood_pressure.py # Oscillometric UART cuff driver
    ├── ble/
    │   └── ble_central.py# Scans, connects, subscribes to wearable
    └── display/
        └── epaper.py     # Waveshare 4.2" vitals dashboard driver
```

---

## Getting Started

### 1. Flash MicroPython

Download the ESP32 MicroPython firmware from [micropython.org](https://micropython.org/download/ESP32_GENERIC/) and flash both boards:

```bash
pip install esptool
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash -z 0x1000 ESP32_GENERIC.bin
```

### 2. Install aioble (BLE library)

Connect each ESP32 to WiFi and run in the MicroPython REPL:

```python
import mip
mip.install("aioble")
```

### 3. Upload firmware files

Use [mpremote](https://docs.micropython.org/en/latest/reference/mpremote.html) or [Thonny IDE](https://thonny.org) to upload files.

**Wearable unit:**
```bash
mpremote connect /dev/ttyUSB0 cp firmware/shared/base.py :base.py
mpremote connect /dev/ttyUSB0 cp firmware/shared/sensor_manager.py :sensor_manager.py
mpremote connect /dev/ttyUSB0 cp firmware/shared/ble_protocol.py :ble_protocol.py
mpremote connect /dev/ttyUSB0 cp -r firmware/wearable/ :/
```

**Bedside unit:**
```bash
mpremote connect /dev/ttyUSB1 cp firmware/shared/base.py :base.py
mpremote connect /dev/ttyUSB1 cp firmware/shared/sensor_manager.py :sensor_manager.py
mpremote connect /dev/ttyUSB1 cp firmware/shared/ble_protocol.py :ble_protocol.py
mpremote connect /dev/ttyUSB1 cp -r firmware/bedside/ :/
```

### 4. Install e-paper display driver

Download `epaper4in2.py` from [mcauser/micropython-waveshare-epaper](https://github.com/mcauser/micropython-waveshare-epaper) and upload it to the bedside ESP32.

### 5. Wire up sensors

See [`hardware/WIRING.md`](hardware/WIRING.md) for full pin-by-pin diagrams.

**Quick reference — shared I2C bus (both sensors):**
| Signal | ESP32 GPIO |
|---|---|
| SDA | 21 |
| SCL | 22 |

**E-paper (SPI):**
| Signal | ESP32 GPIO |
|---|---|
| MOSI | 23 |
| SCK | 18 |
| CS | 5 |
| DC | 17 |
| RST | 16 |
| BUSY | 4 |

---

## Website & Research Dashboard

The `web/` directory contains the public-facing project site and the internal research dashboard. Both are static HTML — no build step required.

To host on GitHub Pages: enable Pages in your repository settings and set the source to the `web/` folder (or copy files to root).

Visit the live site: **[your-username.github.io/maxine](https://github.com)**

---

## License

This project is licensed under **Creative Commons Attribution 4.0 International (CC BY 4.0)**.

You are free to:
- **Share** — copy and redistribute the material in any medium or format
- **Adapt** — remix, transform, and build upon the material for any purpose

Under the following terms:
- **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made.

See [`LICENSE`](LICENSE) for full terms.

---

## Acknowledgements

- **Dr. Mauricio Lizama** — clinical partner, Puerto Rico
- **Volunteers for Medical Engineering (VME)** — project sponsor
- **Loyola University** — Engineering Design Project (EG 497/498)
- **Team:** Amelia Arabe, Alex Kranov, Madison Rolle, Chris Sabins

---

## Contributing

We welcome contributions from engineers, researchers, educators, and anyone who believes technology should serve human dignity. See [`CONTRIBUTING.md`](CONTRIBUTING.md) to get started.
