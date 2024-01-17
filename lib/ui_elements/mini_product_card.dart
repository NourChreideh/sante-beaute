import 'package:flutter_svg/svg.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:mlay_dmp_teams/screens/product_details.dart';
import 'package:mlay_dmp_teams/custom/box_decorations.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../custom/toast_component.dart';
import '../helpers/shared_value_helper.dart';
import '../presenter/cart_counter.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../screens/cart.dart';
import '../screens/login.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MiniProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;

  MiniProductCard(
      {Key key,
      this.id,
      this.image,
      this.name,
      this.main_price,
      this.stroked_price,
      this.has_discount})
      : super(key: key);

  @override
  _MiniProductCardState createState() => _MiniProductCardState();
}

class _MiniProductCardState extends State<MiniProductCard> {
  bool _isInWishList = false;
  fetchWishListCheckInfo() async {
    var wishListCheckResponse =
        await WishListRepository().isProductInUserWishList(
      product_id: widget.id,
    );

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  addToWishList() async {
    var wishListCheckResponse =
        await WishListRepository().add(product_id: widget.id);

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  removeFromWishList() async {
    var wishListCheckResponse =
        await WishListRepository().remove(product_id: widget.id);

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    setState(() {});
  }

  onWishTap() {
    if (is_logged_in.$ == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context).common_login_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    if (_isInWishList) {
      _isInWishList = false;
      setState(() {});
      removeFromWishList();
    } else {
      _isInWishList = true;
      setState(() {});
      addToWishList();
    }
  }

  var _variant = "";
  var _colorList = [];
  var _productDetails = null;
  var resp;
  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  fetchProductDetails() async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(id: widget.id);

    if (productDetailsResponse.detailed_products.length > 0) {
      _productDetails = productDetailsResponse.detailed_products[0];
    }

    setState(() {});
  }

  addToCart({mode, context = null, snackbar = null}) async {
    if (is_logged_in.$ == false) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    } else {
      _productDetails.colors.forEach((color) {
        _colorList.add(color);
        resp = _colorList[0].toString().replaceAll("#", "");
      });

      var variantResponse = await ProductRepository()
          .getVariantWiseInfo(id: widget.id, color: resp, variants: "");

      _variant = variantResponse.variant;

      var cartAddResponse = await CartRepository()
          .getCartAddResponse(widget.id, _variant, user_id.$, 1);

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
  }

  @override
  void initState() {
    if (is_logged_in.$ == true) {
      fetchWishListCheckInfo();
      fetchProductDetails();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ProductDetails(id: widget.id);
            }));
          },
          child: Container(
            width: 155,
            decoration: BoxDecorations.buildBoxDecoration_1(radius: 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                        width: double.infinity,
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15.0),
                              topLeft: Radius.circular(15.0),
                            ),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder.png',
                              image: widget.image,
                              fit: BoxFit.cover,
                            ))),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                    child: Text(
                      widget.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
                  //   child: Text(
                  //     "description text",
                  //     textAlign: TextAlign.left,
                  //     overflow: TextOverflow.ellipsis,
                  //     maxLines: 1,
                  //     style: TextStyle(
                  //         color: MyTheme.medium_grey,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w400),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
                    child: Row(
                      children: [
                        Text(
                          widget.main_price,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: MyTheme.accent_color,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 2,
                        ),
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
                      ],
                    ),
                  ),
                ]),
          ),
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
              child: GestureDetector(
                onTap: () {
                  onWishTap();
                },
                child: SvgPicture.asset(
                  "assets/Heart.svg",
                  color: _isInWishList
                      ? Color.fromRGBO(230, 46, 4, 1)
                      : MyTheme.white,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
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
    );
  }
}
