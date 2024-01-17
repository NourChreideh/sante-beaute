import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlay_dmp_teams/custom/box_decorations.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:mlay_dmp_teams/screens/product_details.dart';
import 'package:mlay_dmp_teams/app_config.dart';
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

class otherProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String main_price;
  String stroked_price;
  bool has_discount;
  var discount;

  otherProductCard(
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
  _otherProductCardState createState() => _otherProductCardState();
}

class _otherProductCardState extends State<otherProductCard> {
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

    if (mounted) setState(() {});
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

  bool _isInWishList = false;
  fetchWishListCheckInfo() async {
    var wishListCheckResponse =
        await WishListRepository().isProductInUserWishList(
      product_id: widget.id,
    );

    //print("p&u:" + widget.id.toString() + " | " + _user_id.toString());
    _isInWishList = wishListCheckResponse.is_in_wishlist;
    if (mounted) setState(() {});
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

  @override
  void initState() {
    // TODO: implement initState
    if (is_logged_in.$ == true) {
      fetchWishListCheckInfo();
      fetchProductDetails();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print((MediaQuery.of(context).size.width - 48 ) / 2);
    return Container(
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
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                          SizedBox(
                            width: 5,
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
      ),
    );
  }
}
