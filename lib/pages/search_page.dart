import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:thecatapp/models/breed_model.dart';
import '../services/http_service.dart';
import '../services/log_service.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  static const String id = "search_page";

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedCategory = 0;
  bool isLoadMore = false;
  String search = "";
  List<Breeds> catList = [];
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCatBreeds();
  }

  void getCatBreeds() {
    setState(() {
      isLoadMore = true;
    });
    Network.GET(Network.API_LIST_Breeds, Network.paramEmpty()).then((value) {
      if (value != null) {
        catList.addAll(List<Breeds>.from(Network.parseBreedsList(value)).where(
            (element) =>
                ((element.image != null) && (element.image?.url != null))));
        Log.i("Length : " + catList.length.toString());
      } else {
        Log.i("Null Response");
      }
      setState(() {
        isLoadMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchWidget(context),
      body: (catList.isNotEmpty)
          ? MasonryGridView.count(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: (search.isEmpty)
                  ? catList.length
                  : catList
                      .where((element) => element.name!
                          .toLowerCase()
                          .contains(search.toLowerCase()))
                      .toList()
                      .length,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemBuilder: (context, index) {
                List temp = List.from(catList
                    .where((element) => element.name!
                        .toLowerCase()
                        .contains(search.toLowerCase()))
                    .toList());
                return postItems(temp[index]);
              },
            )
          : Center(
              child: Lottie.asset('assets/anims/loading.json', width: 100)),
    );
  }

  /// Picture Posts
  Widget postItems(Breeds cat) {
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
                    breed: cat,
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
            tag: cat.image!.id!,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: cat.image!.url!,
                placeholder: (context, index) => AspectRatio(
                    aspectRatio: cat.image!.width! / cat.image!.height!,
                    child: Container(
                      color: Colors.grey.shade200,
                    )),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          cat.name!,
          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
        )
      ],
    );
  }

  /// Search Widget
  PreferredSize searchWidget(BuildContext context) {
    return PreferredSize(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20)),

              /// TextField Search
              child: TextField(
                style: TextStyle(
                    color: Colors.black, decoration: TextDecoration.none),
                cursorColor: Colors.black,
                controller: textEditingController,
                onChanged: (text) {
                  setState(() {
                    search = text;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Search for ideas",
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        decoration: TextDecoration.none),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      size: 30,
                      color: Colors.black,
                    ),
                    suffixIcon: Icon(
                      CupertinoIcons.camera_fill,
                      size: 30,
                      color: Colors.black,
                    ),
                    contentPadding: EdgeInsets.all(15),
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
        preferredSize:
            Size(double.infinity, MediaQuery.of(context).size.height * 0.08));
  }

// /// Will pop
// Future<bool> onWillPop() {
//   DateTime now = DateTime.now();
//   if (currentBackPressTime == null ||
//       now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
//     setState(() {
//       currentBackPressTime = now;
//     });
//
//     return Future.value(false);
//   }
//   return Future.value(true);
// }
}
