import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:thecatapp/models/cat_model.dart';
import 'package:thecatapp/pages/detail_page.dart';
import 'package:thecatapp/services/http_service.dart';
import '../services/log_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);
  static const String id = "home_page";

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isLoading = true;
  int selectedCategory = 1;
  int selected = 0;
  bool isLoadMore = false;
  List<Cat> catList = [];
  List<String> categories = [
    "Hats",
    "Space",
    "Funny",
    "Sunglasses",
    "Boxes",
    "Saturday",
    "Ties",
    "Kittens",
  ];

  @override
  void initState() {
    super.initState();
    getCatImages(1);
  }

  void getCatImages(int categoryId) {
    setState(() {
      isLoadMore = true;
    });
    Network.GET(
            Network.API_LIST, Network.paramsCategoryGet(((catList.length ~/ 10) + 1),categoryId))
        .then((value) {
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
      child: Scaffold(
        body: (isLoading)
            ? Center(
                child: Lottie.asset('assets/anims/loading.json', width: 100))
            :
            /// NotificationListener work when User reach last post
            Stack(
              children: [
                ScrollConfiguration(
                    behavior: const ScrollBehavior(),
                    child: GlowingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      color: Colors.white,
                      child: NestedScrollView(
                        floatHeaderSlivers: true,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return [
                            SliverList(
                                delegate: SliverChildListDelegate([
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.14,
                                child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    itemCount: categories.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (ctx, index) {
                                      return storyItems(index);
                                    }),
                              ),
                            ]))
                          ];
                        },
                        body: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (!isLoadMore &&
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                              getCatImages(selectedCategory);
                              // start loading data
                              setState(() {});
                            }
                            return true;
                          },
                          child: MasonryGridView.count(
                            padding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            itemCount: catList.length,
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            itemBuilder: (context, index) {
                              return postItems(catList[index]);
                            },
                          ),
                        ),
                      ),
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
                pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  return DetailPage(
                    cat: cat,
                  );
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

  Widget storyItems(int index) {
    return GestureDetector(
      onTap: (){
        setState(() {
          catList.clear();
          selected = index;
          (index != 7) ? (selectedCategory = index+1) : (selectedCategory = 9);
          getCatImages(selectedCategory);
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// Story Image
            Container(
              height: 70,
              width: 70,
              padding: EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                border: (selected != index)?Border.all(color: Colors.purple, width: 3):null,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/im_$index.jpg'),
                  )),
            ),
            const SizedBox(
              height: 5,
            ),

            /// User name
            Text(
              categories[index],
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}
