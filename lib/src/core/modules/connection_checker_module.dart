import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionCheckerModule extends StatefulWidget {
  const ConnectionCheckerModule({super.key, this.child});

  final Widget? child;

  @override
  State<ConnectionCheckerModule> createState() => _ConnectionCheckerModuleState();
}

class _ConnectionCheckerModuleState extends State<ConnectionCheckerModule> {
  /// Listener for app lifecycle events.
  late final AppLifecycleListener _listener;

  /// Initializes the lifecycle listener.
  void _initializeLifeCycleListener() {
    _listener = AppLifecycleListener(onResume: _initializeSubsciption, onPause: _subscription.cancel);
  }

  /// Subscription to monitor internet status changes.
  late StreamSubscription<InternetStatus> _subscription;

  /// Initializes the internet status subscription.
  void _initializeSubsciption() {
    _subscription = InternetConnection.createInstance().onStatusChange.listen(_updateConnectionStatus);
  }

  /// A [ValueNotifier] that holds the current internet connectivity status.
  ValueNotifier<InternetStatus> isConnected = ValueNotifier<InternetStatus>(InternetStatus.disconnected);

  /// Updates the connection status.
  /// @param status The new [InternetStatus].
  void _updateConnectionStatus(InternetStatus status) => isConnected.value = status;

  @override
  void initState() {
    _initializeSubsciption();
    _initializeLifeCycleListener();
    super.initState();
  }

  @override
  void dispose() {
    /// Cancels the subscription and disposes the lifecycle listener.
    _subscription.cancel();
    _listener.dispose();

    /// Disposes the ValueNotifier.
    isConnected.dispose();

    /// Calls the superclass dispose method.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ?widget.child,
          ValueListenableBuilder<InternetStatus>(
            valueListenable: isConnected,
            builder: (context, status, child) {
              if (status == InternetStatus.disconnected) {
                return Positioned(
                  bottom: MediaQuery.viewPaddingOf(context).bottom,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 16,
                      mainAxisAlignment: .center,
                      children: [
                        const Icon(Icons.signal_wifi_off, color: Colors.white),
                        const Text(
                          'No Internet Connection',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
