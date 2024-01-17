import 'dart:async';

import 'package:mlay_dmp_teams/repositories/cart_repository.dart';
import 'package:flutter/material.dart';

class CartCounter extends ChangeNotifier {
  // StreamController<int> controller;
  int cartCounter = 0;

  // CartCounter() {
  //   controller = StreamController();
  // }
  // StreamSink<int> get addCounter => controller.sink;
  // Stream<int> get getCounter => controller.stream;

  getCount() async {
    var res = await CartRepository().getCartCount();
    cartCounter = res.count;
    // print("****************************************");
    // print(cartCounter);
    notifyListeners();
  }

  dismiss() {
    // controller.close();
  }
}
