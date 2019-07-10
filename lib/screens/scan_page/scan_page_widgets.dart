import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:provider/provider.dart';

// displays current device and allows the user to disconnect and reconnect
class ConnectedDeviceTile extends StatelessWidget {
  const ConnectedDeviceTile({this.onConnectTap, this.onDisconnectTap});
  final Function(BluetoothDevice d) onConnectTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    return ListTile(
      // uses previous device to allow the user to reconnect after disconnecting
      // without having to scan again
      title: new _ConnectedDeviceTitle(
        context: context,
        device: inheritedBluetooth.previousDevice,
      ),
      trailing: new _ConnectedDeviceButton(
        onDisconnectTap: onDisconnectTap,
        onConnectTap: onConnectTap,
        inheritedBluetooth: inheritedBluetooth,
        device: inheritedBluetooth.previousDevice,
      ),
    );
  }
}

class _ConnectedDeviceButton extends StatelessWidget {
  const _ConnectedDeviceButton({
    Key key,
    @required this.onDisconnectTap,
    @required this.onConnectTap,
    @required this.inheritedBluetooth,
    @required this.device,
  }) : super(key: key);

  final Function onDisconnectTap;
  final Function(BluetoothDevice d) onConnectTap;
  final InheritedBluetooth inheritedBluetooth;
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    if (inheritedBluetooth.isConnected()) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () {
          onDisconnectTap();
        },
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: () {
          onConnectTap(device);
        },
      );
    }
  }
}

class _ConnectedDeviceTitle extends StatelessWidget {
  const _ConnectedDeviceTitle({
    Key key,
    @required this.context,
    @required this.device,
  }) : super(key: key);

  final BuildContext context;
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(device.name),
          Text(
            device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      );
    } else {
      return Text(device.id.toString());
    }
  }
}

// displays a ble device and allows the user to connect, if connectable
class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    this.result,
    this.onConnectTap,
    this.onDisconnectTap,
  });
  final ScanResult result;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    return ListTile(
        title: new _ScanResultTitle(result: result, context: context),
        trailing: new _ScanResultButton(
            result: result,
            onDisconnectTap: onDisconnectTap,
            onConnectTap: onConnectTap,
            inheritedBluetooth: inheritedBluetooth));
  }
}

class _ScanResultButton extends StatelessWidget {
  const _ScanResultButton({
    Key key,
    @required this.result,
    @required this.onDisconnectTap,
    @required this.onConnectTap,
    @required this.inheritedBluetooth,
  }) : super(key: key);

  final ScanResult result;
  final Function onDisconnectTap;
  final Function onConnectTap;
  final InheritedBluetooth inheritedBluetooth;

  @override
  Widget build(BuildContext context) {
    if (inheritedBluetooth.device != null && result.device.id == inheritedBluetooth.device.id) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: () => onDisconnectTap(),
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color:
            (result.advertisementData.connectable) ? Colors.black : Colors.grey,
        textColor: Colors.white,
        onPressed: () =>
            (result.advertisementData.connectable) ? onConnectTap() : null,
      );
    }
  }
}

class ScanResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (c, snapshot) {
        if (snapshot.data.length == 0) return PullToScanWidget();
        return Column(
            children: snapshot.data
                .map((r) => ScanResultTile(
                      result: r,
                      onConnectTap: () => inheritedBluetooth.connect(r.device),
                      onDisconnectTap: () => inheritedBluetooth.disconnect(),
                    ))
                .toList());
      },
    );
  }
}

class _ScanResultTitle extends StatelessWidget {
  const _ScanResultTitle({
    Key key,
    @required this.result,
    @required this.context,
  }) : super(key: key);

  final ScanResult result;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(result.device.name),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }
}

// text that shows when there are no scan results
class PullToScanWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 5,
          ),
        ),
        Text(
          'Pull to Scan',
          style: TextStyle(color: Colors.grey),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
      ],
    );
  }
}
