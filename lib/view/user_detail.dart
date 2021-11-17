import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../styles.dart';

class UserDetail extends StatelessWidget {
  String title = '';
  Map user = Map();

  UserDetail({Key? key, required this.title, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _pageContents(title, user);
  }
}

Widget _pageContents(String title, Map user) {
  return CupertinoPageScaffold(
      child: CustomScrollView(
      slivers: <Widget>[
      CupertinoSliverNavigationBar(
        largeTitle: Text(title),
      ),
      SliverSafeArea(
          top: false,
          minimum: const EdgeInsets.only(top: 4),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              switch (index) {
                case 0:
                  return Container(
                    height: 60,
                  );
                case 1:
                  return CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: CircleAvatar(
                        radius: 100.0,
                        backgroundImage: NetworkImage(user["avatar"]),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                case 2:
                  return Container(
                    height: 10,
                  );
                case 3:
                  return Text("${user["first_name"]} ${user["last_name"]}",
                      textAlign: TextAlign.center,
                      style: Styles.userDetailNameText);
              }
            }),
          ))
    ],
  ));
}
