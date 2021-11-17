import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum UserRegistField {
  avatar,
  firstName,
  lastName,
  email,
  password,
  confirmPassword
}

class UserRegist extends StatefulWidget {
  final String title;

  UserRegist({Key? key, required this.title}) : super(key: key);

  @override
  _UserRegistState createState() => _UserRegistState(title: title);
}

class _UserRegistState extends State<UserRegist> {
  _UserRegistState({required this.title});

  String title = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  late File? userImage = null;
  final picker = ImagePicker();
  Map data = Map();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController confirmPasswordTextController =
      TextEditingController();
  Map isValidField = {
    UserRegistField.firstName: false,
    UserRegistField.lastName: false,
    UserRegistField.email: false,
    UserRegistField.password: false,
    UserRegistField.confirmPassword: false
  };
  Map hasUpdateField = {
    UserRegistField.firstName: false,
    UserRegistField.lastName: false,
    UserRegistField.email: false,
    UserRegistField.password: false,
    UserRegistField.confirmPassword: false
  };

  @override
  void initState() {
    super.initState();

    firstNameTextController.text = firstName;
    lastNameTextController.text = lastName;
    emailTextController.text = email;
    passwordTextController.text = password;
    confirmPasswordTextController.text = confirmPassword;

    firstNameTextController.addListener(() {
      setState(() {
        _validateInitialValue();
      });
    });
    lastNameTextController.addListener(() {
      setState(() {
        _validateInitialValue();
      });
    });
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
    confirmPasswordTextController.addListener(() {
      setState(() {
        _validateInitialValue();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return CupertinoPageScaffold(
      child: CustomScrollView(slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(title),
        ),
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
                      height: 20,
                    );
                  case 1:
                    return Stack(alignment: Alignment.center, children: [
                      _userImageView(),
                      Positioned(
                        bottom: 10.0,
                        right: (screenSize.width - 200) / 2,
                        child: _cameraImageView(),
                      )
                    ]);
                  case 2:
                    return Container(
                      height: 20,
                    );
                  case 3:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _inputTextField(UserRegistField.firstName),
                    );
                  case 4:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _inputTextField(UserRegistField.lastName),
                    );
                  case 5:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _inputTextField(UserRegistField.email),
                    );
                  case 6:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _inputTextField(UserRegistField.password),
                    );
                  case 7:
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _inputTextField(UserRegistField.confirmPassword),
                    );
                  case 8:
                    return Padding(
                      padding: const EdgeInsets.all(30),
                      child: CupertinoButton(
                        color: isValidAllFields() ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(30.0),
                        child: Text('regist'),
                        onPressed: () {
                          if (isValidAllFields()) {
                            _formKey.currentState?.save();
                            print('regist button pressed');
                            _registUser(context);
                          }
                        },
                      ),
                    );
                }
              }),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _userImageView() {
    if (userImage != null) {
      return CircleAvatar(
          radius: 100.0, backgroundImage: Image.file(userImage!).image);
    } else {
      return CircleAvatar(
          radius: 100.0,
          child: ClipRRect(
            child: Image.asset('images/user.jpeg'),
            borderRadius: BorderRadius.circular(100.0),
          ));
    }
  }

  Widget _cameraImageView() {
    return GestureDetector(
      onTap: () {
        _getImage();
      },
      child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20.0,
          child: ClipRRect(
              child: Image.asset('images/camera.png'),
              borderRadius: BorderRadius.circular(20.0))),
    );
  }

  Widget _inputTextField(UserRegistField fieldType) {
    return CupertinoTextFormFieldRow(
      prefix: Icon(
        _getIconData(fieldType),
        color: CupertinoColors.lightBackgroundGray,
        size: 28,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      textCapitalization: TextCapitalization.words,
      autocorrect: false,
      controller: getTextEditingController(fieldType),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0,
            color: CupertinoColors.inactiveGray,
          ),
        ),
      ),
      placeholder: _getPlaceHolder(fieldType),
      obscureText: _isSecureField(fieldType),
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
      },
    );
  }

  IconData _getIconData(UserRegistField fieldType) {
    IconData iconKey = IconData(0);

    if (fieldType == UserRegistField.firstName) {
      iconKey = CupertinoIcons.person_solid;
    } else if (fieldType == UserRegistField.lastName) {
      iconKey = CupertinoIcons.person_solid;
    } else if (fieldType == UserRegistField.email) {
      iconKey = CupertinoIcons.mail_solid;
    } else if (fieldType == UserRegistField.password) {
      iconKey = CupertinoIcons.lock;
    } else if (fieldType == UserRegistField.confirmPassword) {
      iconKey = CupertinoIcons.lock;
    }

    return iconKey;
  }

  String _getPlaceHolder(UserRegistField fieldType) {
    String placeholder = "";

    if (fieldType == UserRegistField.firstName) {
      placeholder = 'First Name';
    } else if (fieldType == UserRegistField.lastName) {
      placeholder = 'Last Name';
    } else if (fieldType == UserRegistField.email) {
      placeholder = 'Email';
    } else if (fieldType == UserRegistField.password) {
      placeholder = 'Password';
    } else if (fieldType == UserRegistField.confirmPassword) {
      placeholder = 'Confirm Password';
    }

    return placeholder;
  }

  bool _isSecureField(UserRegistField fieldType) {
    bool isSecureField = false;

    if (fieldType == UserRegistField.password) {
      isSecureField = true;
    } else if (fieldType == UserRegistField.confirmPassword) {
      isSecureField = true;
    }

    return isSecureField;
  }

  String? _validate(UserRegistField fieldType, String? value) {
    if (fieldType == UserRegistField.firstName) {
      return _firstNameValidator(value);
    } else if (fieldType == UserRegistField.lastName) {
      return _lastNameValidator(value);
    } else if (fieldType == UserRegistField.email) {
      return _emailValidator(value);
    } else if (fieldType == UserRegistField.password) {
      return _passwordValidator(value);
    } else if (fieldType == UserRegistField.confirmPassword) {
      return _confirmPasswordValidator(value);
    }
    return null;
  }

  void _validateInitialValue() {
    final firstNameText = firstNameTextController.text;
    final lastNameText = lastNameTextController.text;
    final emailText = emailTextController.text;
    final passwordText = passwordTextController.text;
    final confirmPasswordText = confirmPasswordTextController.text;

    if (_validate(UserRegistField.firstName, firstNameText) == null) {
      isValidField[UserRegistField.firstName] = false;
    }
    if (_validate(UserRegistField.lastName, lastNameText) == null) {
      isValidField[UserRegistField.lastName] = false;
    }
    if (_validate(UserRegistField.email, emailText) == null) {
      isValidField[UserRegistField.email] = false;
    }
    if (_validate(UserRegistField.password, passwordText) == null) {
      isValidField[UserRegistField.password] = false;
    }
    if (_validate(UserRegistField.confirmPassword, confirmPasswordText) ==
        null) {
      isValidField[UserRegistField.confirmPassword] = false;
    }
  }

  bool isValidAllFields() {
    if (isValidField[UserRegistField.firstName] == true &&
        isValidField[UserRegistField.lastName] == true &&
        isValidField[UserRegistField.email] == true &&
        isValidField[UserRegistField.password] == true &&
        isValidField[UserRegistField.confirmPassword] == true) {
      return true;
    }
    return false;
  }

  String? _firstNameValidator(String? value) {
    if (!hasUpdateField[UserRegistField.firstName]) {
      return null;
    }
    if ((value == null || value.isEmpty)) {
      return 'first name is empty';
    }
    if (value.length > 50) {
      return 'firstName must be within 50 characters';
    }
    isValidField[UserRegistField.firstName] = true;
    return null;
  }

  String? _lastNameValidator(String? value) {
    if (!hasUpdateField[UserRegistField.lastName]) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'last name is empty';
    }
    if (value.length > 50) {
      return 'lastName must be within 50 characters';
    }
    isValidField[UserRegistField.lastName] = true;
    return null;
  }

  String? _emailValidator(String? value) {
    if (!hasUpdateField[UserRegistField.email]) {
      return null;
    }
    if (value == null || value == "") {
      return "email is empty";
    }
    if (value.length > 50) {
      return 'email must be within 50 characters';
    }
    if (!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value)) {
      return 'email is invalid';
    }
    isValidField[UserRegistField.email] = true;
    return null;
  }

  String? _passwordValidator(String? value) {
    if (!hasUpdateField[UserRegistField.password]) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'password is empty';
    }
    if (value.length < 8 || value.length > 50) {
      return 'password must be 8-50 characters';
    }
    if (password != confirmPassword) {
      return 'password is different from confirmation';
    }
    isValidField[UserRegistField.password] = true;
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (!hasUpdateField[UserRegistField.confirmPassword]) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'confirm password is empty';
    }
    if (value.length < 8 || value.length > 50) {
      return 'confirmPassword must be 8-50 characters';
    }
    if (password != confirmPassword) {
      return 'password is different from confirmation';
    }
    isValidField[UserRegistField.confirmPassword] = true;
    return null;
  }

  void _setFieldValue(UserRegistField fieldType, String newValue) {
    if (fieldType == UserRegistField.firstName) {
      firstName = newValue;
    } else if (fieldType == UserRegistField.lastName) {
      lastName = newValue;
    } else if (fieldType == UserRegistField.email) {
      email = newValue;
    } else if (fieldType == UserRegistField.password) {
      password = newValue;
    } else if (fieldType == UserRegistField.confirmPassword) {
      confirmPassword = newValue;
    }
  }

  Future _registUser(BuildContext context) async {
    var request = UserRegistRequest(firstName: firstName, lastName: lastName);

    try {
      http.Response response = await http.post(
          Uri.parse(
              "https://my-json-server.typicode.com/f-rm/SwiftUITraining/regist"),
          body: json.encode(request.toJson()));

      data = json.decode(response.body);
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _openDialog(context, "notice", "user has registered.",
            () => {Navigator.pop(context)});
      }
    } on Exception catch (error) {
      print(error);
      _openDialog(context, "error", "fail to register user.", () => {});
    }
  }

  Future _getImage() async {
    //final pickedFile = await picker.pickImage(source: ImageSource.camera);//カメラ
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        userImage = File(pickedFile.path);
      }
    });
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

  TextEditingController? getTextEditingController(UserRegistField fieldType) {
    if (fieldType == UserRegistField.firstName) {
      return firstNameTextController;
    } else if (fieldType == UserRegistField.lastName) {
      return lastNameTextController;
    } else if (fieldType == UserRegistField.email) {
      return emailTextController;
    } else if (fieldType == UserRegistField.password) {
      return passwordTextController;
    } else if (fieldType == UserRegistField.confirmPassword) {
      return confirmPasswordTextController;
    }
    return null;
  }

  bool isAllFieldFilled() {
    if (firstNameTextController.text.isNotEmpty &&
        lastNameTextController.text.isNotEmpty &&
        emailTextController.text.isNotEmpty &&
        passwordTextController.text.isNotEmpty &&
        confirmPasswordTextController.text.isNotEmpty) {
      return true;
    }
    return false;
  }
}

class UserRegistRequest {
  final String firstName;
  final String lastName;
  UserRegistRequest({
    required this.firstName,
    required this.lastName,
  });
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
      };
}
