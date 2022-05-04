import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:app/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text(transaction.aptName,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500)),
                  Text("${transaction.amount}만원",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(transaction.year, style: TextStyle(color: Colors.grey[500])),
            ])
          ])
        ],
      ),
    );
  }
}
