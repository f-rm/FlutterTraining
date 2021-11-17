import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'user_regist.dart';
import 'dart:convert';

enum LoginField { email, password }

class Login extends StatefulWidget {
  Login({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  String email = 'test@test.com';
  String password = 'test1234';
  Map user = Map();
  Map data = Map();
  final _formKey = GlobalKey<FormState>();
  Map isValidField = {LoginField.email: false, LoginField.password: false};
  Map hasUpdateField = {LoginField.email: false, LoginField.password: false};

  @override
  void initState() {
    super.initState();

    emailTextController.addListener(() {
      setState(() {
        _validateInitialValue();
      });
    });

    passwordTextController.addListener(() {
      setState(() {
        _validateInitialValue();
      });
    });

    emailTextController.text = email;
    passwordTextController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return _pageContents(context, widget.title);
  }

  Widget _pageContents(BuildContext context, String title) {
    return CupertinoPageScaffold(
        child: CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
            leading: Container(),
            largeTitle: Text(title),
            trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text("regist"),
                onPressed: () {
                  print("add button pressed");
                  showUserRegistPage();
                })),
        Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            onChanged: () {
              Form.of(primaryFocus!.context!)?.save();
            },
            child: SliverSafeArea(
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _inputField(context, LoginField.email),
                        );
                      case 2:
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _inputField(context, LoginField.password),
                        );
                      case 3:
                        if (_formKey.currentState != null) {
                          return Padding(
                            padding: const EdgeInsets.all(30),
                            child: CupertinoButton(
                              color: isValidAllFields()
                                  ? Colors.blue
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(30.0),
                              child: Text('login'),
                              onPressed: () {
                                if (isValidAllFields()) {
                                  _formKey.currentState?.save();
                                  print('login button pressed');
                                  //Navigator.of(context).pop();
                                  loginRequest(context);
                                }
                              },
                            ),
                          );
                        }
                    }
                  }),
                )))
      ],
    ));
  }

  Widget _inputField(BuildContext context, LoginField fieldType) {
    String placeholderText = "";
    bool isSecure = false;

    if (fieldType == LoginField.email) {
      placeholderText = 'email';
      isSecure = false;
    } else if (fieldType == LoginField.password) {
      placeholderText = 'password';
      isSecure = true;
    }

    return CupertinoTextFormFieldRow(
        prefix: Icon(
          _getIconData(fieldType),
          color: CupertinoColors.lightBackgroundGray,
          size: 28,
        ),
        obscureText: isSecure,
        placeholder: placeholderText,
        autocorrect: false,
        controller: fieldType == LoginField.email
            ? emailTextController
            : passwordTextController,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0,
              color: CupertinoColors.inactiveGray,
            ),
          ),
        ),
        validator: (String? value) {
          return _validate(fieldType, value);
        },
        onChanged: (newValue) {
          _setFieldValue(fieldType, newValue);
          hasUpdateField[fieldType] = true;
          if (_validate(fieldType, newValue) == null) {
            isValidField[fieldType] = true;
          } else {
            isValidField[fieldType] = false;
          }
        });
  }

  IconData _getIconData(LoginField fieldType) {
    IconData iconKey = IconData(0);

    if (fieldType == LoginField.email) {
      iconKey = CupertinoIcons.mail_solid;
    } else if (fieldType == LoginField.password) {
      iconKey = CupertinoIcons.lock;
    }

    return iconKey;
  }

  String? _validate(LoginField fieldType, String? value) {
    if (fieldType == LoginField.email) {
      if (!hasUpdateField[LoginField.email]) {
        return null;
      }
      if (value == null || value.isEmpty) {
        return 'email is empty';
      }
      if (value.length < 8) {
        return 'email must be over 8 characters';
      }
      if (!RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(value)) {
        return 'email is invalid';
      }
      isValidField[LoginField.email] = true;
    } else if (fieldType == LoginField.password) {
      if (!hasUpdateField[LoginField.password]) {
        return null;
      }
      if (value == null || value.isEmpty) {
        return 'password is empty';
      }
      if (value.length < 8) {
        return 'password must be over 8 characters';
      }
      isValidField[LoginField.password] = true;
    }
    return null;
  }

  bool isValidAllFields() {
    if (isValidField[LoginField.email] == true &&
        isValidField[LoginField.password] == true) {
      return true;
    }
    return false;
  }

  void _setFieldValue(LoginField fieldType, String newValue) {
    if (fieldType == LoginField.email) {
      email = newValue;
    } else if (fieldType == LoginField.password) {
      password = newValue;
    }
  }

  void showUserRegistPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) {
              return UserRegist(title: "User Regist");
            },
            fullscreenDialog: true));
  }

  Future loginRequest(BuildContext context) async {
    var request = LoginRequest(email: email, password: password);

    try {
      http.Response response = await http.post(
          Uri.parse(
              "https://my-json-server.typicode.com/f-rm/SwiftUITraining/regist"),
          body: json.encode(request.toJson()));

      data = json.decode(response.body);
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
      }
    } on Exception catch (error) {
      print(error);
      _openDialog(context, "error", "fail to register user.", () => {});
    }
  }

  void _openDialog(BuildContext context, String title, String message,
      VoidCallback completion) {
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                CupertinoButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                    completion();
                  },
                )
              ],
            ));
  }

  void _validateInitialValue() {
    final emailText = emailTextController.text;
    final passwordText = passwordTextController.text;
    if (_validate(LoginField.email, emailText) == null) {
      isValidField[LoginField.email] = true;
    }
    if (_validate(LoginField.password, passwordText) == null) {
      isValidField[LoginField.password] = true;
    }
  }
}

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({
    required this.email,
    required this.password,
  });
  Map<String, dynamic> toJson() => {
        'email': email,
        'passeword': password,
      };
}
