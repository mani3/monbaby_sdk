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

# Accelerometer Profile Details

MonBaby firmware/hardware is based on Bluetooth 4.0 and Texas Instruments SOC CC2540 with TI's BLE stack 1.4.2.2.

* The advertising interval is set to 300mS and advertising mode is set to "general discoverable", therefore advertises infinitely.
* The min and max connection intervals are 10mS and 75mS.
* Slave latency is 15.
* The connection timeout is 6 seconds.
* Address type is public.
* When initially establishing a connection, the Accelerometer notifications begins, this can be seen on the monBaby unit by the blue led blinking 10 times.
* Flag length: 0x02
* Flag type: 0x01
* Flags: 0x06 - General discoverable, BtEdr Not Supported


# UUID listings for services and descriptors

For a full list please visit: https://docs.google.com/spreadsheets/d/1s70X4K4zBTn0KOcfKAh_yYGUy5wOYbzKIK63zFN7Evo/edit?usp=sharing

| Services | Characteristics | Description |
|:---|:---|:---|
| ACCELEROMETER SERVICE<br>UUID: 0xAA10 | ACCELEROMETER CONFIG<br>UUID: 0xAA12 | Enable accelerometer profile |
|                                       | ACCELEROMETER DATA14<br>UUID: 0xAA16 | Enable 14 bit accelerometer mode<br>Send 0x03 value to enable ACCELEROMETER |
|                                       | ACCELEROMETER PERIOD<br>UUID: 0xAA13 | Format: unsigned char (1 byte wide)<br>Value -  Poll period – Sample rate<br>2 – 100 ms – 6.25 SPS<br>5 – 100 ms – 6.25 SPS<br>9 – 100 ms – 6.25 SPS<br>10 – 100 ms – 6.25 SPS<br>11 – 110 ms – 6.25 SPS<br>16 – 160 ms – 6.25 SPS (this value is exact value of accelerometer data rate but skipping of samples is possible due to some other duties of Firmware)<br>20 – 200 ms – 5 SPS<br>33 – 330 ms – 3 SPS |
| CUSTOM SERVICE<br>UUID: 66697FB0-EDBD-11E5-A837-0800200C9A66 | Offline mode configuration<br>UUID: 0xBB64 | Size/type: 1 byte, unsigned.<br>Bit0 (LSb) – set to ‘1’ (default) to enable offline mode when connection is lost (but not disconnected by logoff), set to ‘0’ to disable offline mode, MonBaby operates just like “old” device.<br>Bit1 – set to ‘1’ (default) to enable buzzer, set to ‘0’ to disable buzzer, it will never sound, LED indication only.|
|                                            | Remote control<br>UUID: 0xBB65 | Size/type: 1 byte, unsigned.<br>Write 0x55 to enforce the device to logout.<br>Write 0x66 to enforce the device to hardware reset (and to logout as result). |
|                                            | Remote control<br>UUID: 0xBB66 | Size/type: 1 byte, unsigned.<br>Bits3..0 – Select first frequency number for buzzer. 16 possible selections.<br>Bits7..4 – Select second frequency number for buzzer. 16 possible selections.|
|                                            | RSSI<br>UUID: 0xBB67 | Size/type: 1 byte, signed.<br>To activate RSSI readings non-zero value should be written. After this new RSSI value will be available for reads updated once per second.<br>To deactivate RSSI readings, 0x00 must be written. When RSSI is not used, it should be deactivated to save some power. |
