# Contributing to Maxine

Thank you for your interest in contributing. Maxine is built on the belief that good technology is made by people who care — engineers, researchers, educators, caregivers, and students alike. All backgrounds are welcome here.

---

## Ways to contribute

### Hardware
- Test sensors and document real-world accuracy findings
- Design enclosures (3D printable STL files welcome)
- Improve wiring diagrams or add new sensor modules

### Firmware
- Add new sensor drivers (must extend `BaseSensor`)
- Improve the heart rate peak detection algorithm
- Build the alert engine (threshold rules → WiFi notifications)
- Optimize power consumption on the wearable unit

### Documentation
- Improve setup guides for different operating systems
- Write tutorials for students and educators
- Translate documentation into Spanish (important for Puerto Rico community)

### Web / Dashboard
- Improve the research dashboard UI
- Build the 3D model viewer (Three.js)
- Add real BLE Web API integration for live browser readings

---

## Ground rules

1. **Be kind.** This project exists to help people. That spirit extends to how we treat each other.
2. **Be honest about limitations.** Never overstate what Maxine can do clinically.
3. **Keep the disclaimer.** Every user-facing interface must carry the NOT A MEDICAL DEVICE disclaimer.
4. **Document your sensor work.** If you add or test hardware, note your accuracy findings in `docs/findings/`.

---

## How to submit changes

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature-name`
3. Make your changes and commit with a clear message
4. Push and open a Pull Request with a description of what you changed and why
5. A maintainer will review within a few days

---

## Sensor driver contract

New sensor drivers must extend `BaseSensor` from `firmware/shared/base.py` and implement:

```python
def setup(self) -> None:     # hardware init, raise SensorError on failure
def read(self) -> Reading:   # return a Reading namedtuple or None
def healthy(self) -> bool:   # quick self-check
```

Set `self.name` and `self.poll_interval_ms` as class attributes.

---

## Questions?

Open an issue with the `question` label. No question is too basic.
