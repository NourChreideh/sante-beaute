import 'package:badges/badges.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlay_dmp_teams/custom/common_functions.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:mlay_dmp_teams/presenter/cart_counter.dart';
import 'package:mlay_dmp_teams/repositories/cart_repository.dart';
import 'package:mlay_dmp_teams/screens/filter.dart';
import 'package:mlay_dmp_teams/screens/flash_deal_list.dart';
import 'package:mlay_dmp_teams/screens/main.dart';
import 'package:mlay_dmp_teams/screens/todays_deal_products.dart';
import 'package:mlay_dmp_teams/screens/top_selling_products.dart';
import 'package:mlay_dmp_teams/screens/category_products.dart';
import 'package:mlay_dmp_teams/screens/category_list.dart';
import 'package:mlay_dmp_teams/ui_sections/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mlay_dmp_teams/repositories/sliders_repository.dart';
import 'package:mlay_dmp_teams/repositories/category_repository.dart';
import 'package:mlay_dmp_teams/repositories/product_repository.dart';
import 'package:mlay_dmp_teams/app_config.dart';

import 'package:mlay_dmp_teams/ui_elements/product_card.dart';
import 'package:mlay_dmp_teams/helpers/shimmer_helper.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mlay_dmp_teams/custom/box_decorations.dart';
import 'package:mlay_dmp_teams/ui_elements/mini_product_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../custom/toast_component.dart';
import '../data_model/all_booking_response.dart';
import '../repositories/profile_repository.dart';
import '../ui_elements/other_products.dart';
import 'all_lazer_device.dart';
import 'cart.dart';
import 'notifications.dart';
import 'others.dart';

class Home extends StatefulWidget {
  Home(
      {Key key,
      this.title,
      this.show_back_button = false,
      go_back = true,
      this.counter})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final CartCounter counter;

  final String title;
  bool show_back_button;
  bool go_back;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _current_slider = 0;
  ScrollController _allProductScrollController;
  ScrollController _featuredCategoryScrollController;
  ScrollController _mainScrollController = ScrollController();

  var _carouselImageList = [];
  var _bannerOneImageList = [];
  var _bannerTwoImageList = [];
  var _featuredCategoryList = [];

  bool _isCategoryInitial = true;

  bool _isCarouselInitial = true;
  bool _isBannerOneInitial = true;
  bool _isBannerTwoInitial = true;

  // var _featuredProductList = [];
  // bool _isFeaturedProductInitial = true;
  // int _totalFeaturedProductData = 0;
  // int _featuredProductPage = 1;
  // bool _showFeaturedLoadingContainer = false;

  var _allProductList = [];
  bool _isAllProductInitial = true;
  int _totalAllProductData = 0;
  int _allProductPage = 1;
  bool _showAllLoadingContainer = false;

  var _categoryProductList = [];
  bool _iscategoryProductInitial = true;
  int _totalcategoryProductData = 0;
  int _categoryProductPage = 1;
  bool _showcategoryLoadingContainer = false;

  var _category2ProductList = [];
  bool _iscategory2ProductInitial = true;
  int _totalcategory2ProductData = 0;
  int _category2ProductPage = 1;
  bool _showcategory2LoadingContainer = false;
  int _cartCount = 0;
  String firstNameCat = "";
  String secondNameCat = "";
  int _orderCounter = 0;
  String _orderCounterString = "00";

  @override
  void initState() {
    // print("app_mobile_language.en${app_mobile_language.$}");
    // print("app_language.${app_language.$}");
    // print("app_language_rtl${app_language_rtl.$}");

    // TODO: implement initState
    super.initState();
    // In initState()

    fetchAll();

    _mainScrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _allProductPage++;
        });
        _showAllLoadingContainer = true;
        fetchAllProducts();
      }
    });
  }

  getCartCount() {
    Provider.of<CartCounter>(context, listen: false).getCount();
    //var res = await CartRepository().getCartCount();
    //widget.counter.controller.sink.add(res.count);
  }

  fetchCounters() async {
    var profileCountersResponse =
        await ProfileRepository().getProfileCountersResponse();
    _orderCounter = profileCountersResponse.order_count;

    // _orderCounterString = _orderCounter.toString();
    // print(_orderCounter);
    if (mounted) setState(() {});
  }

  fetchAll() {
    if (is_logged_in.$) {
      fetchCounters();
    }

    getCartCount();

    fetchCarouselImages();
    fetchBannerOneImages();
    fetchBannerTwoImages();
    fetchFeaturedCategories();
    // fetchFeaturedProducts();
    fetchAllProducts();
    fetchCategoriesProducts();
    fetchCategories2Products();
  }

  fetchCarouselImages() async {
    var carouselResponse = await SlidersRepository().getSliders();
    carouselResponse.sliders.forEach((slider) {
      _carouselImageList.add(slider.photo);
    });
    _isCarouselInitial = false;
    if (mounted) setState(() {});
  }

  fetchBannerOneImages() async {
    var bannerOneResponse = await SlidersRepository().getBannerOneImages();
    bannerOneResponse.sliders.forEach((slider) {
      _bannerOneImageList.add(slider.photo);
    });
    _isBannerOneInitial = false;
    if (mounted) setState(() {});
  }

  fetchBannerTwoImages() async {
    var bannerTwoResponse = await SlidersRepository().getBannerTwoImages();
    bannerTwoResponse.sliders.forEach((slider) {
      _bannerTwoImageList.add(slider.photo);
    });
    _isBannerTwoInitial = false;
    if (mounted) {
      setState(() {});
    }
  }

  fetchFeaturedCategories() async {
    var categoryResponse = await CategoryRepository().getFeturedCategories();
    _featuredCategoryList.addAll(categoryResponse.categories);
    firstNameCat = _featuredCategoryList[0].name;
    secondNameCat = _featuredCategoryList[1].name;
    _isCategoryInitial = false;
    if (mounted) setState(() {});
  }

  // fetchFeaturedProducts() async {
  //   var productResponse = await ProductRepository().getFeaturedProducts(
  //     page: _featuredProductPage,
  //   );

  //   _featuredProductList.addAll(productResponse.products);
  //   _isFeaturedProductInitial = false;
  //   _totalFeaturedProductData = productResponse.meta.total;
  //   _showFeaturedLoadingContainer = false;
  //   setState(() {});
  // }

  fetchCategoriesProducts() async {
    var productResponse = await ProductRepository().getCategoryProducts(id: 8);

    _categoryProductList.addAll(productResponse.products);

    _iscategoryProductInitial = false;
    _totalcategoryProductData = productResponse.meta.total;
    _showcategoryLoadingContainer = false;
    if (mounted) setState(() {});
  }

  fetchCategories2Products() async {
    var productResponse = await ProductRepository().getCategoryProducts(id: 9);

    _category2ProductList.addAll(productResponse.products);
    _iscategory2ProductInitial = false;
    _totalcategory2ProductData = productResponse.meta.total;
    _showcategory2LoadingContainer = false;
    if (mounted) setState(() {});
  }

  fetchAllProducts() async {
    var productResponse =
        await ProductRepository().getFilteredProducts(page: _allProductPage);

    _allProductList.addAll(productResponse.products);
    _isAllProductInitial = false;
    _totalAllProductData = productResponse.meta.total;
    _showAllLoadingContainer = false;
    if (mounted) setState(() {});
  }

  reset() {
    _carouselImageList.clear();
    _bannerOneImageList.clear();
    _bannerTwoImageList.clear();
    // _featuredCategoryList.clear();

    _isCarouselInitial = true;
    _isBannerOneInitial = true;
    _isBannerTwoInitial = true;
    _isCategoryInitial = true;
    _cartCount = 0;

    setState(() {});

    // resetFeaturedProductList();
    resetAllProductList();
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  // resetFeaturedProductList() {
  //   _featuredProductList.clear();
  //   _isFeaturedProductInitial = true;
  //   _totalFeaturedProductData = 0;
  //   _featuredProductPage = 1;
  //   _showFeaturedLoadingContainer = false;
  //   setState(() {});
  // }

  resetAllProductList() {
    _allProductList.clear();
    _isAllProductInitial = true;
    _totalAllProductData = 0;
    _allProductPage = 1;
    _showAllLoadingContainer = false;
    _categoryProductList.clear();
    _iscategoryProductInitial = true;
    _totalcategoryProductData = 0;
    _categoryProductPage = 1;
    _showcategoryLoadingContainer = false;
    _category2ProductList.clear();
    _iscategory2ProductInitial = true;
    _totalcategory2ProductData = 0;
    _category2ProductPage = 1;
    _showcategory2LoadingContainer = false;
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);
    return WillPopScope(
      onWillPop: () async {
        CommonFunctions(context).appExitDialog();
        return widget.go_back;
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
            backgroundColor: Colors.grey.withOpacity(0.1),
            key: _scaffoldKey,
            // appBar: PreferredSize(
            //   preferredSize: Size.fromHeight(76),
            //   child: buildAppBar(statusBarHeight, context),
            // ),
            drawer: MainDrawer(),
            body: Stack(
              children: [
                RefreshIndicator(
                  color: MyTheme.accent_color,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  displacement: 0,
                  child: CustomScrollView(
                    controller: _mainScrollController,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                is_logged_in.$ && avatar_original.$ != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.08),
                                              blurRadius: 20,
                                              spreadRadius: 0.0,
                                              offset: Offset(0.0,
                                                  10.0), // shadow direction: bottom right
                                            )
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 25.0,
                                            backgroundImage: NetworkImage(
                                                "${avatar_original.$}"),
                                          ),
                                        ),
                                      )
                                    : is_logged_in.$ &&
                                            avatar_original.$ == null
                                        ? Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(.08),
                                                  blurRadius: 20,
                                                  spreadRadius: 0.0,
                                                  offset: Offset(0.0,
                                                      10.0), // shadow direction: bottom right
                                                )
                                              ],
                                            ),
                                            child: Image.asset(
                                              'assets/app_logo.png',
                                              height: 48,
                                              width: 48,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          )
                                        : Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(.08),
                                                  blurRadius: 20,
                                                  spreadRadius: 0.0,
                                                  offset: Offset(0.0,
                                                      10.0), // shadow direction: bottom right
                                                )
                                              ],
                                            ),
                                            child: Image.asset(
                                              'assets/app_logo.png',
                                              height: 48,
                                              width: 48,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    is_logged_in.$
                                        ? Text(
                                            AppLocalizations.of(context)
                                                    .welcome +
                                                ", ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: MyTheme.grey_color,
                                                fontWeight: FontWeight.w600),
                                          )
                                        : Text(
                                            AppLocalizations.of(context)
                                                .welcome,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: MyTheme.grey_color,
                                                fontWeight: FontWeight.w600),
                                          ),
                                    SizedBox(
                                      width: width * 0.4,
                                      child: Text(
                                        "${user_name.$}",
                                        maxLines: 1,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Cart(has_bottomnav: false);
                                          }));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.08),
                                                blurRadius: 20,
                                                spreadRadius: 0.0,
                                                offset: Offset(0.0,
                                                    10.0), // shadow direction: bottom right
                                              )
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SvgPicture.asset(
                                                "assets/Bag (1).svg"),
                                          ),
                                          /* child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Badge(
                                              toAnimate: false,
                                              shape: BadgeShape.circle,
                                              badgeColor: Color(0xFFFFA000),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SvgPicture.asset(
                                                  "assets/Bag (1).svg"),
                                              padding: EdgeInsets.all(5),
                                              badgeContent:
                                                  Consumer<CartCounter>(
                                                builder:
                                                    (context, cart, child) {
                                                  return Text(
                                                    "${cart.cartCounter}",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),*/
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Notifications();
                                          }));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.08),
                                                blurRadius: 20,
                                                spreadRadius: 0.0,
                                                offset: Offset(0.0,
                                                    10.0), // shadow direction: bottom right
                                              )
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SvgPicture.asset(
                                                "assets/Notification.svg"),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Filter();
                              }));
                            },
                            child: Container(
                                margin: EdgeInsetsDirectional.only(
                                    start: 15, end: 15),
                                height: 45,
                                // width: width * 0.9,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Color(0xFFD4D8DD)),
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    color: Colors.white),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: SvgPicture.asset(
                                        "assets/Search.svg",
                                      ),
                                    ),
                                    Container(
                                      width: width * 0.5,
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .search_lase,
                                        maxLines: 1,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 14.0,
                                            color: MyTheme.textfield_grey),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            height: 45,
                                            width: width * 0.15,
                                            decoration: BoxDecoration(
                                                color: MyTheme.accent_color,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                  "assets/Filter.svg"),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          buildHomeCarouselSlider(context),
                          SizedBox(
                            height: 35,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: Container(
                              height: app_language_rtl.$
                                  ? height * 0.24
                                  : height * 0.2,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyTheme.light_color,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset("assets/Vector.svg"),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .did_you_book,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: MyTheme.accent_color,
                                                  fontSize: 15),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: width * 0.5,
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .book_text,
                                                maxLines: 3,
                                                style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: MyTheme.text_color,
                                                    fontSize: 14),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: width,
                                          height: 45.0,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                              gradient: LinearGradient(colors: [
                                                MyTheme.accent_color,
                                                MyTheme.secondary_color
                                              ])),
                                          child: ElevatedButton(
                                            onPressed: _orderCounter == 0
                                                ? () {
                                                    ToastComponent.showDialog(
                                                        AppLocalizations.of(
                                                                context)
                                                            .buy_an_order,
                                                        gravity: Toast.center,
                                                        duration:
                                                            Toast.lengthLong);
                                                  }
                                                : () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Main(
                                                                indexx: 2,
                                                              )),
                                                    );
                                                  },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.transparent),
                                              shadowColor: MaterialStateProperty
                                                  .all<Color>(
                                                      Colors.transparent),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .book_now,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.white,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 15,
                                                        color: MyTheme
                                                            .accent_color,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18.0,
                              18.0,
                              20.0,
                              0.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  firstNameCat,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return LazerProducts(id: 8);
                                    }));
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).show_all,
                                    style: TextStyle(
                                        color: MyTheme.grey_color,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          /* Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18.0,
                              0.0,
                              18.0,
                              0.0,
                            ),
                            child: buildHomeMenuRow1(context),
                          ),
                          buildHomeBannerOne(context),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18.0,
                              0.0,
                              18.0,
                              0.0,
                            ),
                            child: buildHomeMenuRow2(context),
                          ),*/
                        ]),
                      ),
                      /* SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18.0,
                              20.0,
                              18.0,
                              0.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)
                                      .home_screen_featured_categories,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),*/
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 340,
                          child: buildHomeMlayLaserCategories(context),
                        ),
                      ),
                      /*SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            color: MyTheme.accent_color,
                            child: Stack(
                              children: [
                                Container(
                                  height: 180,
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset("assets/background_1.png")
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 18.0, left: 18.0),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .home_screen_featured_products,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    buildHomeFeatureProductHorizontalList()
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),*/
                      // SliverList(
                      //   delegate: SliverChildListDelegate(
                      //     [
                      //       buildHomeBannerTwo(context),
                      //     ],
                      //   ),
                      // ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18.0,
                                    18.0,
                                    20.0,
                                    0.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        secondNameCat,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return LazerProducts(id: 9);
                                          }));
                                        },
                                        child: Text(
                                          AppLocalizations.of(context).show_all,
                                          style: TextStyle(
                                              color: MyTheme.grey_color,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
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
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 340,
                          child: devicesHomeFeaturedCategories(context),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18.0,
                                    18.0,
                                    20.0,
                                    0.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).other,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return OthersProducts();
                                          }));
                                        },
                                        child: Text(
                                          AppLocalizations.of(context).show_all,
                                          style: TextStyle(
                                              color: MyTheme.grey_color,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
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
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 320,
                          child: otherHomeFeaturedCategories(context),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          SizedBox(
                            height: 90,
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                // Align(
                //     alignment: Alignment.center,
                //     child: buildProductLoadingContainer())
              ],
            )),
      ),
    );
  }

  Widget buildHomeAllProducts(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _allProductScrollController));
    } else if (_allProductList.length > 0) {
      //snapshot.hasData

      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: _allProductList.length,
        controller: _allProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(16.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
            id: _allProductList[index].id,
            image: _allProductList[index].thumbnail_image,
            name: _allProductList[index].name,
            main_price: _allProductList[index].main_price,
            stroked_price: _allProductList[index].stroked_price,
            has_discount: _allProductList[index].has_discount,
            discount: _allProductList[index].discount,
          );
        },
      );
    } else if (_totalAllProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeAllProducts2(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _allProductScrollController));
    } else if (_allProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _allProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
              id: _allProductList[index].id,
              image: _allProductList[index].thumbnail_image,
              name: _allProductList[index].name,
              main_price: _allProductList[index].main_price,
              stroked_price: _allProductList[index].stroked_price,
              has_discount: _allProductList[index].has_discount,
              discount: _allProductList[index].discount,
            );
          });
    } else if (_totalAllProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeMlayLaserCategories(context) {
    if (_iscategoryProductInitial && _categoryProductList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          // scontroller: _allProductScrollController
          );
    } else if (_categoryProductList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 10),
          scrollDirection: Axis.horizontal,
          // controller: _featuredCategoryScrollController,
          itemCount: _categoryProductList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3 / 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            // mainAxisExtent: 50.0
          ),
          itemBuilder: (context, index) {
            return ProductCard(
              id: _categoryProductList[index].id,
              image: _categoryProductList[index].thumbnail_image,
              name: _categoryProductList[index].name,
              main_price: _categoryProductList[index].main_price,
              stroked_price: _categoryProductList[index].stroked_price,
              has_discount: _categoryProductList[index].has_discount,
              discount: _categoryProductList[index].discount,
            );
          });
    } else if (_categoryProductList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).common_no_product_is_available,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget devicesHomeFeaturedCategories(context) {
    if (_iscategory2ProductInitial && _category2ProductList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount();
    } else if (_category2ProductList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 10),
          scrollDirection: Axis.horizontal,
          // controller: _featuredCategoryScrollController,
          itemCount: _category2ProductList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3 / 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            // mainAxisExtent: 50.0
          ),
          itemBuilder: (context, index) {
            return ProductCard(
              id: _category2ProductList[index].id,
              image: _category2ProductList[index].thumbnail_image,
              name: _category2ProductList[index].name,
              main_price: _category2ProductList[index].main_price,
              stroked_price: _category2ProductList[index].stroked_price,
              has_discount: _category2ProductList[index].has_discount,
              discount: _category2ProductList[index].discount,
            );
          });
    } else if (_category2ProductList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).common_no_product_is_available,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget otherHomeFeaturedCategories(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount();
    } else if (_allProductList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 10),
          scrollDirection: Axis.horizontal,
          // controller: _featuredCategoryScrollController,
          itemCount: _allProductList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3 / 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            // mainAxisExtent: 50.0
          ),
          itemBuilder: (context, index) {
            return otherProductCard(
              id: _allProductList[index].id,
              image: _allProductList[index].thumbnail_image,
              name: _allProductList[index].name,
              main_price: _allProductList[index].main_price,
              stroked_price: _allProductList[index].stroked_price,
              has_discount: _allProductList[index].has_discount,
              discount: _allProductList[index].discount,
            );
          });
    } else if (_allProductList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).common_no_product_is_available,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeMenuRow1(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TodaysDealProducts();
              }));
            },
            child: Container(
              height: 90,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/todays_deal.png")),
                  ),
                  Text(AppLocalizations.of(context).home_screen_todays_deal,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 14.0),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FlashDealList();
              }));
            },
            child: Container(
              height: 90,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/flash_deal.png")),
                  ),
                  Text(AppLocalizations.of(context).home_screen_flash_deal,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildHomeMenuRow2(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CategoryList(
                  is_top_category: true,
                );
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/top_categories.png")),
                  ),
                  Text(
                    AppLocalizations.of(context).home_screen_top_categories,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 14.0,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Filter(
                  selected_filter: "brands",
                );
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/brands.png")),
                  ),
                  Text(AppLocalizations.of(context).home_screen_brands,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 14.0,
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TopSellingProducts();
              }));
            },
            child: Container(
              height: 90,
              width: MediaQuery.of(context).size.width / 3 - 4,
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: Image.asset("assets/top_sellers.png")),
                  ),
                  Text(AppLocalizations.of(context).home_screen_top_sellers,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(132, 132, 132, 1),
                          fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHomeCarouselSlider(context) {
    if (_isCarouselInitial && _carouselImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (_carouselImageList.length > 0) {
      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                aspectRatio: 338 / 140,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInExpo,
                enlargeCenterPage: false,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current_slider = index;
                  });
                }),
            items: _carouselImageList.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 18, right: 18, top: 0, bottom: 0),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            //color: Colors.amber,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFD0EFFD).withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 0.0,
                                  offset: Offset(0.0,
                                      10.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      'assets/placeholder_rectangle.png',
                                  image: i,
                                  height: 145,
                                  fit: BoxFit.cover,
                                ))),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _carouselImageList.map((url) {
              int index = _carouselImageList.indexOf(url);
              return Container(
                width: _current_slider == index ? 15 : 9.0,
                height: _current_slider == index ? 15 : 9.0,
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current_slider == index
                      ? MyTheme.accent_color
                      : Color(0xFF8F9BA9),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeBannerOne(context) {
    if (_isBannerOneInitial && _bannerOneImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (_bannerOneImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: .75,
              initialPage: 0,
              padEnds: false,
              enableInfiniteScroll: false,
              reverse: false,
              autoPlay: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current_slider = index;
                });
              }),
          items: _bannerOneImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 20),
                  child: Container(
                    //color: Colors.amber,
                    width: double.infinity,
                    decoration: BoxDecorations.buildBoxDecoration_1(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder_rectangle.png',
                        image: i,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!_isBannerOneInitial && _bannerOneImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  Widget buildHomeBannerTwo(context) {
    if (_isBannerTwoInitial && _bannerTwoImageList.length == 0) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 10),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (_bannerTwoImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 270 / 120,
              viewportFraction: 0.7,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInExpo,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _current_slider = index;
                });
              }),
          items: _bannerTwoImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 9.0, right: 9, top: 20.0, bottom: 10),
                  child: Container(
                      width: double.infinity,
                      decoration: BoxDecorations.buildBoxDecoration_1(),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fill,
                          ))),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!_isCarouselInitial && _carouselImageList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context).home_screen_no_carousel_image_found,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      // Don't show the leading button
      backgroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Padding(
          // padding:
          //     const EdgeInsets.only(top: 40.0, bottom: 22, left: 18, right: 18),
          padding:
              const EdgeInsets.only(top: 20.0, bottom: 22, left: 18, right: 18),
          child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Filter();
                }));
              },
              child: buildHomeSearchBox(context))),
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).home_screen_search,
              style: TextStyle(fontSize: 13.0, color: MyTheme.textfield_grey),
            ),
            Image.asset(
              'assets/search.png',
              height: 16,
              //color: MyTheme.dark_grey,
              color: MyTheme.dark_grey,
            )
          ],
        ),
      ),
    );
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalAllProductData == _allProductList.length
            ? AppLocalizations.of(context).common_no_more_products
            : AppLocalizations.of(context).common_loading_more_products),
      ),
    );
  }
}
