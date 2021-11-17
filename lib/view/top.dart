import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'user_detail.dart';
import 'login.dart';
import '../styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class Top extends StatefulWidget {
  Top({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TopState createState() => _TopState();
}

class _TopState extends State<Top> {
  Map data = Map();
  @override
  void initState() {
    super.initState();
    new Future.delayed(const Duration(milliseconds: 500))
        .then((value) => showLoginPage());
    Provider.of<TopViewModel>(context, listen: false).fetchUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<TopViewModel>(
      create: (_) => TopViewModel(),
      child: _cupertinoWidget(widget.title),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(Top oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _cupertinoWidget(String title) {
    final List<Map> userList = Provider.of<TopViewModel>(context)._userList;
    return CupertinoPageScaffold(
        child: CustomScrollView(
      semanticChildCount: userList.length,
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text("logout"),
              onPressed: () {
                print("logout button pressed");
                showLoginPage();
              }),
          largeTitle: Text(title),
        ),
        SliverSafeArea(
          top: false,
          minimum: const EdgeInsets.only(top: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < userList.length) {
                  return _listItem(userList[index]);
                }

                return null;
              },
            ),
          ),
        )
      ],
    ));
  }

  Widget _listItem(Map user) {
    return GestureDetector(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            CircleAvatar(
              backgroundImage: NetworkImage(user["avatar"]),
            ),
            SizedBox(
              width: 8,
            ),
            Text("${user["first_name"]} ${user["last_name"]}",
                style: Styles.userListRowText)
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: "/detail"),
            builder: (BuildContext context) =>
                UserDetail(title: "User Detail", user: user),
          ),
        );     
      },
    );
  }

  void showLoginPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) {
              return Login(title: "User Login");
            },
            fullscreenDialog: true));
  }
}

class TopViewModel with ChangeNotifier {
  List<Map> _userList = <Map>[];

  Future fetchUser(BuildContext context) async {
    http.Response response =
        await http.get(Uri.parse("https://my-json-server.typicode.com/f-rm/SwiftUITraining/users"));

    Map data = new Map.from(json.decode(response.body));
    List<Map> userListdata = new List.from(data['data']);

    Provider.of<TopViewModel>(context, listen: false).setData(userListdata);
  }

  void setData(List<Map> userList) {
    _userList = userList;
    notifyListeners();
  }
}
