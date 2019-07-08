# Case Companion (Flutter)

This is the Flutter app for the Case Companion, an open-source instrument case monitor.\
The ESP32 code, which only contains very basic functionality for now, can be found [here](https://github.com/mattang687/case-companion-esp.git).

## Introduction
Bad weather can be pretty dangerous to musical instruments (my viola cracked in the winter a few years ago). Many solutions exist to combat unfriendly weather, like Dampits, humidifiers, covers, and expensive cases, but there's very little useful evidence of their effectiveness, since everyone's setup is different. The Case Companion is my solution to this problem. It consists of this app and a [BLE-enabled ESP32](https://github.com/mattang687/case-companion-esp.git), and it allows musicians to record and view the temperature and humidity in their case over time.

## Core Features
- [x] Scan for and connect to nearby Bluetooth Low Energy (BLE) devices
- [x] Read and display temperature, humidity, and battery level from a compatible BLE device
- [x] Store temperature and humidity data locally
- [x] Graph temperature and humidity over time

## How it Works
### Reading Data
The app allows you to scan for and connect to nearby BLE devices. If you connect to a compatible device, it will allow you to read the sensor data from the device.\
The ESP32 I'm using exposes a Battery service containing a Battery Level characteristic, and an Environmnetal Sensing service containing Temperature and Humidity characteristics. These [services](https://www.bluetooth.com/specifications/gatt/services/) and [characteristics](https://www.bluetooth.com/specifications/gatt/characteristics/) use the 16-bit UUIDs defined by Bluetooth. Any BLE device with the same service/characteristic setup can be read by this app.\
I'm using the [flutter_blue](https://pub.dev/packages/flutter_blue) api to manage scanning for, connecting to, and reading from BLE devices.

### Storing and Graphing Data
Data is stored in an SQLite database, which consists of a single table containing the time, temperature, and humidity for each entry. Interfacing with the database is done with the help of [sqflite](https://pub.dev/packages/sqflite), and [charts_flutter](https://pub.dev/packages/charts_flutter) is used to to create the graph. The SQL operations run by the app allow the user to insert an entry (this happens automatically when the data is refreshed), clear all entries, clear entries before a specified date, and query all rows. To graph the data, a DatabaseHelper wraps all of these operations and maintains a list of entries, which is accessed by the graph widget. 

## Todo
- [x] Connected device should show up in scan results if the user starts a 
- [x] Data should appear to update all at oncescan while connected to a device.
- [x] Settings page (settings saved via shared preferences)
- [x] Store sampled data in a SQLite database
- [x] Graph data on home screen
- [ ] Tapping an entry on the graph selects it and displays data in place of current data
- [ ] Automatically connect to the last used device
- [ ] Support for multiple devices
- [ ] Improve aesthetic experience