import 'package:flutter/material.dart';
import 'package:merchant/operations_menu.dart';
import 'package:merchant/payment_screen.dart';

void main() {
  runApp(const MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Color backgroundColor = const Color.fromRGBO(78, 164, 109, 1);
  final Color textColor = const Color.fromRGBO(255, 255, 255, 1);

  void netBankingBtnPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(
          type: "NETBANKING",
        ),
      ),
    );
  }

  void creditBtnPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(
          type: "CREDITCARD",
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Minkasu2FA Sample App"),
        iconTheme: IconThemeData(color: textColor),
        backgroundColor: backgroundColor,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawer: Drawer(
        child: OperationsScreen(
          merchantCustomerId: "<merchant_customer_id>",
          scaffoldKey: scaffoldKey,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: netBankingBtnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text("Net Banking"),
            ),
            ElevatedButton(
              onPressed: creditBtnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text("Credit/Debit"),
            ),
          ],
        ),
      ),
    );
  }
}
