import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/data/models/user_model.dart';
import 'package:task_manager/data/network_caller/network_caller.dart';
import 'package:task_manager/data/network_caller/network_response.dart';
import 'package:task_manager/data/utility/urls.dart';
import 'package:task_manager/ui/controllers/auth_controller.dart';
import 'package:task_manager/ui/widgets/body_background.dart';
import 'package:task_manager/ui/widgets/profile_summary_card.dart';
import 'package:task_manager/ui/widgets/snack_message.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  TextEditingController _firstNameTEController = TextEditingController();
  TextEditingController _lastNameTEController = TextEditingController();
  TextEditingController _mobileTEController = TextEditingController();
  TextEditingController _passwordTEController = TextEditingController();

  AuthController authController = Get.find<AuthController>();

  bool _updateProfileInProgress = false;

  XFile? photo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailTEController.text = authController.user?.email ?? '';
    _firstNameTEController.text = authController.user?.firstName ?? '';
    _lastNameTEController.text = authController.user?.lastName ?? '';
    _mobileTEController.text = authController.user?.mobile ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileSummaryCard(
              enableOnTap: false,
            ),
            Expanded(
                child: BodyBackground(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        'Update Profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      photoPickerField(),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _emailTEController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _firstNameTEController,
                        decoration: const InputDecoration(
                          hintText: 'First Name',
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _lastNameTEController,
                        decoration: const InputDecoration(
                          hintText: 'Last Name',
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _mobileTEController,
                        decoration: const InputDecoration(
                          hintText: 'Mobile',
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        controller: _passwordTEController,
                        decoration: const InputDecoration(
                          hintText: 'Password (Optional)',
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Visibility(
                            visible: _updateProfileInProgress == false,
                            replacement: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            child: ElevatedButton(
                                onPressed: updateProfile,
                                child:
                                    Icon(Icons.arrow_circle_right_outlined))),
                      ),
                    ],
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    _updateProfileInProgress = true;
    if (mounted) {
      setState(() {});
    }
    String? photoInBase64;
    Map<String, dynamic> inputData = {
      "firstName": _firstNameTEController.text.trim(),
      "lastName": _lastNameTEController.text.trim(),
      "email": _emailTEController.text.trim(),
      "mobile": _mobileTEController.text.trim()
    };

    if (_passwordTEController.text.isNotEmpty) {
      inputData["password"] = _passwordTEController.text;
    }

    if(photo != null){
      List<int> imageBytes = await photo!.readAsBytes();
       photoInBase64 = base64UrlEncode(imageBytes);
      inputData['photo'] = photoInBase64;
    }
    final NetworkResponse response =
        await NetworkCaller().postRequest(Urls.updateProfile, body: inputData);
    _updateProfileInProgress = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess) {
      Get.find<AuthController>().updateUserInformation(UserModel(
          email: _emailTEController.text.trim(),
          firstName: _firstNameTEController.text.trim(),
          lastName: _lastNameTEController.text.trim(),
          mobile: _mobileTEController.text.trim(),
          photo: photoInBase64 ?? Get.find<AuthController>().user?.photo
      ));
      if (mounted) {
        showSnackMessage(context, 'Update profile success');
      }
    } else {
      if (mounted) {
        showSnackMessage(context, 'Update Profile failed. Try again.');
      }
    }
  }

  Container photoPickerField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    )),
                alignment: Alignment.center,
                child: Text(
                  'Photo',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )),
          Expanded(
              flex: 3,
              child: InkWell(
                onTap: () async{
                  final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
                  if(image != null){
                    photo = image;
                    if(mounted){
                      setState(() {});
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  child: Visibility(
                      visible: photo == null,
                      replacement: Text(photo?.name ?? ''),
                      child: Text('Select a photo'),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
