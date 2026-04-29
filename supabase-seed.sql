-- ─────────────────────────────────────────────────────────────────────────────
-- MAXINE Research Dashboard — seed data
-- Run AFTER supabase-schema.sql
-- ─────────────────────────────────────────────────────────────────────────────

-- Notes
insert into public.maxine_notes (tag, title, body, note_date) values
  ('finding', 'MAX30102 accuracy within ±3bpm',
   'Tested the MAX30102 sensor against a commercial pulse oximeter. Readings are within ±3bpm at rest. Under motion the error increases to ±8bpm. Need to improve the peak detection algorithm — the current zero-crossing approach is sensitive to noise.',
   '2025-04-18'),
  ('issue', 'E-paper ghosting after 8 partial refreshes',
   'The Waveshare 4.2" display shows visible ghosting after approximately 8 consecutive partial refreshes. Currently forcing a full refresh every 10 draws. May need to reduce to every 6. Full refresh takes 4.1s on average — acceptable for vitals display.',
   '2025-04-19'),
  ('finding', 'BLE reconnect time < 3s after sleep',
   'After the wearable unit enters deep sleep and wakes, BLE reconnection to the bedside central takes an average of 2.8 seconds. This is acceptable for our use case. aioble scan timeout set to 10s — never hit in testing.',
   '2025-04-20'),
  ('idea', 'Haptic feedback on wearable for alerts',
   'Idea: add a small haptic vibration motor to the wearable module so the patient gets tactile feedback when an alert fires — especially important for patients with limited vision or hearing. Small 3V coin vibration motor would fit on the wrist PCB.',
   '2025-04-21');

-- Hardware components
insert into public.maxine_hardware (name, part_no, qty, unit_cost, status, notes, sort_order) values
  ('ESP32-WROOM-32E (bedside)',    'SDATEKIT-32E',   1, 7.00,  'integrated', 'Bedside main MCU',                         0),
  ('ESP32-WROOM-32E (wearable)',   'SDATEKIT-32E',   1, 7.00,  'integrated', 'Wearable BLE peripheral',                  1),
  ('MAX30102 pulse oximeter',      'KOOBOOK-30102',  2, 5.00,  'testing',    'HR accuracy ±3bpm in tests',               2),
  ('MLX90614 IR temp sensor',      'GY-906-BAA',     1, 8.00,  'integrated', 'Non-contact, 0.5°C accuracy',              3),
  ('GY-521 MPU-6050 IMU',          'GY-521-3PK',     3, 3.00,  'integrated', 'Respiration via chest IMU',                4),
  ('BP cuff UART module',          null,             1, 32.00, 'ordered',    'Awaiting delivery — driver ready',         5),
  ('Waveshare 4.2" e-paper',       'WS-EPD-4.2',     1, 18.00, 'testing',    'Partial refresh ghosting under review',    6),
  ('Micro SD card module',         'DIYables-SD',    1, 4.00,  'integrated', 'SPI · FAT32 · logging ready',              7),
  ('32GB micro SD card',           'SanDisk-32C10',  1, 8.00,  'received',   'FAT32 formatted',                          8),
  ('3.7V LiPo 2000mAh (wearable)','JST-LIPO-2K',    1, 12.00, 'ordered',    'Battery monitoring code ready',            9),
  ('5V 2A USB-C power supply',     null,             1, 8.00,  'received',   'Bedside unit power',                      10),
  ('830pt breadboard + jumper kit','ELEGOO-JW',      1, 10.00, 'integrated', 'Prototype wiring',                        11),
  ('Soldering iron kit',           null,             1, 15.00, 'received',   'Header pins on sensors',                  12);

-- Changelog
insert into public.maxine_changelog (version, title, entry_date, type, changes, sort_order) values
  ('v0.2.0', 'BLE two-unit architecture + e-paper display', '2025-04-21', 'arch',
   '["Split into wearable peripheral + bedside central architecture","Added aioble BLE stack: ble_peripheral.py + ble_central.py","Defined shared BLE protocol in shared/ble_protocol.py (UUIDs + struct encoding)","Replaced OLED with Waveshare 4.2\" e-paper (epaper.py)","Bedside main.py: async gather of wired sensors + BLE + display + logging","Wearable main.py: sensor bridge + battery monitoring + BLE advertising"]',
   0),
  ('v0.1.1', 'Regulatory review — Path 3 decision', '2025-04-20', 'doc',
   '["Documented FDA Class II classification implications for multi-parameter vitals monitor","HIPAA analysis: device manufacturer not a covered entity unless data shared with clinical systems","Confirmed Path 3: open source for research, education, personal use only","Added NOT FOR MEDICAL USE disclaimers to all public-facing materials"]',
   1),
  ('v0.1.0', 'Initial sensor driver layer', '2025-04-18', 'feat',
   '["BaseSensor abstract class with safe_read(), initialize(), healthy() contract","HeartRateSensor: MAX30102 FIFO drain, peak detection, SpO2 Beer-Lambert","TemperatureSensor: MLX90614 non-contact IR, shared I2C bus injection","BloodPressureSensor: oscillometric UART cuff, KT-80x packet parser","RespirationSensor: MPU-6050 IMU or ADC strain gauge, zero-crossing rate","SensorManager: register, boot, tick, dispatch pattern"]',
   2),
  ('v0.0.1', 'Project scaffolded from VME hospital bed work', '2025-04-15', 'feat',
   '["ESP32-WROOM-32E selected as MCU (MicroPython, BLE, WiFi built-in)","Sensor architecture designed: one driver per sensor, BaseSensor contract","Hardware BOM finalized: <$120 total","Project named Maxine after VME bed trigger word"]',
   3);
