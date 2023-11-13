import 'package:count_app/database/database_helper.dart';
import 'package:count_app/screens/add_record_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import your actual database helper

class DeleteRecordScreen extends StatefulWidget {
  @override
  _DeleteRecordScreenState createState() => _DeleteRecordScreenState();
}

class _DeleteRecordScreenState extends State<DeleteRecordScreen> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

//display the records
  Future<void> _loadRecords() async {
    DatabaseHelper dbHelper =
        DatabaseHelper(); // Replace with your actual database helper
    List<Map<String, dynamic>> records = await dbHelper
        .getAllRecords(); // Replace with your actual method to get records
    setState(() {
      _records = records;
    });
  }

//delete records
  Future<void> _deleteRecord(String date, int numbers) async {
    bool confirmDelete = await _showConfirmationDialog(numbers);

    if (confirmDelete) {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.deleteRecordsForDateandNumber(date, numbers);
      _loadRecords();
    }
  }

//confirm whether to delete numbers single
  Future<bool> _showConfirmationDialog(int numbers) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content:
              Text("Are you sure you want to delete the records? $numbers"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancelled
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  //appbar delete every numbers in the date
  Future<void> _showDeleteConfirmationDialog(DateTime date) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text(
              "Are you sure you want to delete all data for ${DateFormat('dd-MM-yyyy').format(date)}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancelled
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper
          .deleteRecordsForDate(DateFormat('dd-MM-yyyy').format(date));
      _loadRecords();
    }
  }

  DateTime selectedDate = DateTime.now();

  //select date to delete
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Record'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              _selectDate(); // Show confirmation dialog before deleting all data for the date
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (selectedDate != null) {
                _showDeleteConfirmationDialog(
                    selectedDate); // Show confirmation dialog before deleting all data for the selected date
              } else {
                // Show a message indicating that a date needs to be selected
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a date first'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display DataTable for existing records
                DataTable(
                  columns: [
                    DataColumn(label: Text('Number')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Delete')),
                  ],
                  rows: _records
                      .map(
                        (record) => DataRow(
                          cells: [
                            DataCell(Text(record['number'].toString())),
                            DataCell(Text(record['quantity'].toString())),
                            DataCell(Text(record['date'].toString())),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteRecord(
                                    record['date'], record['number']),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}