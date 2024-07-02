import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'LocaleString.dart';
import 'language_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function(BuildContext) logoutCallback;

  CustomAppBar({required this.logoutCallback});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    LanguageController _languageController = Get.find();
    return AppBar(
      backgroundColor: Colors.blue,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/wrd_logo.png',
            width: 30,
            height: 30,
          ),
          SizedBox(width: 8),
          Text(
            'pims'.tr,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 8),
          Image.asset(
            'images/logo.png',
            width: 30,
            height: 30,
          ),
        ],
      ),
      actions: [
        Obx(() => Row(
          children: [
            Radio(
              value: 'en',
              groupValue: _languageController.locale.value!,
              onChanged: (value) {
                _languageController.changeLanguage(value as String);
              },
            ),
            Text('English'.tr),
            Radio(
              value: 'pa',
              groupValue: _languageController.locale.value!,
              onChanged: (value) {
                _languageController.changeLanguage(value as String);
              },
            ),
            Text('Punjabi'.tr),
          ],
        )),
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'logout') {
              logoutCallback(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'.tr),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
