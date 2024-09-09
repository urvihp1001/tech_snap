import 'package:JHC_MIS/widgets/glassmorphic_profile.dart';
import 'package:JHC_MIS/widgets/tilt_effect.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:JHC_MIS/utils/colors.dart';

import 'package:JHC_MIS/widgets/tilt_card.dart';

class DeviceProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Device Profiles"),
        backgroundColor: blueColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStartColor, gradientEndColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('device_profiles')
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var devices = snapshot.data!.docs;

            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                var device = devices[index];
                return Padding(
                  padding: EdgeInsets.all(8),
                  child:GlassmorphicContainer(child:TiltEffect(child: Row(children: [
                     Image.network(
                            'data:image/jpeg;base64,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', // Replace with the actual URL of the stock photo
                            width: size.width * 0.3,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                    SizedBox(width:16),
                     Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Device ID: ${device['device_id']}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Type: ${device['device_type']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Floor: ${device['floor_number']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Room: ${device['room_number']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Installed: ${device['installation_date_time']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],

                ),
                  ],
                ),
                ),
                  ),
                );
              }
            );
          }
        ),
  
      ),
    );
  }
  }