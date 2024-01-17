import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlay_dmp_teams/my_theme.dart';

import '../custom/useful_elements.dart';
import 'main.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.01),
        centerTitle: true,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            child: UsefulElements.backToMain(context,
                go_back: false, color: "black"),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).noti,
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SvgPicture.asset("assets/Icon.svg"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context).no_noti,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 30, end: 30),
              child: Text(
                AppLocalizations.of(context).no_noti_text,
                style: TextStyle(color: Color(0xFF737A82), fontSize: 15),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              width: width * 0.9,
              height: 55.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Main(
                                go_back: true,
                              )));
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(MyTheme.accent_color),
                  shadowColor: MaterialStateProperty.all<Color>(
                      MyTheme.accent_color_shadow),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).go_home,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
