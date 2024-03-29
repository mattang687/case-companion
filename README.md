# Case Companion
An instrument case monitoring system created with Flutter and Arduino

![screenshot](/images/case-companion-screenshot.jpg)

## Table of Contents
* [Introduction](#introduction)
* [Key Features](#key-features)
* [Technologies](#technologies)
* [Installation](#installation)
* [How it Works](#how-it-works)

## Introduction
Bad weather can be pretty dangerous to musical instruments (my viola cracked in the winter a few years ago). Many solutions exist to combat unfriendly weather, like Dampits, humidifiers, covers, and expensive cases, but there's very little useful evidence of their effectiveness, since everyone's setup is so different. The Case Companion is my solution to this problem. It consists of this app and a [BLE-enabled ESP32](https://github.com/mattang687/case-companion-esp.git), and it allows musicians to record and view the temperature and humidity in their case over time. This was my first time using Flutter, and I've learned so much in the month I've spent with it. I hope this will be useful to someone, if not as a product itself then as a code example for flutter_blue and charts_flutter, since I couldn't find many examples for them as I was making this. This is something I will be using daily, so I'll be adding to it in my free time moving forward, though most of my issues with the system at the moment lie more on the hardware side.

## Key Features
* Scan for and connect to nearby Bluetooth Low Energy (BLE) devices
* Read and display temperature and humidity from a compatible BLE device
* Store temperature and humidity data locally
* Graph temperature and humidity over time

## Technologies
* Flutter 1.7
    * flutter_blue 0.6.0
    * sqflite 1.1.6
    * charts_flutter 0.6.0
    * provider 3.0.0

## Installation
Note: I don't own a Mac or an iPhone, so I haven't been able to test this on iOS. All APIs used here are cross-platform, so it should work, but I am not currently able to test it. 
To install the app, you will need Flutter. Clone this repo, connect your device and run
```
flutter clean
flutter build apk
flutter install
```
for Android, or
```
flutter clean
flutter build ios
flutter install
```
for iOS.

The code and installation instructions for the ESP32 can be found [here](https://github.com/mattang687/case-companion-esp.git).

## How it Works
### Reading Data
The app allows you to scan for and connect to nearby BLE devices. If you connect to a compatible device, it will allow you to read the sensor data from the device.\
The ESP32 I'm using exposes an Environmnetal Sensing service containing Temperature and Humidity characteristics. The [service](https://www.bluetooth.com/specifications/gatt/services/) and [characteristics](https://www.bluetooth.com/specifications/gatt/characteristics/) use the 16-bit UUIDs defined by Bluetooth. Any BLE device with the same service/characteristic setup can be read by this app.\
I'm using the [flutter_blue](https://pub.dev/packages/flutter_blue) api to manage scanning for, connecting to, and reading from BLE devices.\
All interactions with BLE and flutter_blue are wrapped in the InheritedBluetooth class and provided to the whole app, which makes upgrading flutter_blue through breaking changes simple. Since flutter_blue is still in alpha and rapidly changing, this has been quite useful and saved me a lot of time.

### Storing and Graphing Data
Data is stored in an SQLite database, which consists of a single table containing the time, temperature, and humidity for each entry. Interfacing with the database is done with the help of [sqflite](https://pub.dev/packages/sqflite), and [charts_flutter](https://pub.dev/packages/charts_flutter) is used to to create the graph. The SQL operations run by the app allow the user to insert an entry (this happens automatically when the data is refreshed), clear entries before a specified date, and query all rows. I'm currently working on allowing the user to select a range to query and saving that setting persistently. Similarly to Bluetooth, all interactions with the database are wrapped in a DatabaseHelper. To allow data to be graphed, the DatabaseHelper maintains a list of data points, which is updated when the user queries the database. Then, the chart accesses this list and parses it into a temperature and humidity series, which it can then graph.

## Future Plans
* Allow the user to set the time interval displayed on the graph
* Show data for the selected point on the graph
* Automatically connect to the last used device when the app is launched