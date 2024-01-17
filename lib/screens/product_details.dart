import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mlay_dmp_teams/custom/device_info.dart';
import 'package:mlay_dmp_teams/custom/text_styles.dart';
import 'package:mlay_dmp_teams/presenter/cart_counter.dart';
import 'package:mlay_dmp_teams/screens/cart.dart';
import 'package:mlay_dmp_teams/screens/common_webview_screen.dart';
import 'package:mlay_dmp_teams/screens/login.dart';
import 'package:mlay_dmp_teams/screens/product_reviews.dart';
import 'package:mlay_dmp_teams/screens/seller_details.dart';
import 'package:mlay_dmp_teams/ui_elements/list_product_card.dart';
import 'package:mlay_dmp_teams/ui_elements/mini_product_card.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:expandable/expandable.dart';
import 'dart:ui';
import 'package:flutter_html/flutter_html.dart';
import 'package:mlay_dmp_teams/repositories/product_repository.dart';
import 'package:mlay_dmp_teams/repositories/wishlist_repository.dart';
import 'package:mlay_dmp_teams/repositories/cart_repository.dart';
import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/helpers/shimmer_helper.dart';
import 'package:mlay_dmp_teams/helpers/color_helper.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

import 'package:mlay_dmp_teams/custom/toast_component.dart';
import 'package:mlay_dmp_teams/repositories/chat_repository.dart';
import 'package:mlay_dmp_teams/screens/chat.dart';
import 'package:provider/provider.dart';
import 'package:route_transitions/route_transitions.dart';
import 'package:toast/toast.dart';
import 'package:social_share/social_share.dart';
import 'dart:async';
import 'package:mlay_dmp_teams/screens/video_description_screen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mlay_dmp_teams/screens/brand_products.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mlay_dmp_teams/custom/box_decorations.dart';

import '../custom/useful_elements.dart';
import '../repositories/review_repositories.dart';

class ProductDetails extends StatefulWidget {
  int id;

  ProductDetails({Key key, this.id}) : super(key: key);

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  bool _showCopied = false;
  String _appbarPriceString = ". . .";
  int _currentImage = 0;
  ScrollController _mainScrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController _colorScrollController = ScrollController();
  ScrollController _variantScrollController = ScrollController();
  ScrollController _imageScrollController = ScrollController();
  TextEditingController sellerChatTitleController = TextEditingController();
  TextEditingController sellerChatMessageController = TextEditingController();

  double _scrollPosition = 0.0;

  Animation _colorTween;
  AnimationController _ColorAnimationController;

  CarouselController _carouselController = CarouselController();
  BuildContext loadingcontext;
  //init values

  bool _isInWishList = false;
  var _productDetailsFetched = false;
  var _productDetails = null;
  var _productImageList = [];
  var _colorList = [];
  int _selectedColorIndex = 0;
  var _selectedChoices = [];
  var _choiceString = "";
  var _variant = "";
  var _totalPrice;
  var _singlePrice;
  var _singlePriceString;
  int _quantity = 1;
  int _stock = 0;
  int counter = 0;
  List<dynamic> _reviewList = [];
  bool _isInitial = true;
  int _page = 1;
  int _totalData = 0;
  bool _showLoadingContainer = false;

  double opacity = 0;
  int oneStar = 0;
  int twoStars = 0;
  int threeStars = 0;
  int fourStars = 0;
  int fiveStars = 0;

  List<dynamic> _relatedProducts = [];
  bool _relatedProductInit = false;
  List<dynamic> _topProducts = [];
  bool _topProductInit = false;
  bool showMore = false;

  @override
  void initState() {
    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));

    _colorTween = ColorTween(begin: Colors.transparent, end: Colors.white)
        .animate(_ColorAnimationController);

    _mainScrollController.addListener(() {
      _scrollPosition = _mainScrollController.position.pixels;

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;
        }
      }

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;

          if (100 > _scrollPosition) {
            opacity = 1;
          }
        }
      }
      print("opachity{} $_scrollPosition");

      setState(() {});
    });
    fetchAll();
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _variantScrollController.dispose();
    _imageScrollController.dispose();
    _colorScrollController.dispose();
    super.dispose();
  }

  fetchAll() {
    fetchProductDetails();
    if (is_logged_in.$ == true) {
      fetchWishListCheckInfo();
    }
    fetchRelatedProducts();
    fetchTopProducts();
    fetchData();
  }

  fetchData() async {
    var reviewResponse = await ReviewRepository().getReviewResponse(
      widget.id,
      page: _page,
    );
    _reviewList.addAll(reviewResponse.reviews);
    _isInitial = false;
    _totalData = reviewResponse.meta.total;
    _showLoadingContainer = false;
    for (int i = 0; i < _reviewList.length; i++) {
      // print(_reviewList[i].rating);
      if (_reviewList[i].rating == 1.0) {
        oneStar++;
      }
      if (_reviewList[i].rating == 2.0) {
        twoStars++;
      }
      if (_reviewList[i].rating == 3.0) {
        threeStars++;
      }
      if (_reviewList[i].rating == 4.0) {
        fourStars++;
      }
      if (_reviewList[i].rating == 5.0) {
        fiveStars++;
      }
    }
    setState(() {});
  }

  fetchProductDetails() async {
    var productDetailsResponse =
        await ProductRepository().getProductDetails(id: widget.id);

    if (productDetailsResponse.detailed_products.length > 0) {
      _productDetails = productDetailsResponse.detailed_products[0];
      sellerChatTitleController.text =
          productDetailsResponse.detailed_products[0].name;
    }

    setProductDetailValues();

    setState(() {});
  }

  fetchRelatedProducts() async {
    var relatedProductResponse =
        await ProductRepository().getRelatedProducts(id: widget.id);
    _relatedProducts.addAll(relatedProductResponse.products);
    _relatedProductInit = true;

    setState(() {});
  }

  fetchTopProducts() async {
    var topProductResponse =
        await ProductRepository().getTopFromThisSellerProducts(id: widget.id);
    _topProducts.addAll(topProductResponse.products);
    _topProductInit = true;
  }

  setProductDetailValues() {
    if (_productDetails != null) {
      _appbarPriceString = _productDetails.price_high_low;
      _singlePrice = _productDetails.calculable_price;
      _singlePriceString = _productDetails.main_price;
      calculateTotalPrice();
      _stock = _productDetails.current_stock;
      _productDetails.photos.forEach((photo) {
        _productImageList.add(photo.path);
      });

      _productDetails.choice_options.forEach((choice_opiton) {
        _selectedChoices.add(choice_opiton.options[0]);
      });
      _productDetails.colors.forEach((color) {
        _colorList.add(color);
      });

      setChoiceString();

      if (_productDetails.colors.length > 0 ||
          _productDetails.choice_options.length > 0) {
        fetchAndSetVariantWiseInfo(change_appbar_string: true);
      }
      _productDetailsFetched = true;

      setState(() {});
    }
  }

  setChoiceString() {
    _choiceString = _selectedChoices.join(",").toString();
    // print(_choiceString);
    setState(() {});
  }

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

  fetchAndSetVariantWiseInfo({bool change_appbar_string = true}) async {
    var color_string = _colorList.length > 0
        ? _colorList[_selectedColorIndex].toString().replaceAll("#", "")
        : "";

    /*print("color string: "+color_string);
    return;*/
    // print(color_string);
    // print(_choiceString);
    var variantResponse = await ProductRepository().getVariantWiseInfo(
        id: widget.id, color: color_string, variants: _choiceString);

    // print("vr" + variantResponse.toJson().toString());
    // return;

    // _singlePrice = variantResponse.price;
    _stock = variantResponse.stock;
    if (_quantity > _stock) {
      _quantity = _stock;
      setState(() {});
    }

    _variant = variantResponse.variant;
    // print(_variant);
    setState(() {});

    calculateTotalPrice();
    _singlePriceString = variantResponse.price_string;

    if (change_appbar_string) {
      _appbarPriceString = "${variantResponse.variant} ${_singlePriceString}";
    }

    int pindex = 0;
    _productDetails.photos.forEach((photo) {
      //print('con:'+ (photo.variant == _variant && variantResponse.image != "").toString());
      if (photo.variant == _variant && variantResponse.image != "") {
        _currentImage = pindex;
        _carouselController.jumpToPage(pindex);
      }

      pindex++;
    });

    setState(() {});
  }

  reset() {
    restProductDetailValues();
    _currentImage = 0;
    _productImageList.clear();
    _colorList.clear();
    _selectedChoices.clear();
    _relatedProducts.clear();
    _topProducts.clear();
    _choiceString = "";
    _variant = "";
    _selectedColorIndex = 0;
    _quantity = 1;
    _productDetailsFetched = false;
    _isInWishList = false;
    sellerChatTitleController.clear();
    _reviewList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    oneStar = 0;
    twoStars = 0;
    threeStars = 0;
    fourStars = 0;
    fiveStars = 0;
    setState(() {});
  }

  restProductDetailValues() {
    _appbarPriceString = " . . .";
    _productDetails = null;
    _productImageList.clear();
    _currentImage = 0;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  calculateTotalPrice() {
    _totalPrice = (_singlePrice * _quantity).toStringAsFixed(2);
    setState(() {});
  }

  _onVariantChange(_choice_options_index, value) {
    _selectedChoices[_choice_options_index] = value;
    setChoiceString();
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  _onColorChange(index) {
    _selectedColorIndex = index;
    setState(() {});
    fetchAndSetVariantWiseInfo();
  }

  onPressAddToCart(context, snackbar) {
    addToCart(mode: "add_to_cart", context: context, snackbar: snackbar);
  }

  onPressBuyNow(context) {
    addToCart(mode: "buy_now", context: context);
  }

  addToCart({mode, context = null, snackbar = null}) async {
    if (is_logged_in.$ == false) {
      // ToastComponent.showDialog(AppLocalizations.of(context).common_login_warning, context,
      //     gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }

    var cartAddResponse = await CartRepository()
        .getCartAddResponse(widget.id, _variant, user_id.$, _quantity);

    if (cartAddResponse.result == false) {
      ToastComponent.showDialog(cartAddResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else {
      Provider.of<CartCounter>(context, listen: false).getCount();

      if (mode == "add_to_cart") {
        if (snackbar != null && context != null) {
          Scaffold.of(context).showSnackBar(snackbar);
        }
        reset();
        fetchAll();
      } else if (mode == 'buy_now') {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Cart(has_bottomnav: false);
        })).then((value) {
          onPopped(value);
        });
      }
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  onCopyTap(setState) {
    setState(() {
      _showCopied = true;
    });
    Timer timer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showCopied = false;
      });
    });
  }

  onPressShare(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: FlatButton(
                          minWidth: 75,
                          height: 26,
                          color: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side:
                                  BorderSide(color: Colors.black, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)
                                .product_details_screen_copy_product_link,
                            style: TextStyle(
                              color: MyTheme.medium_grey,
                            ),
                          ),
                          onPressed: () {
                            onCopyTap(setState);
                            SocialShare.copyToClipboard(_productDetails.link);
                          },
                        ),
                      ),
                      _showCopied
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                AppLocalizations.of(context).common_copied,
                                style: TextStyle(
                                    color: MyTheme.medium_grey, fontSize: 12),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: FlatButton(
                          minWidth: 75,
                          height: 26,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side:
                                  BorderSide(color: Colors.black, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)
                                .product_details_screen_share_options,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            print("share links ${_productDetails.link}");
                            SocialShare.shareOptions(_productDetails.link);
                          },
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
                      padding: app_language_rtl.$
                          ? EdgeInsets.only(left: 8.0)
                          : EdgeInsets.only(right: 8.0),
                      child: FlatButton(
                        minWidth: 75,
                        height: 30,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: MyTheme.font_grey, width: 1.0)),
                        child: Text(
                          "CLOSE",
                          style: TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  onTapSellerChat() {
    return showDialog(
        context: context,
        builder: (_) => Directionality(
              textDirection:
                  app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
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
                            onPressSendMessage();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
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

  onPressSendMessage() async {
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
            product_id: widget.id, title: title, message: message);

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

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Chat(
        conversation_id: conversationCreateResponse.conversation_id,
        messenger_name: conversationCreateResponse.shop_name,
        messenger_title: conversationCreateResponse.title,
        messenger_image: conversationCreateResponse.shop_logo,
      );
      ;
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    SnackBar _addedToCartSnackbar = SnackBar(
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
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Cart(has_bottomnav: false);
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: MyTheme.accent_color,
        disabledTextColor: Colors.grey,
      ),
    );

    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: Colors.grey.withOpacity(0.03),
          appBar: AppBar(
            backgroundColor: Colors.grey.withOpacity(0.01),
            centerTitle: true,
            elevation: 0,
            title: Text(
              AppLocalizations.of(context).products_details,
              style: TextStyle(color: Colors.black),
            ),
            leading: Builder(
              builder: (context) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                child: UsefulElements.backToMain(context,
                    go_back: false, color: "black"),
              ),
            ),
          ),
          extendBody: true,
          bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: buildBottomAppBar(context, _addedToCartSnackbar)),
          //appBar: buildAppBar(statusBarHeight, context),
          body: RefreshIndicator(
            color: MyTheme.accent_color,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white.withOpacity(opacity),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  //titleSpacing: 0,
                  title: Row(
                    children: [
                      // Builder(
                      //   builder: (context) => InkWell(
                      //     onTap: () {
                      //       return Navigator.of(context).pop();
                      //     },
                      //     child: Container(
                      //       decoration: BoxDecorations
                      //           .buildCircularButtonDecoration_1(),
                      //       width: 36,
                      //       height: 36,
                      //       child: Center(
                      //         child: Icon(
                      //           CupertinoIcons.arrow_left,
                      //           color: MyTheme.dark_font_grey,
                      //           size: 20,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      //Show product name in appbar
                      AnimatedOpacity(
                          opacity: _scrollPosition > 350 ? 1 : 0,
                          duration: Duration(milliseconds: 200),
                          child: Container(
                              padding: EdgeInsets.only(left: 8),
                              width: DeviceInfo(context).width / 2,
                              child: Text(
                                "${_productDetails != null ? _productDetails.name : ''}",
                                style: TextStyle(
                                    color: MyTheme.dark_font_grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ))),
                      Spacer(),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(context,
                      //         MaterialPageRoute(builder: (context) {
                      //       return Cart(has_bottomnav: false);
                      //     })).then((value) {
                      //       onPopped(value);
                      //     });
                      //   },
                      //   child: Container(
                      //     decoration:
                      //         BoxDecorations.buildCircularButtonDecoration_1(),
                      //     width: 36,
                      //     height: 36,
                      //     child: Badge(
                      //       toAnimate: true,
                      //       stackFit: StackFit.loose,
                      //       shape: BadgeShape.circle,
                      //       badgeColor: MyTheme.accent_color,
                      //       borderRadius: BorderRadius.circular(10),
                      //       child: Image.asset(
                      //         "assets/cart.png",
                      //         color: MyTheme.dark_font_grey,
                      //         height: 16,
                      //       ),
                      //       padding: EdgeInsets.all(8),
                      //       badgeContent: Consumer<CartCounter>(
                      //         builder: (context, cart, child) {
                      //           return Text(
                      //             "${cart.cartCounter}",
                      //             style: TextStyle(
                      //                 fontSize: 12, color: Colors.white),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(width: 15),
                      // InkWell(
                      //   onTap: () {
                      //     onPressShare(context);
                      //   },
                      //   child: Container(
                      //     decoration:
                      //         BoxDecorations.buildCircularButtonDecoration_1(),
                      //     width: 36,
                      //     height: 36,
                      //     child: Center(
                      //       child: Icon(
                      //         Icons.share_outlined,
                      //         color: MyTheme.dark_font_grey,
                      //         size: 16,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          onWishTap();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            color: MyTheme.accent_color,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 20,
                                spreadRadius: 0.0,
                                offset: Offset(0.0,
                                    10.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          width: 38,
                          height: 38,
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/Heart.svg",
                              color: _isInWishList
                                  ? Color.fromRGBO(230, 46, 4, 1)
                                  : MyTheme.white,
                            ),
                            //  Icon(
                            //   FontAwesome.heart,
                            //   color: _isInWishList
                            //       ? Color.fromRGBO(230, 46, 4, 1)
                            //       : MyTheme.dark_font_grey,
                            //   size: 16,
                            // ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  expandedHeight: 360.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: buildProductSliderImageSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    //padding: EdgeInsets.symmetric(horizontal: 14),
                    // decoration: BoxDecorations.buildBoxDecoration_1(),
                    // margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //
                        _productDetails != null
                            ? buildDescRow1()
                            : ShimmerHelper().buildBasicShimmer(
                                height: 30.0,
                              ),

                        _productDetails != null
                            ? buildMainPriceRow1()
                            : ShimmerHelper().buildBasicShimmer(
                                height: 30.0,
                              ),

                        // Padding(
                        //   padding:
                        //       EdgeInsets.only(top: 15, left: 14, right: 14),
                        //   child: _productDetails != null
                        //       ? buildMainPriceRow()
                        //       : ShimmerHelper().buildBasicShimmer(
                        //           height: 30.0,
                        //         ),
                        // ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: Color(0xFFC1C8CF),
                        ),

                        // Visibility(
                        //   visible: club_point_addon_installed.$,
                        //   child: Padding(
                        //     padding:
                        //         EdgeInsets.only(top: 14, left: 14, right: 14),
                        //     child: _productDetails != null
                        //         ? buildClubPointRow()
                        //         : ShimmerHelper().buildBasicShimmer(
                        //             height: 30.0,
                        //           ),
                        //   ),
                        // ),
                        // Padding(
                        //   padding:
                        //       EdgeInsets.only(top: 14, left: 14, right: 14),
                        //   child: _productDetails != null
                        //       ? buildBrandRow()
                        //       : ShimmerHelper().buildBasicShimmer(
                        //           height: 50.0,
                        //         ),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(top: 14),
                        //   child: _productDetails != null
                        //       ? buildSellerRow(context)
                        //       : ShimmerHelper().buildBasicShimmer(
                        //           height: 50.0,
                        //         ),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //       top: 14,
                        //       left: app_language_rtl.$ ? 0 : 14,
                        //       right: app_language_rtl.$ ? 14 : 0),
                        //   child: _productDetails != null
                        //       ? buildChoiceOptionList()
                        //       : buildVariantShimmers(),
                        // ),
                        // Padding(
                        //   padding:
                        //       EdgeInsets.only(top: 14, left: 14, right: 14),
                        //   child: _productDetails != null
                        //       ? (_colorList.length > 0
                        //           ? buildColorRow()
                        //           : Container())
                        //       : ShimmerHelper().buildBasicShimmer(
                        //           height: 30.0,
                        //         ),
                        // ),
                        // Padding(
                        //   padding:
                        //       EdgeInsets.only(top: 14, left: 14, right: 14),
                        //   child: _productDetails != null
                        //       ? buildQuantityRow()
                        //       : ShimmerHelper().buildBasicShimmer(
                        //           height: 30.0,
                        //         ),
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(top: 14, bottom: 14),
                        //   child: _productDetails != null
                        //       ? buildTotalPriceRow()
                        //       : ShimmerHelper().buildBasicShimmer(
                        //           height: 30.0,
                        //         ),
                        // ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: MyTheme.white,
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  20.0,
                                  16.0,
                                  0.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .product_details_screen_description,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  8.0,
                                  0.0,
                                  8.0,
                                  8.0,
                                ),
                                child: _productDetails != null
                                    ? buildExpandableDescription()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child:
                                            ShimmerHelper().buildBasicShimmer(
                                          height: 60.0,
                                        )),
                              ),
                            ],
                          ),
                        ),
                        // divider(),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? (_colorList.length > 0
                                  ? buildColorRow()
                                  : Container())
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: Text(
                            AppLocalizations.of(context).rev_people,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 0, left: 14, right: 14),
                                  child: Text(
                                    AppLocalizations.of(context).general_rev,
                                    style: TextStyle(
                                        color: MyTheme.dark_grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _reviewList.length > 0
                                        ? Text(
                                            "${_reviewList.length}",
                                            style: TextStyle(
                                                color: MyTheme.dark_grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Text(
                                            "0",
                                            style: TextStyle(
                                                color: MyTheme.dark_grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  start: 5, end: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "5",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SvgPicture.asset("assets/Star (2).svg"),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        height: 15,
                                        width: width * 0.38,
                                        child: FAProgressBar(
                                          currentValue:
                                              double.parse("$fiveStars"),
                                          size: 25,
                                          maxValue: double.parse(
                                              "${_reviewList.length}"),
                                          changeColorValue: 100,
                                          backgroundColor: Color(0xFFC1C8CF),
                                          progressColor: Color(0xFF38AC04),
                                          animatedDuration:
                                              const Duration(milliseconds: 300),
                                          direction: Axis.horizontal,
                                          // verticalDirection: VerticalDirection.up,
                                          displayText: '',
                                          formatValueFixed: 2,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        width: width * 0.07,
                                        child: Text(
                                          "($fiveStars)",
                                          style: TextStyle(
                                            color: MyTheme.grey_color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "4",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SvgPicture.asset("assets/Star (3).svg"),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        height: 15,
                                        width: width * 0.38,
                                        child: FAProgressBar(
                                          currentValue:
                                              double.parse("$fourStars"),
                                          size: 25,
                                          maxValue: double.parse(
                                              "${_reviewList.length}"),
                                          changeColorValue: 100,
                                          backgroundColor: Color(0xFFC1C8CF),
                                          progressColor: Color(0xFF9BC03A),
                                          animatedDuration:
                                              const Duration(milliseconds: 300),
                                          direction: Axis.horizontal,
                                          // verticalDirection: VerticalDirection.up,
                                          displayText: '',
                                          formatValueFixed: 2,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        width: width * 0.07,
                                        child: Text(
                                          "($fourStars)",
                                          style: TextStyle(
                                            color: MyTheme.grey_color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "3",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SvgPicture.asset("assets/Star (4).svg"),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        height: 15,
                                        width: width * 0.38,
                                        child: FAProgressBar(
                                          currentValue:
                                              double.parse("$threeStars"),
                                          size: 25,
                                          maxValue: double.parse(
                                              "${_reviewList.length}"),
                                          changeColorValue: 100,
                                          backgroundColor: Color(0xFFC1C8CF),
                                          progressColor: Color(0xFFF3AE3A),
                                          animatedDuration:
                                              const Duration(milliseconds: 300),
                                          direction: Axis.horizontal,
                                          // verticalDirection: VerticalDirection.up,
                                          displayText: '',
                                          formatValueFixed: 2,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        width: width * 0.07,
                                        child: Text(
                                          "($threeStars)",
                                          style: TextStyle(
                                            color: MyTheme.grey_color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "2",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SvgPicture.asset("assets/Star (5).svg"),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        height: 15,
                                        width: width * 0.38,
                                        child: FAProgressBar(
                                          currentValue:
                                              double.parse("$twoStars"),
                                          size: 25,
                                          maxValue: double.parse(
                                              "${_reviewList.length}"),
                                          changeColorValue: 100,
                                          backgroundColor: Color(0xFFC1C8CF),
                                          progressColor: Color(0xFFF46C31),
                                          animatedDuration:
                                              const Duration(milliseconds: 300),
                                          direction: Axis.horizontal,
                                          // verticalDirection: VerticalDirection.up,
                                          displayText: '',
                                          formatValueFixed: 2,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        width: width * 0.07,
                                        child: Text(
                                          "($twoStars)",
                                          style: TextStyle(
                                            color: MyTheme.grey_color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "1",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SvgPicture.asset("assets/Star (6).svg"),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        height: 15,
                                        width: width * 0.38,
                                        child: FAProgressBar(
                                          currentValue:
                                              double.parse("$oneStar"),
                                          size: 25,
                                          maxValue: double.parse(
                                              "${_reviewList.length}"),
                                          changeColorValue: 100,
                                          backgroundColor: Color(0xFFC1C8CF),
                                          progressColor: Color(0xFFF43B12),
                                          animatedDuration:
                                              const Duration(milliseconds: 300),
                                          direction: Axis.horizontal,
                                          // verticalDirection: VerticalDirection.up,
                                          displayText: '',
                                          formatValueFixed: 2,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      SizedBox(
                                        width: width * 0.07,
                                        child: Text(
                                          "($oneStar)",
                                          style: TextStyle(
                                            color: MyTheme.grey_color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),

                        SizedBox(
                          height: 30,
                        ),
                        _isInitial && _reviewList.length == 0
                            ? SingleChildScrollView(
                                child: ShimmerHelper().buildListShimmer(
                                    item_count: 10, item_height: 75.0))
                            : _reviewList.length > 0
                                ? SizedBox(
                                    height: height / (_reviewList.length + 4.5),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: _reviewList.length <= 3
                                            ? _reviewList.length
                                            : showMore
                                                ? _reviewList.length
                                                : 0,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .08),
                                                            blurRadius: 20,
                                                            spreadRadius: 0.0,
                                                            offset: Offset(0.0,
                                                                10.0), // shadow direction: bottom right
                                                          )
                                                        ],
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 22,
                                                        backgroundColor:
                                                            Colors.white,
                                                        child: CircleAvatar(
                                                          radius: 19.0,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  _reviewList[
                                                                          index]
                                                                      .avatar),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 3,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _reviewList[index]
                                                              .user_name,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14),
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        _productDetails != null
                                                            ? RatingBar(
                                                                itemSize: 15.0,
                                                                ignoreGestures:
                                                                    true,
                                                                initialRating:
                                                                    _reviewList[
                                                                            index]
                                                                        .rating,
                                                                direction: Axis
                                                                    .horizontal,
                                                                allowHalfRating:
                                                                    false,
                                                                itemCount: 5,
                                                                ratingWidget:
                                                                    RatingWidget(
                                                                  full: Icon(
                                                                      FontAwesome
                                                                          .star,
                                                                      color: Color(
                                                                          0xFF38AC04)),
                                                                  half: Icon(
                                                                      FontAwesome
                                                                          .star_half,
                                                                      color: Color(
                                                                          0xFF38AC04)),
                                                                  empty: Icon(
                                                                      FontAwesome
                                                                          .star,
                                                                      color: Color.fromRGBO(
                                                                          224,
                                                                          224,
                                                                          225,
                                                                          1)),
                                                                ),
                                                                itemPadding:
                                                                    EdgeInsets.only(
                                                                        right:
                                                                            1.0),
                                                                onRatingUpdate:
                                                                    (rating) {
                                                                  //print(rating);
                                                                },
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                              _reviewList[index]
                                                                  .time,
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0XffC1C8CF)))
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(
                                                          start: width * 0.1,
                                                          top: 10),
                                                  child: Text(
                                                    _reviewList[index].comment,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Container(
                                                    width: double.infinity,
                                                    height: 1,
                                                    color: Color(0XffC1C8CF))
                                              ],
                                            ),
                                          );
                                        }),
                                  )
                                : _totalData == 0
                                    ? Container(
                                        height: 100,
                                        child: Center(
                                            child: Text(AppLocalizations.of(
                                                    context)
                                                .product_reviews_screen_no_reviews_yet)),
                                      )
                                    : Container(),
                        /* InkWell(
                          onTap: () {
                            if (_productDetails.video_link == "") {
                              ToastComponent.showDialog(
                                  AppLocalizations.of(context)
                                      .product_details_screen_video_not_available,
                                  gravity: Toast.center,
                                  duration: Toast.lengthLong);
                              return;
                            }

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return VideoDescription(
                                url: _productDetails.video_link,
                              );
                            })).then((value) {
                              onPopped(value);
                            });
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .product_details_screen_video,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),*/
                        // SizedBox(
                        //   height: 10,
                        // ),
                        _reviewList.length > 3
                            ? GestureDetector(
                                onTap: () {
                                  showMore = true;
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)
                                          .show_more_reviews,
                                      style: TextStyle(
                                          color: MyTheme.accent_color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),

                        SizedBox(
                          height: 20,
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ProductReviews(id: widget.id);
                            })).then((value) {
                              onPopped(value);
                            });
                          },
                          child: Container(
                            color: MyTheme.grey_color.withOpacity(0.1),
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .product_details_screen_reviews,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: MyTheme.dark_font_grey,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        divider(),
                        /* InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/seller-policy",
                                page_name: AppLocalizations.of(context)
                                    .product_details_screen_seller_policy,
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .product_details_screen_seller_policy,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/return-policy",
                                page_name: AppLocalizations.of(context)
                                    .product_details_screen_return_policy,
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .product_details_screen_return_policy,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/support-policy",
                                page_name: AppLocalizations.of(context)
                                    .product_details_screen_support_policy,
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .product_details_screen_support_policy,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),*/
                        // divider(),
                      ]),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18.0,
                        24.0,
                        18.0,
                        0.0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)
                            .product_details_screen_products_may_like,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    buildProductsMayLikeList()
                  ]),
                ),

                //Top selling product
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18.0,
                        24.0,
                        18.0,
                        0.0,
                      ),
                      // child: Text(
                      //   AppLocalizations.of(context)
                      //       .top_selling_products_screen_top_selling_products,
                      //   style: TextStyle(
                      //       color: MyTheme.dark_font_grey,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w600),
                      // ),
                    ),
                    /* Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      child: buildTopSellingProductList(),
                    ),*/
                    Container(
                      height: 83,
                    )
                  ]),
                )
              ],
            ),
          )),
    );
  }

  Widget buildSellerRow(BuildContext context) {
    //print("sl:" +  _productDetails.shop_logo);
    return Container(
      color: MyTheme.light_grey,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          _productDetails.added_by == "admin"
              ? Container()
              : InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SellerDetails(
                                  id: _productDetails.shop_id,
                                )));
                  },
                  child: Padding(
                    padding: app_language_rtl.$
                        ? EdgeInsets.only(left: 8.0)
                        : EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                            color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                        //shape: BoxShape.rectangle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image: _productDetails.shop_logo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
          Container(
            width: MediaQuery.of(context).size.width * (.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).product_details_screen_seller,
                    style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1),
                    )),
                Text(
                  _productDetails.shop_name,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          Spacer(),
          Visibility(
            visible: conversation_system_status.$,
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecorations.buildCircularButtonDecoration_1(),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (is_logged_in == false) {
                            ToastComponent.showDialog("You need to log in",
                                gravity: Toast.center,
                                duration: Toast.lengthLong);
                            return;
                          }

                          onTapSellerChat();
                        },
                        child: Image.asset('assets/chat.png',
                            height: 16, width: 16, color: MyTheme.dark_grey)),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 40,
      color: MyTheme.amber,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Padding(
              padding: app_language_rtl.$
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: Container(
                width: 75,
                child: Text(
                  AppLocalizations.of(context)
                      .product_details_screen_total_price,
                  style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              _productDetails.currency_symbol + _totalPrice.toString(),
              style: TextStyle(
                  color: MyTheme.accent_color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Row buildQuantityRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 75,
            child: Text(
              AppLocalizations.of(context).product_details_screen_quantity,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Container(
          height: 36,
          width: 120,
          /*decoration: BoxDecoration(
              border:
                  Border.all(color: Color.fromRGBO(222, 222, 222, 1), width: 1),
              borderRadius: BorderRadius.circular(36.0),
              color: Colors.white),*/
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              buildQuantityDownButton(),
              Container(
                  width: 36,
                  child: Center(
                      child: Text(
                    _quantity.toString(),
                    style: TextStyle(fontSize: 18, color: MyTheme.dark_grey),
                  ))),
              buildQuantityUpButton()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "(${_stock} ${AppLocalizations.of(context).product_details_screen_available})",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Padding buildVariantShimmers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        0.0,
        8.0,
        0.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildChoiceOptionList() {
    return ListView.builder(
      itemCount: _productDetails.choice_options.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: buildChoiceOpiton(_productDetails.choice_options, index),
        );
      },
    );
  }

  buildChoiceOpiton(choice_options, choice_options_index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0.0,
        14.0,
        0.0,
        0.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: app_language_rtl.$
                ? EdgeInsets.only(left: 8.0)
                : EdgeInsets.only(right: 8.0),
            child: Container(
              width: 75,
              child: Text(
                choice_options[choice_options_index].title,
                style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - (107 + 45),
            child: Scrollbar(
              controller: _variantScrollController,
              isAlwaysShown: false,
              child: Wrap(
                children: List.generate(
                    choice_options[choice_options_index].options.length,
                    (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: 75,
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: buildChoiceItem(
                              choice_options[choice_options_index]
                                  .options[index],
                              choice_options_index,
                              index),
                        ))),
              ),

              /*ListView.builder(
                itemCount: choice_options[choice_options_index].options.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return
                },
              ),*/
            ),
          )
        ],
      ),
    );
  }

  buildChoiceItem(option, choice_options_index, index) {
    return Padding(
      padding: app_language_rtl.$
          ? EdgeInsets.only(left: 8.0)
          : EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          _onVariantChange(choice_options_index, option);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: _selectedChoices[choice_options_index] == option
                    ? MyTheme.accent_color
                    : MyTheme.noColor,
                width: 1.5),
            borderRadius: BorderRadius.circular(3.0),
            color: MyTheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(0.0, 3.0), // shadow direction: bottom right
              )
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                    color: _selectedChoices[choice_options_index] == option
                        ? MyTheme.accent_color
                        : Color.fromRGBO(224, 224, 225, 1),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildColorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: app_language_rtl.$
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: Text(
                AppLocalizations.of(context).product_color,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
            Container(
              alignment: app_language_rtl.$
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              height: 40,
              // width: MediaQuery.of(context).size.width - (107 + 44),
              child: Scrollbar(
                controller: _colorScrollController,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      width: 5,
                    );
                  },
                  itemCount: _colorList.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildColorItem(index),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
        /* Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).mod_number,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ],
            ),
            Container(
              alignment: app_language_rtl.$
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              height: 40,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  "${_productDetails.unit}",
                  maxLines: 3,
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Color(0xFF737A82),
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
              ),
            )
          ],
        ),*/
      ],
    );
  }

  Widget buildColorItem(index) {
    return InkWell(
      onTap: () {
        _onColorChange(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: _selectedColorIndex == index ? 30 : 25,
        height: _selectedColorIndex == index ? 30 : 25,
        decoration: BoxDecoration(
          // border: Border.all(
          //     color: _selectedColorIndex == index
          //         ? Colors.purple
          //         : Colors.white,
          //     width: 1),
          borderRadius: BorderRadius.circular(6.0),
          color: ColorHelper.getColorFromColorCode(_colorList[index]),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(_selectedColorIndex == index ? 0.25 : 0.12),
              blurRadius: 10,
              spreadRadius: 2.0,
              offset: Offset(0.0, 6.0), // shadow direction: bottom right
            )
          ],
        ),
        child: _selectedColorIndex == index
            ? buildColorCheckerContainer()
            : Container(
                height: 25,
              ),
        /*Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
                // border: Border.all(
                //     color: Color.fromRGBO(222, 222, 222, 1), width: 1),
               // borderRadius: BorderRadius.circular(16.0),
                color: ColorHelper.getColorFromColorCode(_colorList[index])),
            child: _selectedColorIndex == index
                ? buildColorCheckerContainer()
                : Container(),
          ),
        ),*/
      ),
    );
  }

  buildColorCheckerContainer() {
    return Padding(
        padding: const EdgeInsets.all(3),
        child: /*Icon(FontAwesome.check, color: Colors.white, size: 16),*/
            Image.asset(
          "assets/white_tick.png",
          width: 16,
          height: 16,
        ));
  }

  Widget buildClubPointRow() {
    return Container(
      constraints: BoxConstraints(maxWidth: 130),
      //width: ,
      decoration: BoxDecoration(
          //border: Border.all(color: MyTheme.golden, width: 1),
          borderRadius: BorderRadius.circular(6.0),
          color:
              //Colors.red,),
              Color.fromRGBO(253, 235, 212, 1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/clubpoint.png",
                  width: 18,
                  height: 12,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  AppLocalizations.of(context)
                      .product_details_screen_club_point,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 10),
                ),
              ],
            ),
            Text(
              _productDetails.earn_point.toString(),
              style: TextStyle(color: MyTheme.golden, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  Row buildMainPriceRow1() {
    return Row(
      children: [
        _stock != null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 110,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFD0EFFD)),
                  child: Center(
                    child: Text(
                      "${_stock} ${AppLocalizations.of(context).product_details_screen_available}",
                      style: TextStyle(
                        color: MyTheme.accent_color,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        SizedBox(
          width: 5,
        ),
        _productDetails != null
            ? buildRatingAndWishButtonRow()
            : ShimmerHelper().buildBasicShimmer(
                height: 30.0,
              ),
      ],
    );
  }

  buildDescRow1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14, left: 14, right: 14),
          child: _productDetails != null
              ? Text(
                  _productDetails.name,
                  style: TextStyles.smallTitleTexStyle(),
                  maxLines: 2,
                )
              : ShimmerHelper().buildBasicShimmer(
                  height: 30.0,
                ),
        ),
        // buildRatingAndWishButtonRow(),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 14, left: 14, right: 14),
              child: Text(
                AppLocalizations.of(context).total_price,
                style: TextStyle(
                  color: MyTheme.font_grey,
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            _productDetails != null
                ? buildMainPriceRow()
                : ShimmerHelper().buildBasicShimmer(
                    height: 30.0,
                  ),
          ],
        ),
      ],
    );
  }

  Column buildMainPriceRow() {
    return Column(
      children: [
        Text(
          _productDetails.currency_symbol + _totalPrice.toString(),
          style: TextStyle(
              color: MyTheme.accent_color,
              fontSize: 16.0,
              fontWeight: FontWeight.w600),
        ),
        Visibility(
          visible: _productDetails.has_discount,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(_productDetails.stroked_price,
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Color.fromRGBO(224, 224, 225, 1),
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                )),
          ),
        ),
        // Visibility(
        //   visible: _productDetails.has_discount,
        //   child: Padding(
        //     padding: EdgeInsets.only(left: 8.0),
        //     child: Text(
        //       "${_productDetails.discount}",
        //       style: TextStyles.largeBoldAccentTexStyle(),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 32.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: Text(
                _appbarPriceString,
                style: TextStyle(fontSize: 16, color: MyTheme.font_grey),
              ),
            )),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: MyTheme.dark_grey),
            onPressed: () {
              onPressShare(context);
            },
          ),
        ),
      ],
    );
  }

  Widget buildBottomAppBar(BuildContext context, _addedToCartSnackbar) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Container(
        height: height * 0.12,
        width: width,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            color: Colors.white),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
              top: 8, bottom: 8, start: 15, end: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_quantity < _stock) {
                        _quantity++;
                        setState(() {});
                        calculateTotalPrice();
                      }
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(0.2)),
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  Text(
                    _quantity.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_quantity > 1) {
                        _quantity--;
                        setState(() {});
                        calculateTotalPrice();
                      }
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(0.2)),
                      child: Icon(
                        Icons.remove,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  onPressAddToCart(context, _addedToCartSnackbar);
                },
                child: Container(
                  width: width * 0.55,
                  // margin: EdgeInsets.only(right: 10, top: 15, left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: MyTheme.accent_color,
                    boxShadow: [
                      BoxShadow(
                        color: MyTheme.accent_color_shadow,
                        blurRadius: 20,
                        spreadRadius: 0.0,
                        offset:
                            Offset(0.0, 10.0), // shadow direction: bottom right
                      )
                    ],
                  ),
                  height: 50,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)
                          .product_details_screen_button_add_to_cart,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      /*  BottomNavigationBar(
        backgroundColor: MyTheme.white,
        items: [
          BottomNavigationBarItem(
              label: "",
              icon: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 10, top: 15, end: 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_quantity < _stock) {
                          _quantity++;
                          setState(() {});
                          calculateTotalPrice();
                        }
                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.withOpacity(0.2)),
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    Text(
                      _quantity.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_quantity > 1) {
                          _quantity--;
                          setState(() {});
                          calculateTotalPrice();
                        }
                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.withOpacity(0.2)),
                        child: Icon(
                          Icons.remove,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              //   InkWell(
              //     onTap: () {
              //       onPressBuyNow(context);
              //     },
              //     child: Container(
              //       margin: EdgeInsets.only(left: 18, right: 18),
              //       height: 50,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(6.0),
              //         color: MyTheme.golden,
              //         boxShadow: [
              //           BoxShadow(
              //             color: MyTheme.golden_shadow,
              //             blurRadius: 20,
              //             spreadRadius: 0.0,
              //             offset: Offset(0.0, 10.0), // shadow direction: bottom right
              //           )
              //         ],
              //       ),
              //       child: Center(
              //         child: Text(
              //           AppLocalizations.of(context)
              //               .product_details_screen_button_buy_now,
              //           style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //               fontWeight: FontWeight.w600),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            label: '',
            icon: InkWell(
              onTap: () {
                onPressAddToCart(context, _addedToCartSnackbar);
              },
              child: Container(
                margin: EdgeInsets.only(right: 10, top: 15, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: MyTheme.accent_color,
                  boxShadow: [
                    BoxShadow(
                      color: MyTheme.accent_color_shadow,
                      blurRadius: 20,
                      spreadRadius: 0.0,
                      offset:
                          Offset(0.0, 10.0), // shadow direction: bottom right
                    )
                  ],
                ),
                height: 50,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)
                        .product_details_screen_button_add_to_cart,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          // BottomNavigationBarItem(
          //   label: "",
          //   icon: InkWell(
          //     onTap: () {
          //       onPressBuyNow(context);
          //     },
          //     child: Container(
          //       margin: EdgeInsets.only(left: 18, right: 18),
          //       height: 50,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(6.0),
          //         color: MyTheme.golden,
          //         boxShadow: [
          //           BoxShadow(
          //             color: MyTheme.golden_shadow,
          //             blurRadius: 20,
          //             spreadRadius: 0.0,
          //             offset: Offset(0.0, 10.0), // shadow direction: bottom right
          //           )
          //         ],
          //       ),
          //       child: Center(
          //         child: Text(
          //           AppLocalizations.of(context)
          //               .product_details_screen_button_buy_now,
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600),
          //         ),
          //       ),
          //     ),
          //   ),
          // )
          /*Container(
            color: Colors.white.withOpacity(0.95),
            height: 83,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 18,
                ),
    
                SizedBox(
                  width: 14,
                ),
    
                SizedBox(
                  width: 18,
                ),
              ],
            ),
          )*/
        ],
      ),*/
    );
  }

  buildRatingAndWishButtonRow() {
    return Row(
      children: [
        RatingBar(
          itemSize: 15.0,
          ignoreGestures: true,
          initialRating: double.parse(_productDetails.rating.toString()),
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 1,
          ratingWidget: RatingWidget(
            full: Icon(FontAwesome.star, color: Colors.amber),
            half: Icon(FontAwesome.star_half, color: Colors.amber),
            empty:
                Icon(FontAwesome.star, color: Color.fromRGBO(224, 224, 225, 1)),
          ),
          itemPadding: EdgeInsets.only(right: 1.0),
          onRatingUpdate: (rating) {
            //print(rating);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            _productDetails.rating_count.toString(),
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 10),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "( " +
                "${_reviewList.length} " +
                AppLocalizations.of(context).review +
                " )",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 10),
          ),
        ),
        /* SizedBox(
          width: 5,
        ),
        Visibility(
          visible: conversation_system_status.$,
          child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecorations.buildCircularButtonDecoration_1(),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        if (is_logged_in == false) {
                          ToastComponent.showDialog("You need to log in",
                              gravity: Toast.center,
                              duration: Toast.lengthLong);
                          return;
                        }

                        onTapSellerChat();
                      },
                      child: Image.asset('assets/chat.png',
                          height: 16, width: 16, color: MyTheme.dark_grey)),
                ],
              )),
        )*/
      ],
    );
  }

  buildBrandRow() {
    return _productDetails.brand.id > 0
        ? InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BrandProducts(
                  id: _productDetails.brand.id,
                  brand_name: _productDetails.brand.name,
                );
              }));
            },
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 75,
                    child: Text(
                      AppLocalizations.of(context).product_details_screen_brand,
                      style: TextStyle(
                          color: Color.fromRGBO(
                            153,
                            153,
                            153,
                            1,
                          ),
                          fontSize: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    _productDetails.brand.name,
                    style: TextStyle(
                        color: MyTheme.font_grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
                /*Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                    //shape: BoxShape.rectangle,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: _productDetails.brand.logo,
                        fit: BoxFit.contain,
                      )),
                ),*/
              ],
            ),
          )
        : Container();
  }

  ExpandableNotifier buildExpandableDescription() {
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: 50,
                child: Html(
                  data: _productDetails.description,
                  style: {
                    "body": Style(color: Color(0xFF737A82)),
                  },
                )),
            expanded: Container(child: Html(data: _productDetails.description)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) {
                  var controller = ExpandableController.of(context);
                  return FlatButton(
                    child: Text(
                      !controller.expanded
                          ? AppLocalizations.of(context).common_view_more
                          : AppLocalizations.of(context).common_show_less,
                      style:
                          TextStyle(color: MyTheme.accent_color, fontSize: 11),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }

  buildTopSellingProductList() {
    if (_topProductInit == false && _topProducts.length == 0) {
      return Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 75.0,
              )),
        ],
      );
    } else if (_topProducts.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 14,
          ),
          itemCount: _topProducts.length,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(top: 14),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListProductCard(
                id: _topProducts[index].id,
                image: _topProducts[index].thumbnail_image,
                name: _topProducts[index].name,
                main_price: _topProducts[index].main_price,
                stroked_price: _topProducts[index].stroked_price,
                has_discount: _topProducts[index].has_discount);
          },
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                  AppLocalizations.of(context)
                      .product_details_screen_no_top_selling_product,
                  style: TextStyle(color: MyTheme.font_grey))));
    }
  }

  buildProductsMayLikeList() {
    double height = MediaQuery.of(context).size.height;
    if (_relatedProductInit == false && _relatedProducts.length == 0) {
      return Row(
        children: [
          Padding(
              padding: app_language_rtl.$
                  ? EdgeInsets.only(left: 8.0, top: 20)
                  : EdgeInsets.only(right: 8.0, top: 20),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 190.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: app_language_rtl.$
                  ? EdgeInsets.only(left: 8.0, top: 20)
                  : EdgeInsets.only(right: 8.0, top: 20),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 190.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 190.0,
                  width: (MediaQuery.of(context).size.width - 32) / 3)),
        ],
      );
    } else if (_relatedProducts.length > 0) {
      return SingleChildScrollView(
        child: SizedBox(
          height: height * 0.44,
          child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
              width: 16,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: _relatedProducts.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return MiniProductCard(
                  id: _relatedProducts[index].id,
                  image: _relatedProducts[index].thumbnail_image,
                  name: _relatedProducts[index].name,
                  main_price: _relatedProducts[index].main_price,
                  stroked_price: _relatedProducts[index].stroked_price,
                  has_discount: _relatedProducts[index].has_discount);
            },
          ),
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)
                .product_details_screen_no_related_product,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  buildQuantityUpButton() => Container(
        decoration: BoxDecorations.buildCircularButtonDecoration_1(),
        width: 36,
        child: IconButton(
            icon: Icon(FontAwesome.plus, size: 16, color: MyTheme.dark_grey),
            onPressed: () {
              if (_quantity < _stock) {
                _quantity++;
                setState(() {});
                calculateTotalPrice();
              }
            }),
      );

  buildQuantityDownButton() => Container(
      decoration: BoxDecorations.buildCircularButtonDecoration_1(),
      width: 36,
      child: IconButton(
          icon: Icon(FontAwesome.minus, size: 16, color: MyTheme.dark_grey),
          onPressed: () {
            if (_quantity > 1) {
              _quantity--;
              setState(() {});
              calculateTotalPrice();
            }
          }));

  openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );

  buildProductImageSection() {
    if (_productImageList.length == 0) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 190.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            width: 64,
            child: Scrollbar(
              controller: _imageScrollController,
              isAlwaysShown: false,
              thickness: 4.0,
              child: Padding(
                padding: app_language_rtl.$
                    ? EdgeInsets.only(left: 8.0)
                    : EdgeInsets.only(right: 8.0),
                child: ListView.builder(
                    itemCount: _productImageList.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int itemIndex = index;
                      return GestureDetector(
                        onTap: () {
                          _currentImage = itemIndex;
                          print(_currentImage);
                          setState(() {});
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _currentImage == itemIndex
                                    ? MyTheme.accent_color
                                    : Color.fromRGBO(112, 112, 112, .3),
                                width: _currentImage == itemIndex ? 2 : 1),
                            //shape: BoxShape.rectangle,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  /*Image.asset(
                                        singleProduct.product_images[index])*/
                                  FadeInImage.assetNetwork(
                                placeholder: 'assets/placeholder.png',
                                image: _productImageList[index],
                                fit: BoxFit.contain,
                              )),
                        ),
                      );
                    }),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              openPhotoDialog(context, _productImageList[_currentImage]);
            },
            child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width - 96,
              child: Container(
                  child: FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder_rectangle.png',
                image: _productImageList[_currentImage],
                fit: BoxFit.scaleDown,
              )),
            ),
          ),
        ],
      );
    }
  }

  Widget buildProductSliderImageSection() {
    if (_productImageList.length == 0) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else {
      return CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
            aspectRatio: 355 / 375,
            viewportFraction: 1,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInExpo,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              print(index);
              setState(() {
                _currentImage = index;
              });
            }),
        items: _productImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        openPhotoDialog(
                            context, _productImageList[_currentImage]);
                      },
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fitHeight,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              _productImageList.length,
                              (index) => Container(
                                    width: _currentImage == index ? 30 : 7,
                                    height: 7.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      // shape: BoxShape.circle,
                                      color: _currentImage == index
                                          ? MyTheme.accent_color
                                          : Colors.grey.withOpacity(0.2),
                                    ),
                                  ))),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  Widget divider() {
    return Container(
      color: MyTheme.light_grey,
      height: 5,
    );
  }
}
