import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../language/appLocalizations.dart';
import '../../resources/auth_methods.dart';
import '../../resources/user_model.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_text_field_view.dart';
import '../../widgets/remove_focuse.dart';
import 'display_image.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String? _userImageUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _uid;
  String? url;
  String _errorFName = '';
  String _errorLName = '';
  String _errorName = '';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getData();
    if(user?.uid != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        loggedInUser = UserModel.fromMap(value.data());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser.imageUrl == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const AppBarTheme().backgroundColor,
        ),
        body: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4FBE9F),
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              Text(AppLocalizations(context).of("wait"),
                  style: const TextStyle(
                      color: Color(0xFF4FBE9F),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    } else if (loggedInUser.firstName != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const AppBarTheme().backgroundColor,
        ),
        body: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 30),
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DisplayImage())),
                          child: CircleAvatar(
                            radius: 71,
                            backgroundColor: const Color(0xFFF7F7F7),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: const Color(0xFF4FBE9F),
                              foregroundImage: _pickedImage == null
                                  ? null
                                  : FileImage(_pickedImage!),
                              backgroundImage: NetworkImage(_userImageUrl ??
                                  'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 120,
                          left: 110,
                          child: RawMaterialButton(
                            elevation: 10,
                            fillColor: const Color(0xFF4FBE9F),
                            child: const Icon(Icons.add_a_photo),
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        AppLocalizations(context).of("choose"),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4FBE9F),
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: [
                                            InkWell(
                                              onTap: _pickImageCamera,
                                              splashColor:
                                                  const Color(0xFF4FBE9F),
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.camera,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations(context)
                                                        .of("camera"),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF4FBE9F)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: _pickImageGallery,
                                              splashColor: Colors.grey,
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.upload,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations(context)
                                                        .of("gallery"),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF4FBE9F)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: _remove,
                                              splashColor: Colors.grey,
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations(context)
                                                        .of("remove"),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ))
                    ],
                  ),
                ),
                // ${AuthMethods().currentUser?.email}
                Container(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 16, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommonTextFieldView(
                        enabled: false,
                        titleText: AppLocalizations(context).of("your_email"),
                        hintText: '${AuthMethods().currentUser!.email}',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 16, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommonTextFieldView(
                        titleText: AppLocalizations(context).of("first_name"),
                        errorText: _errorFName,
                        controller: firstNameController,
                        hintText: '${loggedInUser.firstName}',
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CommonTextFieldView(
                        controller: lastNameController,
                        errorText: _errorLName,
                        titleText: AppLocalizations(context).of("last_name"),
                        hintText: '${loggedInUser.lastName}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),

                CommonButton(
                  buttonTextWidget: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            Text(AppLocalizations(context).of("wait"),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Text(AppLocalizations(context).of("update"),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 16, top: 10),
                  isClickable: !_isLoading,
                  onTap: () async {
                    if (_isLoading) return;
                    setState(() {
                      _isLoading = true;
                    });
                    await Future.delayed(const Duration(milliseconds: 500));

                    setState(() {
                      _isLoading = false;
                      update1();
                    });
                  },
                ),

                const SizedBox(
                  height: 150,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const AppBarTheme().backgroundColor,
        ),
        body: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 30),
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DisplayImage())),
                          child: CircleAvatar(
                            radius: 71,
                            backgroundColor: const Color(0xFFF7F7F7),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: const Color(0xFF4FBE9F),
                              foregroundImage: _pickedImage == null
                                  ? null
                                  : FileImage(_pickedImage!),
                              backgroundImage: NetworkImage(_userImageUrl ??
                                  'https://t3.ftcdn.net/jpg/01/83/55/76/240_F_183557656_DRcvOesmfDl5BIyhPKrcWANFKy2964i9.jpg'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 120,
                          left: 110,
                          child: RawMaterialButton(
                            elevation: 10,
                            fillColor: const Color(0xFF4FBE9F),
                            child: const Icon(Icons.add_a_photo),
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        AppLocalizations(context).of("choose"),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4FBE9F),
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: [
                                            InkWell(
                                              onTap: _pickImageCamera,
                                              splashColor:
                                                  const Color(0xFF4FBE9F),
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.camera,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations(context)
                                                        .of("camera"),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF4FBE9F)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: _pickImageGallery,
                                              splashColor: Colors.grey,
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.upload,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations(context)
                                                        .of("gallery"),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFF4FBE9F)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: _remove,
                                              splashColor: Colors.grey,
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLocalizations(context)
                                                        .of("remove"),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ))
                    ],
                  ),
                ),
                // ${AuthMethods().currentUser?.email}
                Container(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 16, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommonTextFieldView(
                        enabled: false,
                        titleText: AppLocalizations(context).of("your_email"),
                        hintText: '${AuthMethods().currentUser!.email}',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 16, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CommonTextFieldView(
                        titleText: AppLocalizations(context).of("your_name"),
                        errorText: _errorName,
                        controller: displayNameController,
                        hintText: '${AuthMethods().currentUser!.displayName}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),

                CommonButton(
                    buttonTextWidget: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              Text(AppLocalizations(context).of("wait"),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Text(AppLocalizations(context).of("update"),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, bottom: 16, top: 10),
                    isClickable: !_isLoading,
                    onTap: () async {
                      if (_isLoading) return;
                      setState(() {
                        _isLoading = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {
                        _isLoading = false;
                        update2();
                      });
                    }),

                const SizedBox(
                  height: 150,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void getData() async {
    User? user = _auth.currentUser;
    _uid = user!.uid;

    final DocumentSnapshot<Map<String, dynamic>>? userDoc = user.isAnonymous
        ? null
        : await FirebaseFirestore.instance.collection('users').doc(_uid).get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        _userImageUrl = userDoc.get('imageUrl');
      });
    }
  }

  File? _pickedImage;

  String imageUrl = '';
  TextEditingController displayNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  void _pickImageCamera() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 10);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  bool _isLoading = false;

  update1() async {
    if (_allValidation()) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      if (_pickedImage == null) {
        Fluttertoast.showToast(msg: AppLocalizations(context).of("pick"));
        _isLoading = false;
      } else if (!_allValidation()) {
        setState(() {
          _isLoading = false;
          Fluttertoast.showToast(msg: AppLocalizations(context).of("fields"));
        });
      } else {
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('usersImages')
            .child(firstNameController.text + '.jpg');
        await ref.putFile(_pickedImage!);
        url = await ref.getDownloadURL();
        // calling our firestore
        // calling our user model
        // sedning these values

        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        User? user = _auth.currentUser;

        UserModel userModel = UserModel();

        // writing all the values
        userModel.email = user!.email;
        userModel.uid = user.uid;
        userModel.firstName = firstNameController.text;
        userModel.lastName = lastNameController.text;
        userModel.imageUrl = url;

        user.updateDisplayName(
            firstNameController.text + " " + lastNameController.text);
        await firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .update(userModel.toMap());
        Fluttertoast.showToast(msg: 'update successfully');
        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          _isLoading = false;
          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          _isLoading = false;
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          _isLoading = false;
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          _isLoading = false;
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          _isLoading = false;
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          _isLoading = false;
          break;
        case "email-already-in-use":
          errorMessage = "Email is already in use.";
          _isLoading = false;
          break;
        default:
          errorMessage = "An undefined Error happened.";
          _isLoading = false;
      }
      Fluttertoast.showToast(msg: errorMessage!);
      _isLoading = false;
    }
  }

  update2() async {
    if (_allValidation2()) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      if (_pickedImage == null) {
        Fluttertoast.showToast(msg: 'Please pick an image');
        _isLoading = false;
      } else if (!_allValidation2()) {
        setState(() {
          _isLoading = false;
          Fluttertoast.showToast(msg: 'Please fill all fields');
        });
      } else {
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('usersImages')
            .child(displayNameController.text + '.jpg');
        await ref.putFile(_pickedImage!);
        url = await ref.getDownloadURL();
        // calling our firestore
        // calling our user model
        // sedning these values

        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        User? user = _auth.currentUser;

        UserModel userModel = UserModel();

        // writing all the values
        userModel.email = user!.email;
        userModel.uid = user.uid;
        //
        userModel.imageUrl = url;

        user.updateDisplayName(displayNameController.text);
        // user.updatePhotoURL(_pickedImage!());
        await firebaseFirestore
            .collection("users")
            .doc(user.uid)
            .update(userModel.toMap());
        Fluttertoast.showToast(msg: 'update successfully');
        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Your email address appears to be malformed.";
          _isLoading = false;
          break;
        case "wrong-password":
          errorMessage = "Your password is wrong.";
          _isLoading = false;
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          _isLoading = false;
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          _isLoading = false;
          break;
        case "too-many-requests":
          errorMessage = "Too many requests";
          _isLoading = false;
          break;
        case "operation-not-allowed":
          errorMessage = "Signing in with Email and Password is not enabled.";
          _isLoading = false;
          break;
        case "email-already-in-use":
          errorMessage = "Email is already in use.";
          _isLoading = false;
          break;
        default:
          errorMessage = "An undefined Error happened.";
          _isLoading = false;
      }
      Fluttertoast.showToast(msg: errorMessage!);
      _isLoading = false;
    }
  }

  bool _allValidation() {
    bool isValid = true;

    if (firstNameController.text.trim().isEmpty) {
      _errorFName = AppLocalizations(context).of('first_name_cannot_empty');
      isValid = false;
    } else {
      _errorFName = '';
    }

    if (lastNameController.text.trim().isEmpty) {
      _errorLName = AppLocalizations(context).of('last_name_cannot_empty');
      isValid = false;
    } else {
      _errorLName = '';
    }

    setState(() {});
    return isValid;
  }

  bool _allValidation2() {
    bool isValid = true;
    if (displayNameController.text.trim().isEmpty) {
      _errorName = AppLocalizations(context).of('name_cannot_empty');
      isValid = false;
    } else {
      _errorName = '';
    }

    setState(() {});
    return isValid;
  }
}
