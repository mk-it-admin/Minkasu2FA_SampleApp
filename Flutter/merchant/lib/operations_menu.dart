import 'package:flutter/material.dart';
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_flutter_plugin.dart';
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models.dart';

class OperationsScreen extends StatefulWidget {
  final String merchantCustomerId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const OperationsScreen({
    super.key,
    required this.merchantCustomerId,
    required this.scaffoldKey,
  });

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  /// Initializing the Minkasu2FAFlutterPlugin instance
  final _minkasu2FA = Minkasu2FAFlutterPlugin();
  final Color backgroundColor = const Color.fromRGBO(78, 164, 109, 1);

  List<Minkasu2FAOperationType> operations = [];

  void fetchOperations() async {
    /// Fetching available Minkasu2FA Operations
    ///
    /// Returns a list of Minkasu2FAOperationType
    try {
      final ops = await _minkasu2FA.getAvailableMinkasu2FAOperations();
      setState(() {
        operations = ops;
      });
    } catch (_) {}
  }

  void performOperation(Minkasu2FAOperationType operation) async {
    final merchantCustomerId = widget.merchantCustomerId;

    /// Performing a Minkasu2FA Operation
    ///
    /// Please make sure the merchantCustomerId is a unique id associated with the
    /// currently logged in user, and is the same id used in the payment flow.
    /// The theme settings is for iOS only. Please update the `colors.xml` file for android theme settings
    try {
      final result = await _minkasu2FA.performMinkasu2FAOperation(
        operation,
        merchantCustomerId,
        const Minkasu2FACustomTheme(
          navigationBarColor: Colors.red,
          navigationBarTextColor: Colors.green,
          //Use this to set a separate color theme for Dark mode
          darkModeNavigationBarColor: Colors.yellow,
          darkModeNavigationBarTextColor: Colors.green,
          supportDarkMode: true,
        ),
      );
    } catch (_) {}
  }

  String getDisplayNameFor(Minkasu2FAOperationType operation) {
    switch (operation) {
      case Minkasu2FAOperationType.changePayPin:
        return "Change PayPin";
      case Minkasu2FAOperationType.enableBiometry:
        return "Enable Biometry";
      case Minkasu2FAOperationType.disableBiometry:
        return "Disable Biometry";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOperations();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: const Center(
            child: Text(
              'Minkasu Operations',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: operations.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(
                  getDisplayNameFor(operations[i]),
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  performOperation(operations[i]);
                  if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                    widget.scaffoldKey.currentState!.closeDrawer();
                  }
                  fetchOperations();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
