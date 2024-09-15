import 'package:JHC_MIS/api/firebase_api.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/widgets/glass_morph.dart';
import 'package:JHC_MIS/widgets/text_field_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTask> {
  final TextEditingController _issueController = TextEditingController();
  String? _selectedFloor;
  String? _selectedBuilding;
  String? _selectedRoom;
  String? _selectedDevice;
  DateTime? _selectedDateTime;
  String? _selectedIssue;
  List<String> _buildings = [];
  List<String> _floors = [];
  List<String> _rooms = [];
  List<String> _devices = [];
  
  // List of common issues
  final List<String> _commonIssues = [
    'Network Issue',
    'PC Hanging',
    'Wire misplaced',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  void _loadBuildings() async {
    final bldgsSnapShot = await FirebaseFirestore.instance.collection("device_profiles").get();
    final bldgs = bldgsSnapShot.docs.map((doc) => doc['building'] as String).toSet().toList();
    setState(() {
      _buildings = bldgs;
    });
  }

  void _loadFloors(String building) async {
    final flrSnapShot = await FirebaseFirestore.instance.collection("device_profiles")
        .where('building', isEqualTo: building)
        .get();
    final flr = flrSnapShot.docs.map((doc) => doc['floor_number'] as String).toSet().toList();
    setState(() {
      _floors = flr;
      _rooms = [];
    });
  }

  void _loadRooms(String building, String floor) async {
    final roomsSnapShot = await FirebaseFirestore.instance.collection("device_profiles")
        .where('building', isEqualTo: building)
        .where('floor_number', isEqualTo: floor)
        .get();
    final rooms = roomsSnapShot.docs.map((doc) => doc['room_number'] as String).toSet().toList();
    setState(() {
      _rooms = rooms;
      _devices = [];
    });
  }

  void _loadDevices(String building, String floor, String room) async {
    final devicesSnapShot = await FirebaseFirestore.instance.collection("device_profiles")
        .where('building', isEqualTo: building)
        .where('floor_number', isEqualTo: floor)
        .where('room_number', isEqualTo: room)
        .get();
    final devices = devicesSnapShot.docs.map((doc) => doc['device_id'] as String).toSet().toList();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addTask() async {
    if (_selectedFloor == null || _selectedRoom == null || _selectedDevice == null || _selectedIssue == null || (_selectedIssue == 'Other' && _issueController.text.isEmpty) || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    try {
      // Add task to Firestore
      DocumentReference taskRef = await FirebaseFirestore.instance.collection('tasks').add({
        'building': _selectedBuilding,
        'floor_number': _selectedFloor,
        'room_number': _selectedRoom,
        'device_id': _selectedDevice,
        'issue': _selectedIssue == 'Other' ? _issueController.text : _selectedIssue,
        'date_time': _selectedDateTime,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'comments': [],
      });

      // Send notification to admin and engineers
      await FirebaseFirestore.instance.collection('notifications').add({'task_id':taskRef.id,
      'message':'A new task is added.',
      'timestamp':FieldValue.serverTimestamp(),
      'roles':['admin','engineer'],
      });
FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      // Start a 24-hour timer for the task
     Future.delayed(Duration(hours:24),()async{
      DocumentSnapshot taskSnapshot=await taskRef.get();
      if(taskSnapshot.exists && taskSnapshot['status']=='pending')
      {
        await taskRef.update({'status':'red-flagged'});
        await FirebaseFirestore.instance.collection('notifications').add({
          'task_id':taskRef.id,
          'message':'Task unresolved since 24 hrs',
           'timestamp':FieldValue.serverTimestamp(),
      'roles':['admin','engineer'],
        });
      }
     });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task added successfully')));
      _issueController.clear();
      setState(() {
        _selectedBuilding = null;
        _selectedFloor = null;
        _selectedRoom = null;
        _selectedDevice = null;
        _selectedDateTime = null;
        _selectedIssue = null;
        _rooms = [];
        _devices = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register issue: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
        backgroundColor: blueColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStartColor, gradientEndColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassmorphicContainer(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Log Issue",
                            style: TextStyle(
                              fontSize: 60,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.bold,
                              color: blueColor,
                            ),
                          ),
                          SizedBox(height: 48),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Select Building",
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            dropdownColor: Colors.white.withOpacity(0.8),
                            value: _selectedBuilding,
                            items: _buildings.map((building) {
                              return DropdownMenuItem<String>(
                                value: building,
                                child: Text(building, style: TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBuilding = value;
                                _selectedFloor = null;
                                _selectedRoom = null;
                                _selectedDevice = null;
                                _loadFloors(value!);
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Select Floor",
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            dropdownColor: Colors.white.withOpacity(0.8),
                            value: _selectedFloor,
                            items: _floors.map((floor) {
                              return DropdownMenuItem<String>(
                                value: floor,
                                child: Text(floor, style: TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFloor = value;
                                _selectedRoom = null;
                                _selectedDevice = null;
                                _loadRooms(_selectedBuilding!, value!);
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Select Room",
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            dropdownColor: Colors.white.withOpacity(0.8),
                            value: _selectedRoom,
                            items: _rooms.map((room) {
                              return DropdownMenuItem<String>(
                                value: room,
                                child: Text(room, style: TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoom = value;
                                _selectedDevice = null;
                                _loadDevices(_selectedBuilding!, _selectedFloor!, value!);
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Select Device",
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            dropdownColor: Colors.white.withOpacity(0.8),
                            value: _selectedDevice,
                            items: _devices.map((device) {
                              return DropdownMenuItem<String>(
                                value: device,
                                child: Text(device, style: TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDevice = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Select Issue",
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                            dropdownColor: Colors.white.withOpacity(0.8),
                            value: _selectedIssue,
                            items: _commonIssues.map((issue) {
                              return DropdownMenuItem<String>(
                                value: issue,
                                child: Text(issue, style: TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedIssue = value;
                              });
                            },
                          ),
                          if (_selectedIssue == 'Other') ...[
                            SizedBox(height: 16),
                            TextField(
                              style: TextStyle(color: blueColor,fontFamily: 'Ubuntu'),
                              controller: _issueController,
                              decoration: InputDecoration(
                                labelText: "Describe the issue",
                                labelStyle: TextStyle(color: blueColor),
                                
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _selectDateTime(context),
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: _selectedDateTime == null ? "Select Date and Time" : _selectedDateTime!.toString(),
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(color: blueColor),
                                ),
                                style:TextStyle(color: blueColor,fontFamily: 'Ubuntu') ,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                           InkWell(
                        onTap: _addTask,
                        child: Container(
                          child:  Text("Add Task"),
                          width:double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4))),
                            color: blueColor,
                          ),
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}