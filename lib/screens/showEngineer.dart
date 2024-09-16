import 'package:JHC_MIS/screens/add_task.dart';
import 'package:JHC_MIS/screens/admindashboard.dart';
import 'package:JHC_MIS/screens/comments.dart';
import 'package:JHC_MIS/screens/deviceProfilePage.dart';
import 'package:JHC_MIS/screens/device_profile.dart';
import 'package:JHC_MIS/screens/engineerDashboard.dart';
import 'package:JHC_MIS/screens/report.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/widgets/custom_dash_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:JHC_MIS/models/user.dart' as model;
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart'; // To format timestamps

class engDashboard extends StatefulWidget {
  const engDashboard({super.key});

  @override
  State<engDashboard> createState() => _engDashboardState();
}

class _engDashboardState extends State<engDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a GlobalKey for the Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  // Function to fetch notifications from Firestore
  Stream<List<Map<String, dynamic>>> fetchNotifications() {
    return _firestore.collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // Function to format the timestamp
  String formatTimestamp(Timestamp timestamp) {
    var dateTime = timestamp.toDate();
    return DateFormat.yMMMd().add_jm().format(dateTime); // Example: Sep 12, 2024 3:30 PM
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Engineer Dashboard"),
        backgroundColor: blueColor,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer(); // Open the right-side drawer using the GlobalKey
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: blueColor,
              ),
              child: Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Expanded(
  child: StreamBuilder<List<Map<String, dynamic>>>(
    stream: fetchNotifications(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('No notifications available.'));
      }

      var notifications = snapshot.data!;
      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];
          var timestamp = notification['timestamp'] as Timestamp;
          var message = notification['message'] ?? 'No message';
          var taskId = notification['taskId']; // Assuming you have taskId in the notification data

          return ListTile(
            title: Text(message),
            subtitle: Text(formatTimestamp(timestamp)),
            leading: Icon(Icons.notification_important, color: Colors.red),
            onTap: () {
              Navigator.pop(context);
              
            },
          );
        },
      );
    },
  ),
),
          ],
        ),),
      body: FutureBuilder<model.User>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No user data available'));
          }

          final userData = snapshot.data!;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Text(
                    "Welcome ${userData.role}",
                    style: TextStyle(
                      fontSize: size.height * 0.056,
                      color: blueColor,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DashboardButton(
                                  text: 'Device Profile',
                                  isSelected: false,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DeviceProfile()),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.04),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DashboardButton(
                                  text: 'Issue Tracker',
                                  isSelected: false,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EngineerDashboard()),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DashboardButton(
                                  text: 'Task Manager',
                                  isSelected: false,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddTask()));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
