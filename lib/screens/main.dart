import 'dart:async';
import 'dart:io';

import 'package:flutter_svg/svg.dart';
import 'package:mlay_dmp_teams/custom/common_functions.dart';
import 'package:mlay_dmp_teams/data_model/order_mini_response.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:mlay_dmp_teams/presenter/bottom_appbar_index.dart';
import 'package:mlay_dmp_teams/presenter/cart_counter.dart';
import 'package:mlay_dmp_teams/repositories/cart_repository.dart';
import 'package:mlay_dmp_teams/screens/booking.dart';
import 'package:mlay_dmp_teams/screens/cart.dart';
import 'package:mlay_dmp_teams/screens/category_list.dart';
import 'package:mlay_dmp_teams/screens/home.dart';
import 'package:mlay_dmp_teams/screens/login.dart';
import 'package:mlay_dmp_teams/screens/orders.dart';
import 'package:mlay_dmp_teams/screens/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:route_transitions/route_transitions.dart';

class Main extends StatefulWidget {
  Main({Key key, go_back = true, this.indexx = 0}) : super(key: key);

  bool go_back;
  int indexx;

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _currentIndex = 0;
  //int _cartCount = 0;

  BottomAppbarIndex bottomAppbarIndex = BottomAppbarIndex();

  CartCounter counter = CartCounter();

  var _children = [];

  fetchAll() {
    getCartCount();
  }

  void onTapped(int i) {
    fetchAll();
    if (!is_logged_in.$ && (i == 2 || i == 1)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    // if (i == 3) {
    //   app_language_rtl.$
    //       ? slideLeftWidget(newPage: Profile(), context: context)
    //       : slideRightWidget(newPage: Profile(), context: context);
    // return;
    // }

    setState(() {
      _currentIndex = i;
    });
    //print("i$i");
  }

  getCartCount() async {
    Provider.of<CartCounter>(context, listen: false).getCount();
  }

  void initState() {
    print(widget.indexx);
    if (widget.indexx == 2) {
      setState(() {
        onTapped(2);
      });
    }

    _children = [
      Home(
        counter: counter,
      ),
      // CategoryList(
      //   is_base_category: true,
      // ),
      Orders(),
      // Cart(
      //   has_bottomnav: true,
      //   from_navigation: true,
      //   counter: counter,
      // ),
      allBooking(),
      Profile()
    ];
    fetchAll();
    // TODO: implement initState
    //re appear statusbar in case it was not there in the previous page
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //print("_currentIndex");
        if (_currentIndex != 0) {
          fetchAll();
          setState(() {
            _currentIndex = 0;
          });
          return false;
        } else {
          CommonFunctions(context).appExitDialog();
        }
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBody: true,
            body: _children[_currentIndex],
            bottomNavigationBar: Container(
              height: 95,
              decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  onTap: onTapped,
                  currentIndex: _currentIndex,
                  backgroundColor: Colors.white.withOpacity(0.95),
                  unselectedItemColor: Color.fromRGBO(168, 175, 179, 1),
                  selectedItemColor: MyTheme.accent_color,
                  selectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: MyTheme.accent_color,
                      fontSize: 12),
                  unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(168, 175, 179, 1),
                      fontSize: 12),
                  items: [
                    BottomNavigationBarItem(
                      icon: _currentIndex == 0
                          ? Container(
                              height: 55,
                              width: 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/BG2.png'),
                                  fit: BoxFit.fill,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    top: 15, end: 25, start: 25, bottom: 8),
                                child: SvgPicture.asset(
                                  "assets/Home.svg",
                                  color: _currentIndex == 0
                                      ? Theme.of(context).accentColor
                                      : Color(0xFF737A82),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SvgPicture.asset(
                                "assets/Home.svg",
                                color: _currentIndex == 0
                                    ? Theme.of(context).accentColor
                                    : Color(0xFF737A82),
                                height: 25,
                              ),
                            ),
                      label: AppLocalizations.of(context).home,
                    ),
                    BottomNavigationBarItem(
                        icon: _currentIndex == 1
                            ? Container(
                                height: 55,
                                width: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/BG2.png'),
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 15, end: 25, start: 25, bottom: 2),
                                  child: SvgPicture.asset(
                                    "assets/Bag.svg",
                                    // width: 20,
                                    color: _currentIndex == 1
                                        ? Theme.of(context).accentColor
                                        : Color(0xFF737A82),
                                    // height: 18,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: SvgPicture.asset(
                                  "assets/Bag.svg",
                                  color: _currentIndex == 1
                                      ? Theme.of(context).accentColor
                                      : Color(0xFF737A82),
                                  height: 25,
                                ),
                              ),
                        label: AppLocalizations.of(context).order),
                    BottomNavigationBarItem(
                        icon: _currentIndex == 2
                            ? Container(
                                height: 55,
                                width: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/BG2.png'),
                                    fit: BoxFit.fill,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 15, end: 25, start: 25, bottom: 2),
                                  child: SvgPicture.asset(
                                    "assets/Document.svg",
                                    // width: 20,
                                    color: _currentIndex == 2
                                        ? Theme.of(context).accentColor
                                        : Color(0xFF737A82),
                                    // height: 18,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: SvgPicture.asset(
                                  "assets/Document.svg",
                                  color: _currentIndex == 2
                                      ? Theme.of(context).accentColor
                                      : Color(0xFF737A82),
                                  height: 25,
                                ),
                              ),
                        label: AppLocalizations.of(context).book),
                    BottomNavigationBarItem(
                      icon: _currentIndex == 3
                          ? Container(
                              height: 55,
                              width: 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/BG2.png'),
                                  fit: BoxFit.fill,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    top: 15, end: 25, start: 25, bottom: 2),
                                child: SvgPicture.asset(
                                  "assets/Profile.svg",
                                  // width: 20,
                                  color: _currentIndex == 3
                                      ? Theme.of(context).accentColor
                                      : Color(0xFF737A82),
                                  // height: 18,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SvgPicture.asset(
                                "assets/Profile.svg",
                                color: _currentIndex == 3
                                    ? Theme.of(context).accentColor
                                    : Color(0xFF737A82),
                                height: 25,
                              ),
                            ),
                      label: AppLocalizations.of(context).profile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
