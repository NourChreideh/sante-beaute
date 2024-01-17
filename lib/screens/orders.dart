import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mlay_dmp_teams/custom/box_decorations.dart';
import 'package:one_context/one_context.dart';
import 'package:shimmer/shimmer.dart';

import '../custom/useful_elements.dart';
import '../helpers/shared_value_helper.dart';
import '../my_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../repositories/order_repository.dart';
import 'main.dart';
import 'order_details.dart';

class PaymentStatus {
  String option_key;
  String name;

  PaymentStatus(this.option_key, this.name);

  static List<PaymentStatus> getPaymentStatusList() {
    return <PaymentStatus>[
      PaymentStatus(
          '',
          AppLocalizations.of(OneContext().context)
              .order_list_screen_all_payments),
      PaymentStatus('paid',
          AppLocalizations.of(OneContext().context).order_list_screen_paid),
      PaymentStatus('unpaid',
          AppLocalizations.of(OneContext().context).order_list_screen_unpaid),
    ];
  }
}

class DeliveryStatus {
  String option_key;
  String name;

  DeliveryStatus(this.option_key, this.name);

  static List<DeliveryStatus> getDeliveryStatusList() {
    return <DeliveryStatus>[
      DeliveryStatus(
          '',
          AppLocalizations.of(OneContext().context)
              .order_list_screen_all_deliveries),
      DeliveryStatus(
          'confirmed',
          AppLocalizations.of(OneContext().context)
              .order_list_screen_confirmed),
      DeliveryStatus(
          'on_delivery',
          AppLocalizations.of(OneContext().context)
              .order_list_screen_on_delivery),
      DeliveryStatus(
          'delivered',
          AppLocalizations.of(OneContext().context)
              .order_list_screen_delivered),
    ];
  }
}

class Orders extends StatefulWidget {
  const Orders({Key key, this.from_checkout = false}) : super(key: key);
  final bool from_checkout;

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();

  List<PaymentStatus> _paymentStatusList = PaymentStatus.getPaymentStatusList();
  List<DeliveryStatus> _deliveryStatusList =
      DeliveryStatus.getDeliveryStatusList();

  PaymentStatus _selectedPaymentStatus;
  DeliveryStatus _selectedDeliveryStatus;

  List<DropdownMenuItem<PaymentStatus>> _dropdownPaymentStatusItems;
  List<DropdownMenuItem<DeliveryStatus>> _dropdownDeliveryStatusItems;

  //------------------------------------
  List<dynamic> _orderList = [];
  bool _isInitial = true;
  int _page = 1;
  int _totalData = 0;
  bool _showLoadingContainer = false;
  String _defaultPaymentStatusKey = '';
  String _defaultDeliveryStatusKey = '';

  List<dynamic> _orderListOld = [];
  bool _isInitialOld = true;
  int _pageOld = 1;
  int _totalDataOld = 0;
  bool _showLoadingContainerOld = false;

  @override
  void initState() {
    init();
    super.initState();

    fetchDataOld();

    fetchData();

    _xcrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
          _pageOld++;
        });
        _showLoadingContainer = true;
        _showLoadingContainerOld = true;
        fetchData();
        fetchDataOld();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  init() {
    _dropdownPaymentStatusItems =
        buildDropdownPaymentStatusItems(_paymentStatusList);

    _dropdownDeliveryStatusItems =
        buildDropdownDeliveryStatusItems(_deliveryStatusList);

    for (int x = 0; x < _dropdownPaymentStatusItems.length; x++) {
      if (_dropdownPaymentStatusItems[x].value.option_key ==
          _defaultPaymentStatusKey) {
        _selectedPaymentStatus = _dropdownPaymentStatusItems[x].value;
      }
    }

    for (int x = 0; x < _dropdownDeliveryStatusItems.length; x++) {
      if (_dropdownDeliveryStatusItems[x].value.option_key ==
          _defaultDeliveryStatusKey) {
        _selectedDeliveryStatus = _dropdownDeliveryStatusItems[x].value;
      }
    }
  }

  reset() {
    _orderList.clear();
    _isInitial = true;
    _page = 1;
    _totalData = 0;
    _showLoadingContainer = false;
    _orderListOld.clear();
    _isInitialOld = true;
    _pageOld = 1;
    _totalDataOld = 0;
    _showLoadingContainerOld = false;
  }

  resetFilterKeys() {
    _defaultPaymentStatusKey = '';
    _defaultDeliveryStatusKey = '';

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    resetFilterKeys();
    for (int x = 0; x < _dropdownPaymentStatusItems.length; x++) {
      if (_dropdownPaymentStatusItems[x].value.option_key ==
          _defaultPaymentStatusKey) {
        _selectedPaymentStatus = _dropdownPaymentStatusItems[x].value;
      }
    }

    for (int x = 0; x < _dropdownDeliveryStatusItems.length; x++) {
      if (_dropdownDeliveryStatusItems[x].value.option_key ==
          _defaultDeliveryStatusKey) {
        _selectedDeliveryStatus = _dropdownDeliveryStatusItems[x].value;
      }
    }
    setState(() {});
    fetchDataOld();
    fetchData();
  }

  fetchData() async {
    var orderResponse = await OrderRepository().getOrderList(
      page: _page,
      payment_status: _selectedPaymentStatus.option_key,
      // delivery_status: 'delivered'
    );
    // print("or:" + orderResponse.toJson().toString());
    _orderList.addAll(orderResponse.orders);
    _isInitial = false;
    _totalData = orderResponse.meta.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchDataOld() async {
    var orderResponse = await OrderRepository().getOrderList(
        page: _pageOld,
        payment_status: _selectedPaymentStatus.option_key,
        delivery_status: 'delivered');
    // print("or:" + orderResponse.toJson().toString());
    _orderListOld.addAll(orderResponse.orders);
    _isInitialOld = false;
    _totalDataOld = orderResponse.meta.total;
    _showLoadingContainerOld = false;
    if (mounted) setState(() {});
  }

  List<DropdownMenuItem<PaymentStatus>> buildDropdownPaymentStatusItems(
      List _paymentStatusList) {
    List<DropdownMenuItem<PaymentStatus>> items = List();
    for (PaymentStatus item in _paymentStatusList) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(item.name),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<DeliveryStatus>> buildDropdownDeliveryStatusItems(
      List _deliveryStatusList) {
    List<DropdownMenuItem<DeliveryStatus>> items = List();
    for (DeliveryStatus item in _deliveryStatusList) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(item.name),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () {
          if (widget.from_checkout) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Main();
            }));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey.withOpacity(0.1),
          appBar: AppBar(
            backgroundColor: Colors.grey.withOpacity(0.05),
            centerTitle: true,
            leading: Builder(
              builder: (context) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                child: UsefulElements.backToMain(context,
                    go_back: false, color: "black"),
              ),
            ),
            title: Text(
              AppLocalizations.of(context).order,
              style: TextStyle(color: Colors.black),
            ),
            elevation: 0.0,
            titleSpacing: 0,
            bottom: TabBar(
              padding: EdgeInsets.all(8),
              tabs: [
                Tab(
                  text: AppLocalizations.of(context).recent_order,
                ),
                Tab(
                  text: AppLocalizations.of(context).history,
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              (_isInitial && _orderList.length == 0)
                  ? SingleChildScrollView(
                      child: ListView.builder(
                      controller: _scrollController,
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
                  : (_orderList.length > 0)
                      ? RefreshIndicator(
                          color: MyTheme.accent_color,
                          backgroundColor: Colors.white,
                          displacement: 0,
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                              controller: _xcrollController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              itemCount: _orderList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8.0),
                                      height: app_language_rtl.$
                                          ? height * 0.33
                                          : height * 0.3,
                                      width: width,
                                      decoration:
                                          BoxDecorations.buildBoxDecoration_1(),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      // width: width * 0.25,
                                                      height: height * 0.03,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: _orderList[index]
                                                                    .delivery_status_string !=
                                                                "Delivered"
                                                            ? Color.fromRGBO(
                                                                253,
                                                                201,
                                                                68,
                                                                0.3)
                                                            : Color.fromRGBO(40,
                                                                167, 69, 0.3),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: Center(
                                                          child: Text(
                                                            _orderList[index]
                                                                .delivery_status_string,
                                                            style: TextStyle(
                                                                color: _orderList[index]
                                                                            .delivery_status_string !=
                                                                        "Delivered"
                                                                    ? Color(
                                                                        0xFFFDC944)
                                                                    : Color(
                                                                        0xFF28A745)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/Calendar.svg",
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          _orderList[index]
                                                              .date,
                                                          style: TextStyle(
                                                            color: MyTheme
                                                                .grey_color,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 0.5,
                                                      color: MyTheme.grey_color,
                                                      width: width * 0.9,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/Edit.svg",
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                                  context)
                                                              .ref +
                                                          ":",
                                                      style: TextStyle(
                                                        color:
                                                            MyTheme.grey_color,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      _orderList[index].code,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/Profile_image.svg",
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                                  context)
                                                              .receiver_name +
                                                          ":",
                                                      style: TextStyle(
                                                        color:
                                                            MyTheme.grey_color,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      user_name.$,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/Wallet.svg",
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                                  context)
                                                              .payment_method +
                                                          ":",
                                                      style: TextStyle(
                                                        color:
                                                            MyTheme.grey_color,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      _orderList[index]
                                                          .payment_type,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // SizedBox(
                                                //   height: height * 0.01,
                                                // ),
                                                // Row(
                                                //   children: [
                                                //     SvgPicture.asset(
                                                //       "assets/Location_n.svg",
                                                //     ),
                                                //     SizedBox(
                                                //       width: 5,
                                                //     ),
                                                //     Text(
                                                //       "location",
                                                //       style: TextStyle(
                                                //         fontWeight:
                                                //             FontWeight.bold,
                                                //         color: Colors.black,
                                                //         fontSize: 15,
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: width,
                                                  height: 50.0,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return OrderDetails(
                                                          id: _orderList[index]
                                                              .id,
                                                        );
                                                      }));
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(MyTheme
                                                                  .accent_color),
                                                      shadowColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .transparent),
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .show_details,
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        )
                      : _totalData == 0
                          ? Center(
                              child: Text(AppLocalizations.of(context)
                                  .common_no_data_available))
                          : Container(),
              (_isInitialOld && _orderListOld.length == 0)
                  ? SingleChildScrollView(
                      child: ListView.builder(
                      controller: _scrollController,
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
                  : (_orderListOld.length > 0)
                      ? RefreshIndicator(
                          color: MyTheme.accent_color,
                          backgroundColor: Colors.white,
                          displacement: 0,
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                              controller: _xcrollController,
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              itemCount: _orderListOld.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8.0),
                                      height: app_language_rtl.$
                                          ? height * 0.33
                                          : height * 0.3,
                                      width: width,
                                      decoration:
                                          BoxDecorations.buildBoxDecoration_1(),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: width * 0.25,
                                                      height: height * 0.03,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        color: _orderListOld[
                                                                        index]
                                                                    .delivery_status_string !=
                                                                "Delivered"
                                                            ? Color.fromRGBO(
                                                                253,
                                                                201,
                                                                68,
                                                                0.3)
                                                            : Color.fromRGBO(40,
                                                                167, 69, 0.3),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _orderListOld[index]
                                                              .delivery_status_string,
                                                          style: TextStyle(
                                                              color: _orderListOld[
                                                                              index]
                                                                          .delivery_status_string !=
                                                                      "Delivered"
                                                                  ? Color(
                                                                      0xFFFDC944)
                                                                  : Color(
                                                                      0xFF28A745)),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/Calendar.svg",
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          _orderListOld[index]
                                                              .date,
                                                          style: TextStyle(
                                                            color: MyTheme
                                                                .grey_color,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 0.5,
                                                      color: MyTheme.grey_color,
                                                      width: width * 0.9,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/Edit.svg",
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                                  context)
                                                              .ref +
                                                          ":",
                                                      style: TextStyle(
                                                        color:
                                                            MyTheme.grey_color,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      _orderListOld[index].code,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/Profile_image.svg",
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                                  context)
                                                              .receiver_name +
                                                          ":",
                                                      style: TextStyle(
                                                        color:
                                                            MyTheme.grey_color,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      user_name.$,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: height * 0.01,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/Wallet.svg",
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                                  context)
                                                              .payment_method +
                                                          ":",
                                                      style: TextStyle(
                                                        color:
                                                            MyTheme.grey_color,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      _orderListOld[index]
                                                          .payment_type,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // SizedBox(
                                                //   height: height * 0.01,
                                                // ),
                                                // Row(
                                                //   children: [
                                                //     SvgPicture.asset(
                                                //       "assets/Location_n.svg",
                                                //     ),
                                                //     SizedBox(
                                                //       width: 5,
                                                //     ),
                                                //     Text(
                                                //       "location",
                                                //       style: TextStyle(
                                                //         fontWeight:
                                                //             FontWeight.bold,
                                                //         color: Colors.black,
                                                //         fontSize: 15,
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: width,
                                                  height: 50.0,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return OrderDetails(
                                                          id: _orderListOld[
                                                                  index]
                                                              .id,
                                                        );
                                                      }));
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(MyTheme
                                                                  .accent_color),
                                                      shadowColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .transparent),
                                                      shape: MaterialStateProperty
                                                          .all<
                                                              RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .show_details,
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        )
                      : _totalDataOld == 0
                          ? Center(
                              child: Text(AppLocalizations.of(context)
                                  .common_no_data_available))
                          : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
