### Case Companion

This is the Flutter app for my Case Companion system.
I'm using Flutter Blue to establish a connection to a BLE-enabled ESP32 and read temperature, humidity, and battery level from it.
This is my first time using Flutter, so suggestions are very welcome!

#### Todo
* Connected device should show up in scan results if the user starts a scan while connected to a device.
* Automatically connect to the last used device
* Pretty layout for the home screen
* Data should wait until all characteristics have been read so they all load in at the same time, while remaining separate widgets
* Graph of data over time
* Data transfer for values stored by the ESP32 while not connected