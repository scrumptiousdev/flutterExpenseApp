import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './adaptive_button.dart';

class NewTransaction extends StatefulWidget {
  final Function handleNewTransaction;

  NewTransaction(this.handleNewTransaction);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate;

  void _submitTransaction() {
    if (_amountController.text.isEmpty) return;

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) return;

    widget.handleNewTransaction(enteredTitle, enteredAmount, _selectedDate);
    Navigator.of(context).pop();
  }

  void _displayDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now()
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 40
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: _titleController,
                onSubmitted: (_) => _submitTransaction()
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Amount'),
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _submitTransaction()
              ),
              Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(_selectedDate == null ? 'Date' : DateFormat.yMMMd().format(_selectedDate))
                    ),
                    AdaptiveFlatButton('Choose Date', _displayDatePicker)
                  ],
                ),
              ),
              SizedBox(height: 15),
              RaisedButton(
                child: Text('Add Transaction'),
                textColor: Theme.of(context).textTheme.button.color,
                color: Theme.of(context).primaryColor,
                onPressed: _submitTransaction
              )
            ]
          )
        )
      ),
    );
  }
}