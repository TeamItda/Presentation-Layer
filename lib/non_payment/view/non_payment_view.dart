import "package:flutter/material.dart";
class NonPaymentView extends StatelessWidget {
  final String hospitalId;
  const NonPaymentView({super.key, required this.hospitalId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("NonPayment: $hospitalId")));
  }
}
