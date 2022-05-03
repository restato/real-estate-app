import 'package:flutter/material.dart';
import 'package:app/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(transaction.aptName),
            subtitle: Text("${transaction.amount}만원"),
            trailing: Text(transaction.year),
          )
        ],
      ),
    );
  }
}
