# monbaby_sdk
This is an example of how to connect to Monbaby button (monbaby.com for more info) and get data from the accelerometer.
It consists of several classes:
* BleConnectionHelper
* BleScanHelper
* ConnectActivity
* ScanActivity

# BLE documentation links
Link with examples:
http://processors.wiki.ti.com/index.php/CC254X_Smart_Phone_Examples

IOS demo, there is no for android but iOS uses same logic
http://processors.wiki.ti.com/index.php/Category:IPhone4SBLEDemo

Accelerometer data packing and settings
http://cache.freescale.com/files/sensors/doc/app_note/AN4076.pdf

Usuful forums:
e2e.ti.com

# UUID listings for services and descriptors

For a full list please visit: https://docs.google.com/spreadsheets/d/1s70X4K4zBTn0KOcfKAh_yYGUy5wOYbzKIK63zFN7Evo/edit?usp=sharing

ACCELEROMETER SERVICE
UUID: 0xAA10: enable accelerometer profile
ACCELEROMETER CONFIG Characteristics: 0xAA12


ACCELEROMETER DATA14 Characteristics
UUID: 0xAA16 enable 14 bit accelerometer mode
Send 0x03 value to enable ACCELEROMETER

Service UUID: 0xAA10
Characteristic UUID: 0xAA13 “Accel Period”
Format: unsigned char (1 byte wide)
Value -  Poll period – Sample rate
2 – 100 ms – 6.25 SPS
5 – 100 ms – 6.25 SPS
9 – 100 ms – 6.25 SPS
10 – 100 ms – 6.25 SPS
11 – 110 ms – 6.25 SPS
16 – 160 ms – 6.25 SPS (this value is exact value of accelerometer data rate but skipping of samples is possible due to some other duties of Firmware)
20 – 200 ms – 5 SPS
33 – 330 ms – 3 SPS

UUID 0xBB64: Offline mode configuration.
Size/type: 1 byte, unsigned.
Bit0 (LSb) – set to ‘1’ (default) to enable offline mode when connection is lost (but not disconnected by logoff), set to ‘0’ to disable offline mode, MonBaby operates just like “old” device.
Bit1 – set to ‘1’ (default) to enable buzzer, set to ‘0’ to disable buzzer, it will never sound, LED indication only.

UUID 0xBB65: Remote control.
Size/type: 1 byte, unsigned.
Write 0x55 to enforce the device to logout.
Write 0x66 to enforce the device to hardware reset (and to logout as result).

UUID 0xBB66: Buzzer setup.
Size/type: 1 byte, unsigned.

Bits3..0 – Select first frequency number for buzzer. 16 possible selections.
Bits7..4 – Select second frequency number for buzzer. 16 possible selections.

UUID 0xBB67: RSSI.
Size/type: 1 byte, signed.
To activate RSSI readings non-zero value should be written. After this new RSSI value will be available for reads updated once per second.
To deactivate RSSI readings, 0x00 must be written. When RSSI is not used, it should be deactivated to save some power.
