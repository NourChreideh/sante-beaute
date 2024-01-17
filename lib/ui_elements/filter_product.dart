import 'dart:ffi';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlay_dmp_teams/custom/box_decorations.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:mlay_dmp_teams/screens/product_details.dart';
import 'package:mlay_dmp_teams/app_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../custom/toast_component.dart';
import '../helpers/shared_value_helper.dart';
import '../presenter/cart_counter.dart';
import '../repositories/cart_repository.dart';
import '../screens/cart.dart';
import '../screens/login.dart';

class FilterProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;
  var discount;

  FilterProductCard(
      {Key key,
      this.id,
      this.image,
      this.name,
      this.main_price,
      this.stroked_price,
      this.has_discount,
      this.discount})
      : super(key: key);

  @override
  _FilterProductCardState createState() => _FilterProductCardState();
}

class _FilterProductCardState extends State<FilterProductCard> {
  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  addToCart({mode, context = null, snackbar = null}) async {
    if (is_logged_in.$ == false) {
      // ToastComponent.showDialog(AppLocalizations.of(context).common_login_warning, context,
      //     gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    // print(widget.id);
    // print(_variant);
    // print(user_id.$);
    // print(_quantity);

    var cartAddResponse = await CartRepository()
        .getCartAddResponse(widget.id, "Amethyst", user_id.$, 1);

    if (cartAddResponse.result == false) {
      ToastComponent.showDialog(cartAddResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else {
      Provider.of<CartCounter>(context, listen: false).getCount();
      if (snackbar != null && context != null) {
        Scaffold.of(context).showSnackBar(snackbar);
      }
    }
  }

  double discount = 0;

  @override
  void initState() {
    // widget.has_discount
    //     ? discount = (double.parse(widget.main_price) -
    //             double.parse(widget.main_price)) /
    //         double.parse(widget.stroked_price) *
    //         100
    //     : discount = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print((MediaQuery.of(context).size.width - 48 ) / 2);
    return Container(
      height: 295,
      decoration: BoxDecorations.buildBoxDecoration_1(radius: 15).copyWith(),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProductDetails(
                  id: widget.id,
                );
              }));
            },
            child: Column(children: <Widget>[
              AspectRatio(
                aspectRatio: 1.1,
                child: Container(
                    width: double.infinity,
                    //height: 158,
                    child: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15), bottom: Radius.zero),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image: widget.image,
                          fit: BoxFit.cover,
                        ))),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
                      child: Text(
                        widget.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            height: 1.2,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.main_price,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              Text(
                                "4.7",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              SvgPicture.asset("assets/Star.svg"),
                              Text(
                                "(593)",
                                style: TextStyle(
                                  color: MyTheme.grey_color.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
                      child: Row(
                        children: [
                          widget.has_discount
                              ? Text(
                                  widget.stroked_price,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: MyTheme.medium_grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                )
                              : Container(
                                  height: 8.0,
                                ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${AppLocalizations.of(context).discount} ${discount}%",
                            style: TextStyle(
                              color: Color(
                                0xFFFFA000,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: MyTheme.accent_color,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomLeft: Radius.circular(0.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x14000000),
                      offset: Offset(-1, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  "assets/Heart.svg",
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  onPressAddToCart(
                      context,
                      is_logged_in.$ == false
                          ? null
                          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                AppLocalizations.of(context)
                                    .product_details_screen_snackbar_added_to_cart,
                                style: TextStyle(color: MyTheme.font_grey),
                              ),
                              backgroundColor: MyTheme.soft_accent_color,
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: AppLocalizations.of(context)
                                    .product_details_screen_snackbar_show_cart,
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return Cart(has_bottomnav: false);
                                  })).then((value) {});
                                },
                                textColor: MyTheme.accent_color,
                                disabledTextColor: Colors.grey,
                              ),
                            )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: MyTheme.accent_color,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x14000000),
                        offset: Offset(-1, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).add_to_card,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
