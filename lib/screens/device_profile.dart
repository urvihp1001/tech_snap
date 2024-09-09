import 'package:JHC_MIS/screens/deviceProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:JHC_MIS/utils/colors.dart';
import 'package:JHC_MIS/widgets/glass_morph.dart';
import 'package:JHC_MIS/widgets/text_field_input.dart';

class DeviceProfile extends StatefulWidget {
  @override
  _DeviceProfileState createState() => _DeviceProfileState();
}

class _DeviceProfileState extends State<DeviceProfile> {
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _deviceTypeController = TextEditingController();
  final TextEditingController _bldgController=TextEditingController();
  final TextEditingController _floorNumberController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();
  
  DateTime? _selectedDateTime;
  bool _isLoading = false;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

  Future<void> _addDeviceProfile() async {
    setState(() {
      _isLoading = true;
    });

    final String deviceId = _deviceIdController.text;
    final String deviceType = _deviceTypeController.text;
    final String bldg=_bldgController.text;
    final String floorNumber = _floorNumberController.text;
    final String roomNumber = _roomNumberController.text;
    final String additionalNotes = _additionalNotesController.text;

    if (deviceId.isEmpty || deviceType.isEmpty || floorNumber.isEmpty || roomNumber.isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!);

    try {
      await FirebaseFirestore.instance.collection('device_profiles').add({
        'device_id': deviceId,
        'device_type': deviceType,
        'building':bldg,
        'floor_number': floorNumber,
        'room_number': roomNumber,
        'installation_date_time': formattedDateTime, // Store as formatted string
        'additional_notes': additionalNotes,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Device Profile added successfully")),
      );

      _deviceIdController.clear();
      _deviceTypeController.clear();
      _bldgController.clear();
      _floorNumberController.clear();
      _roomNumberController.clear();
      _additionalNotesController.clear();
      setState(() {
        _selectedDateTime = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeviceProfilePage()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add device profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Device Profile"),
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
                            "Add Device",
                            style: TextStyle(
                              fontSize: 60,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.bold,
                              color: blueColor,
                            ),
                          ),
                          SizedBox(height: 48),
                          TextFieldInput(
                            textEditingController: _deviceIdController,
                            hintText: "Enter Device ID",
                            textInputType: TextInputType.text,
                          ),
                          SizedBox(height: size.height * 0.02),
                          TextFieldInput(
                            textEditingController: _deviceTypeController,
                            hintText: "Enter Device Type",
                            textInputType: TextInputType.text,
                          ),
                          SizedBox(height: size.height * 0.02),
                            TextFieldInput(
                            textEditingController: _bldgController,
                            hintText: "Enter Device Building",
                            textInputType: TextInputType.text,
                          ),
                            SizedBox(height: size.height * 0.02),
                          TextFieldInput(
                            textEditingController: _floorNumberController,
                            hintText: "Enter Device Floor",
                            textInputType: TextInputType.text,
                          ),
                          SizedBox(height: size.height * 0.02),
                          TextFieldInput(
                            textEditingController: _roomNumberController,
                            hintText: "Enter Device Room",
                            textInputType: TextInputType.text,
                          ),
                          SizedBox(height: size.height * 0.02),
                          GestureDetector(
                            onTap: () => _selectDateTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border.all(color: blueColor),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _selectedDateTime == null
                                    ? 'Select Installation Date & Time'
                                    : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedDateTime == null
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          TextFieldInput(
                            textEditingController: _additionalNotesController,
                            hintText: "Enter Additional Information",
                            textInputType: TextInputType.multiline,
                          ),
                          SizedBox(height: size.height * 0.04),
                          InkWell(
                            onTap: _addDeviceProfile,
                            child: Container(
                              child: _isLoading
                                  ? Center(
                                      child: const CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    )
                                  : Text("Add Device"),
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
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
