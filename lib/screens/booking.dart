import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import '../custom/box_decorations.dart';
import '../custom/toast_component.dart';
import '../custom/useful_elements.dart';
import '../helpers/shared_value_helper.dart';
import '../my_theme.dart';
import '../repositories/chat_repository.dart';
import '../repositories/order_repository.dart';
import 'chat.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

class allBooking extends StatefulWidget {
  const allBooking({Key key}) : super(key: key);

  @override
  State<allBooking> createState() => _allBookingState();
}

class _allBookingState extends State<allBooking> {
  var _List = [];
  bool _isInitial = true;
  int _totalData = 0;
  int _Page = 1;
  bool _showLoadingContainer = false;
  bool isbook = false;
  TextEditingController sellerChatTitleController = TextEditingController();
  TextEditingController sellerChatMessageController = TextEditingController();
  BuildContext loadingcontext;
  fetchData() async {
    var allBooking = await OrderRepository().reminders();
    _List.addAll(allBooking.reminders);
    _isInitial = false;
    _showLoadingContainer = false;
    if (mounted) {
      setState(() {});
    }
  }

  sendBookData({int id = 0, String status = ""}) async {
    var booking = await OrderRepository().sendBook(id: id, status: status);
    if (booking.message == 'Reminder updated') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.of(context).add_success,
          style: TextStyle(color: MyTheme.font_grey),
        ),
        backgroundColor: MyTheme.soft_accent_color,
        duration: const Duration(seconds: 3),
      ));
    }
    // if (mounted) {
    setState(() {});
    // }
  }

  onTapSellerChat(int id) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            AppLocalizations.of(context)
                                .product_details_screen_seller_chat_title,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: sellerChatTitleController,
                            autofocus: false,
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .product_details_screen_seller_chat_enter_title,
                                hintStyle: TextStyle(
                                    fontSize: 12.0,
                                    color: MyTheme.textfield_grey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 0.5),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(8.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(8.0),
                                  ),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8.0)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context).product_details_screen_seller_chat_messasge} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 55,
                          child: TextField(
                            controller: sellerChatMessageController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)
                                    .product_details_screen_seller_chat_enter_messasge,
                                hintStyle: TextStyle(
                                    fontSize: 12.0,
                                    color: MyTheme.textfield_grey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 0.5),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(8.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(8.0),
                                  ),
                                ),
                                contentPadding: EdgeInsets.only(
                                    right: 16.0,
                                    left: 8.0,
                                    top: 16.0,
                                    bottom: 16.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FlatButton(
                        minWidth: 75,
                        height: 30,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: MyTheme.light_grey, width: 1.0)),
                        child: Text(
                          AppLocalizations.of(context)
                              .common_close_in_all_capital,
                          style: TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: FlatButton(
                        minWidth: 75,
                        height: 30,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: MyTheme.light_grey, width: 1.0)),
                        child: Text(
                          AppLocalizations.of(context)
                              .common_send_in_all_capital,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          print(id);
                          onPressSendMessage(id);
                        },
                      ),
                    )
                  ],
                )
              ],
            ));
  }

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

  showLoginWarning() {
    return ToastComponent.showDialog(
        AppLocalizations.of(context).common_login_warning,
        gravity: Toast.center,
        duration: Toast.lengthLong);
  }

  onPressSendMessage(int id) async {
    if (!is_logged_in.$) {
      showLoginWarning();
      return;
    }
    loading();
    var title = sellerChatTitleController.text.toString();
    var message = sellerChatMessageController.text.toString();

    if (title == "" || message == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)
              .product_details_screen_seller_chat_title_message_empty_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var conversationCreateResponse = await ChatRepository()
        .getCreateConversationResponse(
            product_id: 39, title: title, message: message);

    Navigator.of(loadingcontext).pop();

    if (conversationCreateResponse.result == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)
              .product_details_screen_seller_chat_creation_unable_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    sellerChatTitleController.clear();
    sellerChatMessageController.clear();
    setState(() {});

    print(conversationCreateResponse.shop_name);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Chat(
        conversation_id: conversationCreateResponse.conversation_id,
        messenger_name: AppLocalizations.of(context).mlay,
        messenger_title: conversationCreateResponse.title,
        messenger_image: conversationCreateResponse.shop_logo,
      );
    })).then((value) {
      onPopped(value);
    });
  }

  Future<void> _onPageRefresh() async {
    _List.clear();
    _isInitial = true;
    _showLoadingContainer = true;
    fetchData();
    setState(() {});
  }

  onPopped(value) async {
    _List.clear();
    _isInitial = true;
    _showLoadingContainer = false;
    fetchData();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.01),
        centerTitle: true,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).book_app,
          style: TextStyle(color: Colors.black),
        ),
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            child: UsefulElements.backToMain(context,
                go_back: false, color: "black"),
          ),
        ),
      ),
      body: (_isInitial && _List.length == 0)
          ? SingleChildScrollView(
              child: ListView.builder(
              itemCount: 10,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 14.0),
                  child: Shimmer.fromColors(
                    baseColor: MyTheme.shimmer_base,
                    highlightColor: MyTheme.shimmer_highlighted,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ))
          : (_List.length > 0)
              ? RefreshIndicator(
                  color: MyTheme.accent_color,
                  backgroundColor: Colors.white,
                  onRefresh: _onPageRefresh,
                  displacement: 0,
                  child: ListView.builder(
                      // controller: _xcrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemCount: _List.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              width: width,
                              height: height * 0.36,
                              decoration: BoxDecorations.buildBoxDecoration_1(),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(
                                            //   "description",
                                            //   style: TextStyle(
                                            //     color: MyTheme.accent_color,
                                            //     fontWeight: FontWeight.bold,
                                            //     fontSize: 17,
                                            //   ),
                                            // ),
                                            SizedBox(
                                              height: height * 0.02,
                                            ),
                                            Text(
                                              AppLocalizations.of(context).mlay,
                                              style: TextStyle(
                                                color: MyTheme.grey_color,
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * 0.01,
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/Location.svg"),
                                                SizedBox(
                                                  width: width * 0.01,
                                                ),
                                                Text(
                                                  "${_List[index].location}",
                                                  style: TextStyle(
                                                    color: MyTheme.grey_color,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Image.asset("assets/Logo.png")
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 0.5,
                                        color: MyTheme.grey_color,
                                        width: width * 0.9,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/Calendar.svg",
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "${_List[index].sessionTime.split(' ')[0]}",
                                              style: TextStyle(
                                                color: MyTheme.grey_color,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/Time Square.svg",
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              DateFormat.jm().format(
                                                  DateFormat("hh:mm:ss").parse(
                                                      _List[index]
                                                          .sessionTime
                                                          .split(' ')[1])),
                                              style: TextStyle(
                                                color: MyTheme.grey_color,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: width * 0.2,
                                          height: height * 0.04,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: _List[index].status == 'تمت'
                                                ? Color.fromRGBO(
                                                    40, 167, 69, 0.3)
                                                : Color.fromRGBO(
                                                    253, 201, 68, 0.3),
                                          ),
                                          child: Center(
                                              child: Text(
                                            "${_List[index].status}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color:
                                                    _List[index].status == 'تمت'
                                                        ? Color(0xFF28A745)
                                                        : Color(0xFFFDC944)),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: width,
                                          height: 50.0,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await sendBookData(
                                                  id: _List[index].id,
                                                  status: _List[index].status);
                                              _List.clear();
                                              _isInitial = true;
                                              _showLoadingContainer = true;
                                              fetchData();
                                              setState(() {});
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Color(0xFFFFA000)
                                                          .withOpacity(0.5)),
                                              shadowColor: MaterialStateProperty
                                                  .all<Color>(
                                                      Colors.transparent),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .change_status,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.01,
                                        ),
                                        Container(
                                          width: width,
                                          height: 50.0,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (is_logged_in.$ == false) {
                                                ToastComponent.showDialog(
                                                    "You need to log in",
                                                    gravity: Toast.center,
                                                    duration: Toast.lengthLong);
                                                return;
                                              }

                                              onTapSellerChat(36);
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      MyTheme.accent_color),
                                              shadowColor: MaterialStateProperty
                                                  .all<Color>(
                                                      Colors.transparent),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .talk_us,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                SizedBox(width: 2),
                                                SvgPicture.asset(
                                                    "assets/Sendo.svg")
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      }),
                )
              : _totalData == 0
                  ? Center(
                      child: Text(AppLocalizations.of(context)
                          .common_no_data_available))
                  : Container(),
    );
  }
}
