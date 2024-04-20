import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/sp_keys.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  String email = '';
  String name = '';
  String pass = '';

  @override
  void initState() {
    super.initState();
    getEmailPass();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 100,
              sigmaY: 100,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        backgroundColor: Colors.blue.withAlpha(200).withOpacity(0.25),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/images/wired.gif',
                      scale: 2, color: Colors.white),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Welcome,",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Email | $email',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Pass   | $pass',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 20,
            // foregroundColor: Colors.black38,
            backgroundColor: Colors.blue.shade800,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
            minimumSize: const Size(double.maxFinite, 48),
          ),
          onPressed: () async {
            var sharedPref = await SharedPreferences.getInstance();
            Map<String, dynamic> json =
            jsonDecode(sharedPref.getString(AppKeys.json) ?? '');
            print(json);
            sharedPref.setBool(AppKeys.keyLogin, false);
            Future.delayed(Duration.zero)
                .then((value) =>
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false));
          },
          child: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void getEmailPass() async {
    var sharedPref = await SharedPreferences.getInstance();
    var getUserList = sharedPref.getStringList(AppKeys.userListKey);
    var getCurrentUser = sharedPref.getString(AppKeys.currentUserKey);

    for (int i = 0; i < (getUserList?.length ?? 0); i++) {
      final getUserMap = jsonDecode(getUserList?[i] ?? '');
      if (getUserMap['email'] == getCurrentUser) {
        setState(() {
          name = getUserMap['name'];
          email = getUserMap['email'];
          pass = getUserMap['pass'];
        });
        break;
      }
    }
  }
}
