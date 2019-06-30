# Case Companion (Flutter)

This is the Flutter app for the Case Companion, an open-source instrument case monitor.\
The ESP32 code, which only contains very basic functionality for now, can be found [here](https://github.com/mattang687/case-companion-esp.git).

## Introduction
As a violist whose instrument has cracked in the dry cold of winter, I'm very familiar with the danger the weather poses to musical instruments. Many solutions exist to combat unfriendly weather, like Dampits, humidifiers, covers, and expensive cases, but there's very little useful evidence of their effectiveness, since everyone's setup is different. The Case Companion is my solution to this problem. It consists of this app and a [BLE-enabled ESP32](https://github.com/mattang687/case-companion-esp.git), and it allows musicians to record and view the temperature and humidity in their case over time. This project is still a work in progress, but it should be done by the end of the summer.

## Core Features
- [x] Scan for and connect to nearby Bluetooth Low Energy (BLE) devices
- [x] Read and display temperature, humidity, and battery level from a compatible BLE device
- [ ] Store temperature and humidity data locally
- [ ] Graph temperature and humidity over different periods of time

## How it Works
### Reading Data
The app allows you to scan for and connect to nearby BLE devices. If you connect to a compatible device, it will allow you to read the sensor data from the device.\
The ESP32 I'm using exposes a Battery service containing a Battery Level characteristic, and an Environmnetal Sensing service containing Temperature and Humidity characteristics. These [services](https://www.bluetooth.com/specifications/gatt/services/) and [characteristics](https://www.bluetooth.com/specifications/gatt/characteristics/) use the 16-bit UUIDs defined by Bluetooth. Any BLE device with the same service/characteristic setup can be read by this app.\
I'm using the [flutter_blue](https://pub.dev/packages/flutter_blue) api to manage scanning for, connecting to, and reading from BLE devices.

### Storing and Graphing Data
Data is stored in an SQLite database, which consists of a single table containing the time, temperature, and humidity for each entry. Interfacing with the database is done with the help of [sqflite](https://pub.dev/packages/sqflite), and graphing will be implemetned with [charts_flutter](https://pub.dev/packages/charts_flutter). This part of the app is currently under development, and the readme will be updated accordingly.

### Data Transfer
I haven't started work on this part of the app yet, but it will likely involve a custom service/characteristic and the manipulation of the characteristic over time on the ESP32's side, as well as the notification of the app from the ESP32. The app may then subscribe to the stream of notifications from the ESP32 to read and recombine the data as needed. I will update the readme as I begin work on this.

## Todo
- [x] Connected device should show up in scan results if the user starts a 
- [x] Data should appear to update all at oncescan while connected to a device.
- [x] Settings page (settings saved via shared preferences)
- [ ] Store sampled data in a SQLite database
- [ ] Graph data on home screen
- [ ] Data transfer for values stored by the ESP32 while not connected
- [ ] Automatically connect to the last used device
- [ ] Support for multiple devices
- [ ] Improve aesthetic experience