import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import './models/transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './widgets/chart.dart';

void main() {
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Expenses',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple[900],
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
          title: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
          button: TextStyle(
            color: Colors.white
          )
        )
      ),
      home: ExpenseMain(),
    );
  }
}

class ExpenseMain extends StatefulWidget {
  @override
  _ExpenseMainState createState() => _ExpenseMainState();
}

class _ExpenseMainState extends State<ExpenseMain> {
  final List<Transaction> _userTransactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((transaction) {
      return transaction.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  Widget _buildAppBar() {
    return Platform.isIOS ? CupertinoNavigationBar(
      middle: const Text(
        'Expenses',
        style: TextStyle(
          color: Colors.white
        )
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTransaction(context)
          )
        ]
      ),
      backgroundColor: Colors.deepPurple[900],
      actionsForegroundColor: Colors.white
    ) : AppBar(
      title: const Text('Expenses'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context)
        )
      ]
    );
  }

  List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery, double appBarHeight, Widget transactionListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.title
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) => setState(() => _showChart = val)
          )
        ]
      ),
      _showChart ? Container(
        height: (mediaQuery.size.height - appBarHeight - mediaQuery.padding.top) * 0.7,
        child: Chart(_recentTransactions)
      ) : transactionListWidget
    ];
  }
  
  List<Widget> _buildPortraitContent(MediaQueryData mediaQuery, double appBarHeight, Widget transactionListWidget) {
    return [
      Container(
        height: (mediaQuery.size.height - appBarHeight - mediaQuery.padding.top) * 0.3,
        child: Chart(_recentTransactions)
      ),
      transactionListWidget
    ];
  }

  void _addNewTransaction(String newTitle, double newAmount, DateTime chosenDate) {
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: newTitle,
      amount: newAmount,
      date: chosenDate
    );
    
    setState(() => _userTransactions.add(newTransaction));
  }

  void _deleteTransaction(String id) {
    setState(() => _userTransactions.removeWhere((transaction) => transaction.id == id));
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque
        );
      }
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = _buildAppBar();
    final transactionListWidget = Container(
      height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) * 0.75,
      child: TransactionList(_userTransactions, _deleteTransaction)
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (isLandscape) ..._buildLandscapeContent(mediaQuery, appBar.preferredSize.height, transactionListWidget),
            if (!isLandscape) ..._buildPortraitContent(mediaQuery, appBar.preferredSize.height, transactionListWidget),
          ]
        )
      )
    );

    return Platform.isIOS ? CupertinoPageScaffold(
      navigationBar: appBar,
      child: pageBody
    ) : Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS ? Container() : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(ctx)
      )
    );
  }
}
