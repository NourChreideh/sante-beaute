import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../custom/useful_elements.dart';
import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../repositories/product_repository.dart';
import '../ui_elements/filter_product.dart';
import '../ui_elements/product_card.dart';

class LazerProducts extends StatefulWidget {
  final int id;
  const LazerProducts({Key key, this.id}) : super(key: key);

  @override
  State<LazerProducts> createState() => _LazerProductsState();
}

class _LazerProductsState extends State<LazerProducts> {
  var _productList = [];
  bool _isProductInitial = true;
  int _totalProductData = 0;
  int _ProductPage = 1;
  bool _showLoadingContainer = false;
  ScrollController _mainScrollController = ScrollController();

  fetchAllProducts() async {
    var productResponse =
        await ProductRepository().getCategoryProducts(id: widget.id);

    _productList.addAll(productResponse.products);
    _isProductInitial = false;
    _totalProductData = productResponse.meta.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onProductListRefresh() async {
    _productList.clear();
    fetchAllProducts();
  }

  @override
  void initState() {
    super.initState();
    // In initState()

    fetchAllProducts();

    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _ProductPage++;
        });
        _showLoadingContainer = true;
        fetchAllProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.01),
        centerTitle: true,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).all_products,
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
      body: SafeArea(child: buildProductList()),
    );
  }

  Container buildProductList() {
    return Container(
      child: buildProductScrollableList(),
    );
  }

  buildProductScrollableList() {
    if (_isProductInitial && _productList.length == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
            child: ShimmerHelper().buildProductGridShimmer(
                // scontroller: _scrollController
                )),
      );
    } else if (_productList.length > 0) {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: MyTheme.accent_color,
        onRefresh: _onProductListRefresh,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).viewPadding.top > 40 ? 10 : 10
                  //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                  ),
              MasonryGridView.count(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: _productList.length,
                // controller: _scrollController,
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 18, right: 18),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return ProductCard(
                    id: _productList[index].id,
                    image: _productList[index].thumbnail_image,
                    name: _productList[index].name,
                    main_price: _productList[index].main_price,
                    stroked_price: _productList[index].stroked_price,
                    has_discount: _productList[index].has_discount,
                    discount: _productList[index].discount,
                  );
                },
              )
            ],
          ),
        ),
      );
    } else if (_totalProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context).common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}
