import 'package:JHC_MIS/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class WeeklyTasks extends StatefulWidget {
  const WeeklyTasks({super.key});

  @override
  State<WeeklyTasks> createState() => _WeeklyTasksState();
}

class _WeeklyTasksState extends State<WeeklyTasks> {
  bool _isLoading = false;
Future<bool> _request_per(Permission permission)async
{
  AndroidDeviceInfo build=await DeviceInfoPlugin().androidInfo;
  if(build.version.sdkInt>=30)
  {
    var re=await Permission.manageExternalStorage.request();
    if (re.isGranted)
    {
      return true;
    }
    else{
      return false;
    }
  }
  else{
    if(await permission.isGranted)
    {
return true;
    }
    else{
      return false;
    }
    
  }
}
  DateTime _startOfWeek() {
    DateTime now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1)); // Monday of the week
  }

  DateTime _endOfWeek() {
    DateTime now = DateTime.now();
    return now.add(Duration(days: DateTime.daysPerWeek - now.weekday)); // Sunday of the week
  }

  Future<void> _generateExcelReport(List<QueryDocumentSnapshot> tasks) async {
    setState(() {
      _isLoading = true;
    });

    var excel = Excel.createExcel();
    Sheet sheetObj = excel['Tasks this week'];
    sheetObj.appendRow([
     TextCellValue( 'TaskId',),
              TextCellValue('Building'),
        TextCellValue('Floor'),
        TextCellValue('Room'),
        TextCellValue('Device'),
        TextCellValue('Issue'),
        TextCellValue('Date'),
        TextCellValue('Status')

    ]);

    for (var task in tasks) {
      sheetObj.appendRow([
       TextCellValue(task.id),
        TextCellValue(task['building']),
        TextCellValue(task['floor_number']),
        TextCellValue(task['room_number']),
        TextCellValue(task['device_id']),
        TextCellValue(task['issue']),
        TextCellValue(task['date_time'].toDate().toString()),
        TextCellValue(task['status'])
      ]);
    }

    await _saveExcelFile(excel);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveExcelFile(Excel excel) async {
   // when you are in flutter web then save() downloads the excel file.

// Call function save() to download the file
if(kIsWeb)
{
  var fileBytes = excel.save(fileName: 'My_Excel_File_Name.xlsx');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel Report saved")),
      );
}
else{
 if(await  _request_per(Permission.storage))
 {
  print("granted");
  var bytes = excel.save();
    
    // Get the Downloads directory path
    Directory downloadsDir = Directory('/storage/emulated/0/Download');

    // Define the file path for the report in the Downloads folder
    String filePath = "${downloadsDir.path}/Weekly_Tasks_Report.xlsx";

    // Save the file
    
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!);

      print("File saved at: $filePath");

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Excel Report saved at $filePath")),
      );
 }
 else{
  print("not granted");
 }
}
      
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("This Week's Tasks"),backgroundColor: blueColor,),
       body:Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStartColor, gradientEndColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),child:StreamBuilder(
          
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('date_time', isGreaterThanOrEqualTo: _startOfWeek())
            .where('date_time', isLessThanOrEqualTo: _endOfWeek())
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tasks available for this week',style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),);
          }
          final tasks = snapshot.data!.docs;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text("Task ID: ${task.id}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Building: ${task['building']}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                          Text("Floor: ${task['floor_number']}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                          Text("Room: ${task['room_number']}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                          Text("Device: ${task['device_id']}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                          Text("Issue: ${task['issue']}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                          Text("Date: ${task['date_time'].toDate()}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                          Text("Status: ${task['status']}",style:TextStyle(fontFamily:'Ubuntu',color: Colors.black87)),
                        ],
                      ),
                    );
                  },
                ),
              ),
               InkWell(
              onTap: ()=>_generateExcelReport(snapshot.data!.docs),
              child:Container(
             child:_isLoading?Center(child:const CircularProgressIndicator(color: primaryColor,)): Text("Generate Report"),
              width:MediaQuery.of(context).size.width*0.8,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical:12),
              decoration: ShapeDecoration(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                color:blueColor,
                ),
            ),
            ),
            const SizedBox(height:12),
            ],
          );
        },
      ),
       ),
    );
  }
}
