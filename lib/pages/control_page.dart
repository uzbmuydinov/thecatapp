import 'package:flutter/material.dart';
import 'package:thecatapp/pages/home_page.dart';
import 'package:thecatapp/pages/search_page.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key}) : super(key: key);
  static const String id = "control_page";

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  PageController _pageController = PageController();
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomePage(),
          SearchPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        fixedColor: Colors.black,
        selectedFontSize: 14,
        currentIndex: selectedPage,
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
            selectedPage = index;
          });
        },
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image(
                color : (selectedPage ==0) ? Colors.black : null,
                width: 25,
                height: 25,
                image: AssetImage('assets/icons/ic_home.png')),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image(
                color : (selectedPage ==1) ? Colors.black : null,
                width: 25,
                height: 25,
                image: AssetImage('assets/icons/ic_search.png')),
            label: "Search",
          ),
        ],
      ),
    );
  }
}
