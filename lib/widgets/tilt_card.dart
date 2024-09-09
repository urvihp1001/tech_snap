import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'tilt_effect.dart';
import 'package:JHC_MIS/utils/colors.dart';

class TiltCard extends StatelessWidget {
  final String deviceId;
  final String deviceType;
  final String floorNumber;
  final String installationDate;
  final String roomNumber;
  final String additionalNotes;
  final String imageUrl;
  
  const TiltCard({super.key, required this.deviceId, required this.deviceType, required this.floorNumber, required this.installationDate, required this.roomNumber, required this.additionalNotes, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return TiltEffect(child: Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:LinearGradient(colors: [Colors.white.withOpacity(0.2),Colors.white.withOpacity(0.1),],
        begin:Alignment.topLeft,
        end:Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 8,
            offset: Offset(0,8),
          ),
        ],
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:Image.network(imageUrl,
            height:120,
            width:double.infinity,
            fit:BoxFit.contain,
            )
          ),
          SizedBox(height: 12,),
          Text('Device ID: $deviceId',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          ),
          Text('Device Type: $deviceType',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          ),
          Text('Floor: $floorNumber, Room: $roomNumber',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          ),
          Text('Installed on: $installationDate',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          ),
          Text('Notes: $additionalNotes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          ),
      ],
      )
    ),
    
    );
  }
}