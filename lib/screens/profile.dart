import 'dart:async';

import 'package:mlay_dmp_teams/custom/box_decorations.dart';
import 'package:mlay_dmp_teams/custom/device_info.dart';
import 'package:mlay_dmp_teams/custom/lang_text.dart';
import 'package:mlay_dmp_teams/helpers/auth_helper.dart';
import 'package:mlay_dmp_teams/screens/auction_products.dart';
import 'package:mlay_dmp_teams/screens/change_language.dart';
import 'package:mlay_dmp_teams/screens/classified_ads/classified_ads.dart';
import 'package:mlay_dmp_teams/screens/classified_ads/my_classified_ads.dart';
import 'package:mlay_dmp_teams/screens/digital_product/digital_products.dart';
import 'package:mlay_dmp_teams/screens/digital_product/purchased_digital_produts.dart';
import 'package:mlay_dmp_teams/screens/filter.dart';
import 'package:mlay_dmp_teams/screens/login.dart';
import 'package:mlay_dmp_teams/screens/main.dart';
import 'package:mlay_dmp_teams/screens/messenger_list.dart';
import 'package:mlay_dmp_teams/screens/whole_sale_products.dart';
import 'package:mlay_dmp_teams/screens/wishlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:mlay_dmp_teams/ui_sections/drawer.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/screens/wallet.dart';
import 'package:mlay_dmp_teams/screens/profile_edit.dart';
import 'package:mlay_dmp_teams/screens/address.dart';
import 'package:mlay_dmp_teams/screens/order_list.dart';
import 'package:mlay_dmp_teams/screens/club_point.dart';
import 'package:mlay_dmp_teams/screens/refund_request.dart';
import 'package:mlay_dmp_teams/repositories/profile_repository.dart';
import 'package:mlay_dmp_teams/custom/toast_component.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../custom/useful_elements.dart';
import '../repositories/auth_repository.dart';

class Profile extends StatefulWidget {
  Profile({Key key, this.show_back_button = false}) : super(key: key);

  bool show_back_button;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ScrollController _mainScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _cartCounter = 0;
  String _cartCounterString = "00";
  int _wishlistCounter = 0;
  String _wishlistCounterString = "00";
  int _orderCounter = 0;
  String _orderCounterString = "00";
  BuildContext loadingcontext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  fetchAll() {
    fetchCounters();
  }

  fetchCounters() async {
    var profileCountersResponse =
        await ProfileRepository().getProfileCountersResponse();

    _cartCounter = profileCountersResponse.cart_item_count;
    _wishlistCounter = profileCountersResponse.wishlist_item_count;
    _orderCounter = profileCountersResponse.order_count;

    _cartCounterString =
        counterText(_cartCounter.toString(), default_length: 2);
    _wishlistCounterString =
        counterText(_wishlistCounter.toString(), default_length: 2);
    _orderCounterString =
        counterText(_orderCounter.toString(), default_length: 2);

    setState(() {});
  }

  deleteAccountReq() async {
    loading();
    var response = await AuthRepository().getAccountDeleteResponse();

    if (response.result) {
      AuthHelper().clearUserData();
      Navigator.pop(loadingcontext);
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) {
        return Main();
      }), (route) => false);
    }
    ToastComponent.showDialog(response.message);
  }

  String counterText(String txt, {default_length = 3}) {
    var blank_zeros = default_length == 3 ? "000" : "00";
    var leading_zeros = "";
    if (txt != null) {
      if (default_length == 3 && txt.length == 1) {
        leading_zeros = "00";
      } else if (default_length == 3 && txt.length == 2) {
        leading_zeros = "0";
      } else if (default_length == 2 && txt.length == 1) {
        leading_zeros = "0";
      }
    }

    var newtxt = (txt == null || txt == "" || txt == null.toString())
        ? blank_zeros
        : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leading_zeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  reset() {
    _cartCounter = 0;
    _cartCounterString = "00";
    _wishlistCounter = 0;
    _wishlistCounterString = "00";
    _orderCounter = 0;
    _orderCounterString = "00";
    setState(() {});
  }

  onTapLogout(context) async {
    AuthHelper().clearUserData();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return Main();
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: buildView(context),
    );
  }

  Widget buildView(context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      appBar: buildCustomAppBar(context),
      body: buildBody(),
    );
  }

  RefreshIndicator buildBody() {
    return RefreshIndicator(
      color: MyTheme.accent_color,
      backgroundColor: Colors.white,
      onRefresh: _onPageRefresh,
      displacement: 10,
      child: buildBodyChildren(),
    );
  }

  CustomScrollView buildBodyChildren() {
    return CustomScrollView(
      controller: _mainScrollController,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
            //   child: buildCountersRow(),
            // ),

            /* Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: buildHorizontalSettings(),
            ),*/
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
            //   child: buildSettingAndAddonsVerticalMenu(),
            // ),
            /* Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: buildSettingAndAddonsHorizontalMenu(),
            ),*/
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: buildBottomVerticalCardList(),
            ),
          ]),
        )
      ],
    );
  }

  AppBar buildCustomAppBar(context) {
    return AppBar(
      backgroundColor: Colors.grey.withOpacity(0.01),
      centerTitle: true,
      elevation: 0,
      title: Text(
        AppLocalizations.of(context).profile,
        style: TextStyle(color: Colors.black),
      ),
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: UsefulElements.backToMain(context,
              go_back: false, color: "black"),
        ),
      ),
      //  Container(
      //     // color: Colors.green,
      //     child: SafeArea(
      //       child: Column(
      //         children: [
      //           Align(
      //             alignment: Alignment.topRight,
      //             child: Container(
      //               margin: EdgeInsets.only(right: 18),
      //               height: 30,
      //               child: InkWell(
      //                   onTap: () {
      //                     Navigator.pop(context);
      //                   },
      //                   child: Icon(
      //                     Icons.arrow_back_ios,
      //                     size: 20,
      //                   )),
      //             ),
      //           ),

      //           // Container(
      //           //   margin: EdgeInsets.symmetric(vertical: 8),
      //           //   width: DeviceInfo(context).width,height: 1,color: MyTheme.medium_grey_50,),
      // Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
      //   child: buildAppbarSection(),
      // ),
      //         ],
      //       ),
      //     ),
      //   ),
    );
  }

  Widget buildBottomVerticalCardList() {
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(bottom: 0, top: 14),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            35,
          ),
          topRight: Radius.circular(
            35,
          ),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            spreadRadius: 0.0,
            offset: Offset(0.0, 10.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Column(
        children: [
          if (false)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildBottomVerticalCardListItem("assets/coupon.png",
                    LangText(context).local.profile_screen_coupons,
                    onPressed: () {}),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
                buildBottomVerticalCardListItem("assets/favoriteseller.png",
                    LangText(context).local.profile_screen_favorite_seller,
                    onPressed: () {}),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          // buildBottomVerticalCardListItem("assets/download.png",
          //     LangText(context).local.profile_screen_all_digital_products,
          //     onPressed: () {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) {
          //     return DigitalProducts();
          //   }));
          // }),
          // Divider(
          //   thickness: 1,
          //   color: MyTheme.light_grey,
          // ),

          // this is addon
          if (false)
            Column(
              children: [
                buildBottomVerticalCardListItem("assets/auction.png",
                    LangText(context).local.profile_screen_on_auction_products,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AuctionProducts();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          if (classified_product_status.$)
            Column(
              children: [
                buildBottomVerticalCardListItem("assets/classified_product.png",
                    LangText(context).local.profile_screen_on_classified_ads,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ClassifiedAds();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          // this is addon
          if (false)
            Column(
              children: [
                buildBottomVerticalCardListItem("assets/wholesale.png",
                    LangText(context).local.profile_screen_wholesale_products,
                    onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WholeSaleProducts();
                  }));
                }),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),

          buildAppbarSection(),
          Divider(
            thickness: 1,
            color: MyTheme.grey_153.withOpacity(0.5),
          ),
          SizedBox(
            height: 10,
          ),
          // buildBottomVerticalCardListItem("assets/edit.png",
          //     AppLocalizations.of(context).profile_edit_screen_edit_profile,
          //     onPressed: is_logged_in.$
          //         ? () {
          //             Navigator.push(context,
          //                 MaterialPageRoute(builder: (context) {
          //               return ProfileEdit();
          //             })).then((value) {
          //               onPopped(value);
          //             });
          //           }
          //         : () => showLoginWarning()),
          // Divider(
          //   thickness: 0,
          //   color: MyTheme.white,
          // ),
          buildBottomVerticalCardListItem(
              "assets/language.png", AppLocalizations.of(context).lang,
              onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ChangeLanguage();
                },
              ),
            );
          }),
          Divider(
            thickness: 0,
            color: MyTheme.white,
          ),
          buildBottomVerticalCardListItem(
              "assets/location.png", AppLocalizations.of(context).address,
              onPressed: is_logged_in.$
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Address();
                          },
                        ),
                      );
                    }
                  : () => showLoginWarning()),

          Divider(
            thickness: 0,
            color: MyTheme.white,
          ),
          buildBottomVerticalCardListItem(
              "assets/orders.png", AppLocalizations.of(context).order,
              onPressed: is_logged_in.$
                  ? () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return OrderList();
                      }));
                    }
                  : () => null),
          Divider(
            thickness: 0,
            color: MyTheme.white,
          ),
          buildBottomVerticalCardListItem("assets/heart.png",
              AppLocalizations.of(context).main_drawer_my_wishlist,
              onPressed: is_logged_in.$
                  ? () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Wishlist();
                      }));
                    }
                  : () => showLoginWarning()),
          Divider(
            thickness: 0,
            color: MyTheme.white,
          ),
          if (conversation_system_status.$)
            buildBottomVerticalCardListItem("assets/messages.png",
                AppLocalizations.of(context).main_drawer_messages,
                onPressed: is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MessengerList();
                        }));
                      }
                    : () => showLoginWarning()),
          /*  Divider(
            thickness: 0,
            color: MyTheme.white,
          ),

          buildBottomVerticalCardListItem(
              "assets/shop.png", AppLocalizations.of(context).browse_all_seller,
              onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Filter(
                selected_filter: "sellers",
              );
            }));
          }),*/
          Divider(
            thickness: 0,
            color: MyTheme.white,
          ),

          if (is_logged_in.$)
            Column(
              children: [
                buildBottomVerticalCardListItem("assets/delete.png",
                    AppLocalizations.of(context).delete_account, onPressed: () {
                  deleteWarningDialog();

                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return Filter(
                  //     selected_filter: "sellers",
                  //   );
                  // }
                  //)
                  //);
                }),
                Divider(
                  thickness: 0,
                  color: MyTheme.white,
                ),

                // Container(
                //   width: 70,
                //   height: 26,
                //   child: FlatButton(
                //     padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                //     // 	rgb(50,205,50)
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(6),
                //         side: BorderSide(color: MyTheme.white)),
                //     child: Text(
                //       is_logged_in.$
                //           ? AppLocalizations.of(context).main_drawer_logout
                //           : LangText(context).local.main_drawer_login,
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 10,
                //           fontWeight: FontWeight.w500),
                //     ),
                //     onPressed: () {
                //       if (is_logged_in.$)
                //         onTapLogout(context);
                //       else
                //         Navigator.push(context,
                //             MaterialPageRoute(builder: (context) => Login()));
                //     },
                //   ),
                // ),
              ],
            ),
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {
                if (is_logged_in.$)
                  onTapLogout(context);
                else
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
              },
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0, left: 15),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MyTheme.grey_153.withOpacity(0.1),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: is_logged_in.$
                              ? Icon(
                                  Icons.logout,
                                  color: MyTheme.dark_font_grey,
                                  size: 18,
                                )
                              : Icon(
                                  Icons.login,
                                  color: MyTheme.dark_font_grey,
                                  size: 18,
                                )),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    is_logged_in.$
                        ? AppLocalizations.of(context).main_drawer_logout
                        : LangText(context).local.main_drawer_login,
                    style:
                        TextStyle(fontSize: 15, color: MyTheme.dark_font_grey),
                  ),
                ],
              ),
            ),
          ),

          if (false)
            buildBottomVerticalCardListItem(
                "assets/blog.png", LangText(context).local.profile_screen_blogs,
                onPressed: () {}),
        ],
      ),
    );
  }

  Container buildBottomVerticalCardListItem(String img, String label,
      {Function() onPressed, bool isDisable = false}) {
    return Container(
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            alignment: Alignment.center,
            padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 15),
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyTheme.grey_153.withOpacity(0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    img,
                    height: 16,
                    width: 16,
                    color:
                        isDisable ? MyTheme.grey_153 : MyTheme.dark_font_grey,
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   width: 5,
            // ),
            Text(
              label,
              style: TextStyle(
                  fontSize: 15,
                  color: isDisable ? MyTheme.grey_153 : MyTheme.dark_font_grey),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: MyTheme.grey_153.withOpacity(0.5),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This section show after counter section
  // change Language, Edit Profile and Address section
  Widget buildHorizontalSettings() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildHorizontalSettingItem(true, "assets/language.png",
              AppLocalizations.of(context).profile_screen_language, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ChangeLanguage();
                },
              ),
            );
          }),
          /*InkWell(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return OrderList();
              // }));
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/currency.png",
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppLocalizations.of(context).profile_screen_currency,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),*/
          buildHorizontalSettingItem(
              is_logged_in.$,
              "assets/edit.png",
              AppLocalizations.of(context).profile_edit_screen_edit_profile,
              is_logged_in.$
                  ? () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ProfileEdit();
                      })).then((value) {
                        onPopped(value);
                      });
                    }
                  : () => showLoginWarning()),
          buildHorizontalSettingItem(
              is_logged_in.$,
              "assets/location.png",
              AppLocalizations.of(context).profile_screen_address,
              is_logged_in.$
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Address();
                          },
                        ),
                      );
                    }
                  : () => showLoginWarning()),
        ],
      ),
    );
  }

  InkWell buildHorizontalSettingItem(
      bool isLogin, String img, String text, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            img,
            height: 16,
            width: 16,
            color: isLogin ? MyTheme.white : MyTheme.blue_grey,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: isLogin ? MyTheme.white : MyTheme.blue_grey,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  showLoginWarning() {
    return ToastComponent.showDialog(
        AppLocalizations.of(context).common_login_warning,
        gravity: Toast.center,
        duration: Toast.lengthLong);
  }

  deleteWarningDialog() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                LangText(context)
                    .local
                    .profile_screen_delete_account_warning_title,
                style: TextStyle(fontSize: 15, color: MyTheme.dark_font_grey),
              ),
              content: Text(
                LangText(context)
                    .local
                    .profile_screen_delete_account_warning_des,
                style: TextStyle(fontSize: 13, color: MyTheme.dark_font_grey),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      pop(context);
                    },
                    child: Text(LangText(context).local.common_no)),
                TextButton(
                    onPressed: () {
                      pop(context);
                      deleteAccountReq();
                    },
                    child: Text(LangText(context).local.common_yes))
              ],
            ));
  }
/*
  Widget buildSettingAndAddonsHorizontalMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      margin: EdgeInsets.only(top: 14),
      width: DeviceInfo(context).width,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        //color: Colors.blue,
        child: Wrap(
          direction: Axis.horizontal,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 20,
          spacing: 10,
          //mainAxisAlignment: MainAxisAlignment.start,
          alignment: WrapAlignment.center,
          children: [
            if (wallet_system_status.$)
              buildSettingAndAddonsHorizontalMenuItem("assets/wallet.png",
                  AppLocalizations.of(context).wallet_screen_my_wallet, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Wallet();
                }));
              }),
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/orders.png",
                AppLocalizations.of(context).profile_screen_orders,
                is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return OrderList();
                        }));
                      }
                    : () => null),
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/heart.png",
                AppLocalizations.of(context).main_drawer_my_wishlist,
                is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Wishlist();
                        }));
                      }
                    : () => null),
            if (club_point_addon_installed.$)
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/points.png",
                  AppLocalizations.of(context).club_point_screen_earned_points,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Clubpoint();
                          }));
                        }
                      : () => null),
            if (refund_addon_installed.$)
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/refund.png",
                  AppLocalizations.of(context)
                      .refund_request_screen_refund_requests,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return RefundRequest();
                          }));
                        }
                      : () => null),
            if (conversation_system_status.$)
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/messages.png",
                  AppLocalizations.of(context).main_drawer_messages,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MessengerList();
                          }));
                        }
                      : () => null),
            if (true)
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/auction.png",
                  AppLocalizations.of(context).profile_screen_auction,
                  is_logged_in.$
                      ? () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) {
                          //   return MessengerList();
                          // }));
                        }
                      : () => null),
            if (true)
              buildSettingAndAddonsHorizontalMenuItem(
                  "assets/classified_product.png",
                  AppLocalizations.of(context).profile_screen_classified_products,
                  is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MessengerList();
                          }));
                        }
                      : () => null),
          ],
        ),
      ),
    );
  }*/

  Widget buildSettingAndAddonsHorizontalMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      margin: EdgeInsets.only(top: 14),
      width: DeviceInfo(context).width,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: GridView.count(
        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //   crossAxisCount: 3,
        // ),
        crossAxisCount: 3,

        childAspectRatio: 2,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        cacheExtent: 5.0,
        mainAxisSpacing: 16,
        children: [
          if (wallet_system_status.$)
            Container(
              // color: Colors.red,

              child: buildSettingAndAddonsHorizontalMenuItem(
                  "assets/wallet.png",
                  AppLocalizations.of(context).wallet_screen_my_wallet, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Wallet();
                }));
              }),
            ),
          buildSettingAndAddonsHorizontalMenuItem(
              "assets/orders.png",
              AppLocalizations.of(context).profile_screen_orders,
              is_logged_in.$
                  ? () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return OrderList();
                      }));
                    }
                  : () => null),
          buildSettingAndAddonsHorizontalMenuItem(
              "assets/heart.png",
              AppLocalizations.of(context).main_drawer_my_wishlist,
              is_logged_in.$
                  ? () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Wishlist();
                      }));
                    }
                  : () => null),
          if (club_point_addon_installed.$)
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/points.png",
                AppLocalizations.of(context).club_point_screen_earned_points,
                is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Clubpoint();
                        }));
                      }
                    : () => null),
          if (refund_addon_installed.$)
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/refund.png",
                AppLocalizations.of(context)
                    .refund_request_screen_refund_requests,
                is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return RefundRequest();
                        }));
                      }
                    : () => null),
          if (conversation_system_status.$)
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/messages.png",
                AppLocalizations.of(context).main_drawer_messages,
                is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MessengerList();
                        }));
                      }
                    : () => null),
          // if (auction_addon_installed.$)
          if (false)
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/auction.png",
                AppLocalizations.of(context).profile_screen_auction,
                is_logged_in.$
                    ? () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return MessengerList();
                        // }));
                      }
                    : () => null),
          if (classified_product_status.$)
            buildSettingAndAddonsHorizontalMenuItem(
                "assets/classified_product.png",
                AppLocalizations.of(context).profile_screen_classified_products,
                is_logged_in.$
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MyClassifiedAds();
                        }));
                      }
                    : () => null),

          buildSettingAndAddonsHorizontalMenuItem(
              "assets/download.png",
              AppLocalizations.of(context).profile_screen_download,
              is_logged_in.$
                  ? () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PurchasedDigitalProducts();
                      }));
                    }
                  : () => null),
        ],
      ),
    );
  }

  Container buildSettingAndAddonsHorizontalMenuItem(
      String img, String text, Function() onTap) {
    return Container(
      alignment: Alignment.center,
      // color: Colors.red,
      // width: DeviceInfo(context).width / 4,
      child: InkWell(
        onTap: is_logged_in.$
            ? onTap
            : () {
                showLoginWarning();
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              img,
              width: 16,
              height: 16,
              color: is_logged_in.$
                  ? MyTheme.dark_font_grey
                  : MyTheme.medium_grey_50,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  color: is_logged_in.$
                      ? MyTheme.dark_font_grey
                      : MyTheme.medium_grey_50,
                  fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

/*
  Widget buildSettingAndAddonsVerticalMenu() {
    return Container(
      margin: EdgeInsets.only(bottom: 120, top: 14),
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
        children: [
          Visibility(
            visible: wallet_system_status.$,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Wallet();
                      }));
                    },
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        alignment: Alignment.center,
                        padding: EdgeInsets.zero),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/wallet.png",
                          width: 16,
                          height: 16,
                          color: MyTheme.dark_font_grey,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          AppLocalizations.of(context).wallet_screen_my_wallet,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.dark_font_grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return OrderList();
                }));
              },
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/orders.png",
                    width: 16,
                    height: 16,
                    color: MyTheme.dark_font_grey,
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    AppLocalizations.of(context).profile_screen_orders,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: MyTheme.dark_font_grey, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Wishlist();
                }));
              },
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/heart.png",
                    width: 16,
                    height: 16,
                    color: MyTheme.dark_font_grey,
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    AppLocalizations.of(context).main_drawer_my_wishlist,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: MyTheme.dark_font_grey, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          Visibility(
            visible: club_point_addon_installed.$,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Clubpoint();
                      }));
                    },
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        alignment: Alignment.center,
                        padding: EdgeInsets.zero),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/points.png",
                          width: 16,
                          height: 16,
                          color: MyTheme.dark_font_grey,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          AppLocalizations.of(context)
                              .club_point_screen_earned_points,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.dark_font_grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          ),
          Visibility(
            visible: refund_addon_installed.$,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return RefundRequest();
                      }));
                    },
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        alignment: Alignment.center,
                        padding: EdgeInsets.zero),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/refund.png",
                          width: 16,
                          height: 16,
                          color: MyTheme.dark_font_grey,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          AppLocalizations.of(context)
                              .refund_request_screen_refund_requests,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: MyTheme.dark_font_grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          ),
          Visibility(
            visible: conversation_system_status.$,
            child: Container(
              height: 40,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MessengerList();
                  }));
                },
                style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/messages.png",
                      width: 16,
                      height: 16,
                      color: MyTheme.dark_font_grey,
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      AppLocalizations.of(context).main_drawer_messages,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey, fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
*/
  Widget buildCountersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCountersRowItem(
          _cartCounterString,
          AppLocalizations.of(context).profile_screen_in_your_cart,
        ),
        buildCountersRowItem(
          _wishlistCounterString,
          AppLocalizations.of(context).profile_screen_in_wishlist,
        ),
        buildCountersRowItem(
          _orderCounterString,
          AppLocalizations.of(context).profile_screen_in_ordered,
        ),
      ],
    );
  }

  Widget buildCountersRowItem(String counter, String title) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 14),
      width: DeviceInfo(context).width / 3.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: MyTheme.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            counter,
            maxLines: 2,
            style: TextStyle(
                fontSize: 16,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            maxLines: 2,
            style: TextStyle(
              color: MyTheme.dark_font_grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAppbarSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // color: Colors.amber,
        alignment: Alignment.center,
        height: 48,
        child: GestureDetector(
          onTap: is_logged_in.$
              ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfileEdit();
                  })).then((value) {
                    onPopped(value);
                  });
                }
              : () => showLoginWarning(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* Container(
                child: InkWell(
                  //padding: EdgeInsets.zero,
                  onTap: (){
                  Navigator.pop(context);
                } ,child:Icon(Icons.arrow_back,size: 25,color: MyTheme.white,), ),
              ),*/
              // SizedBox(width: 10,),
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: MyTheme.white, width: 1),
                      //shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 20,
                          spreadRadius: 0.0,
                          offset: Offset(
                              0.0, 10.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: is_logged_in.$ && avatar_original.$ != null
                        ? ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100.0)),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/app_logo.png',
                              image: "${avatar_original.$}",
                              fit: BoxFit.fill,
                            ))
                        : is_logged_in.$ && avatar_original.$ == null
                            ? Image.asset(
                                'assets/app_logo.png',
                                height: 48,
                                width: 48,
                                fit: BoxFit.fitHeight,
                              )
                            : Image.asset(
                                'assets/app_logo.png',
                                height: 48,
                                width: 48,
                                fit: BoxFit.fitHeight,
                              )),
              ),
              GestureDetector(
                  onTap: is_logged_in.$
                      ? () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ProfileEdit();
                          })).then((value) {
                            onPopped(value);
                          });
                        }
                      : () => showLoginWarning(),
                  child: buildUserInfo()),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.15,
              // ),
              // is_logged_in.$
              //     ? Icon(
              //         Icons.arrow_forward_ios,
              //         color: MyTheme.grey_153.withOpacity(0.5),
              //       )
              //     : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserInfo() {
    return is_logged_in.$
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${user_name.$}",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    //if user email is not available then check user phone if user phone is not available use empty string
                    "${user_email.$ != "" && user_email.$ != null ? user_email.$ : user_phone.$ != "" && user_phone.$ != null ? user_phone.$ : ''}",
                    style: TextStyle(
                      color: MyTheme.grey_color,
                    ),
                  )),
            ],
          )
        : Text(
            "Login/Registration",
            style: TextStyle(
                fontSize: 14,
                color: MyTheme.white,
                fontWeight: FontWeight.bold),
          );
  }

/*
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      /* leading: GestureDetector(
        child: widget.show_back_button
            ? Builder(
                builder: (context) => IconButton(
                  icon:
                      Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 0.0),
                    child: Container(
                      child: Image.asset(
                        'assets/hamburger.png',
                        height: 16,
                        color: MyTheme.dark_grey,
                      ),
                    ),
                  ),
                ),
              ),
      ),*/
      title: Text(
        AppLocalizations.of(context).profile_screen_account,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }*/

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context).loading_text}"),
            ],
          ));
        });
  }
}
