import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:thecatapp/models/cat_model.dart';
import 'package:thecatapp/pages/detail_page.dart';
import 'package:thecatapp/services/http_service.dart';

import '../services/log_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = "home_page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? currentBackPressTime;
  bool isLoading = true;
  int selectedCategory = 0;
  bool isLoadMore = false;
  List<Cat> catList = [];
  List<String> categories = [
    "None",
    "boxes",
    "clothes",
    "hats",
    "sinks",
    "space",
    "sunglasses",
  ];

  @override
  void initState() {
    super.initState();
    getCatImages();
  }

  void getCatImages() {
    setState(() {
      isLoadMore = true;
    });
    Network.GET(Network.API_LIST, Network.paramsGet((catList.length ~/ 10)+1)).then((value) {
      if (value != null) {
        catList.addAll(List.from(Network.parseCatList(value)));
        Log.i("Length : " + catList.length.toString());
      } else {
        Log.i("Null Response");
      }
      setState(() {
        isLoading = false;
        isLoadMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: categoriesWidget(),
          body: (isLoading)
              ? Center(
                  child: Lottie.asset('assets/anims/loading.json', width: 100))
              : Stack(
                  children: [
                    /// NotificationListener work when User reach last post
                    NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!isLoadMore &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          getCatImages();
                          // start loading data
                          setState(() {});
                        }
                        return true;
                      },
                      child: MasonryGridView.count(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        itemCount: catList.length,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          return postItems(catList[index]);
                        },
                      ),
                    ),

                    /// Lottie_Loading appear when User reach last post and start Load More
                    isLoadMore
                        ? AnimatedContainer(
                            curve: Curves.easeIn,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: Colors.white54),
                            duration: const Duration(milliseconds: 4),

                            /// Lottie_Loading appear when User reach last post and start Load More
                            child: Center(
                                child: Lottie.asset('assets/anims/loading.json',
                                    width: 100)),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
        ),
      ),
    );
  }

  /// Picture Posts
  Widget postItems(Cat cat) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
                fullscreenDialog: true,
                transitionDuration: Duration(milliseconds: 1000),
                pageBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  return DetailPage(cat: cat,);
                },
                transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticInOut,

                    ),
                    child: child,
                  );
                }));
          },
          child: Hero(
            tag: cat.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: cat.url,
                placeholder: (context, index) => AspectRatio(
                  aspectRatio: cat.width / cat.height,
                  child: Image(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/im_placeholder.png"),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// App Bar Categories
  PreferredSize categoriesWidget() {
    return PreferredSize(
        child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              /// TextBUtton
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = index;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    shape: StadiumBorder(),
                    backgroundColor: (selectedCategory == index)
                        ? Colors.black
                        : Colors.grey.shade300,
                  ),
                  child: Text(
                    categories[index],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: (selectedCategory == index)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            }),
        preferredSize: Size(double.infinity, 60));
  }

  /// Will pop
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      setState(() {
        currentBackPressTime = now;
      });

      return Future.value(false);
    }
    return Future.value(true);
  }
}
