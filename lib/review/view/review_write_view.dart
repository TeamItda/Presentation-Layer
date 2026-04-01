import "package:flutter/material.dart";
class ReviewWriteView extends StatelessWidget {
  final String facilityId;
  const ReviewWriteView({super.key, required this.facilityId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Review: $facilityId")));
  }
}
