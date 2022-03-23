// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firebase = FirebaseFirestore.instance;

  String? userName, myPassword, myEmail;
  bool? signUpValid = false;

  OutlineInputBorder textBorders(Color color, double radius) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: color));
  }

  signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: myEmail!, password: myPassword!);
        signUpValid = true;
      } on FirebaseAuthException catch (e) {
        signUpValid = false;
        if (e.code == 'weak-password') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.TOPSLIDE,
            desc: 'Password Is Too Weak',
          ).show();
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.TOPSLIDE,
            desc: 'Email Already Exists',
          ).show();
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
      print("Valid");
    } else {
      print("Not Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
              child: ListView(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                    child: Text(
                  "Chat App",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.purple[900],
                      fontWeight: FontWeight.bold),
                )),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextFormField(
                  onSaved: (value) {
                    userName = value;
                  },
                  controller: userNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      print("UserName Is Empty");
                      return "Enter Valid UserName";
                    } else {
                      if (value.length <= 2) {
                        return "Username Can't be less than 2 letters";
                      } else if (value.length >= 100) {
                        return "Username Can't be more than 100 letters";
                      } else {
                        return null;
                      }
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "UserName",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.purple[900],
                    ),
                    hoverColor: Colors.red,
                    border: textBorders(Colors.purple, 10),
                    hintText: "UserName",
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextFormField(
                  onSaved: (value) {
                    myEmail = value;
                  },
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      print("Email Is Empty");
                      return "Enter Valid Email";
                    } else {
                      if (value.length <= 2) {
                        return "Email Can't be less than 2 letters";
                      } else if (value.length >= 100) {
                        return "Email Can't be more than 100 letters";
                      } else {
                        return null;
                      }
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.purple[900],
                    ),
                    hoverColor: Colors.red,
                    border: textBorders(Colors.purple, 10),
                    hintText: "user email",
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextFormField(
                  onSaved: (value) {
                    myPassword = value;
                  },
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      print("Password Is Empty");
                      return "Enter Valid Password";
                    } else {
                      if (value.length < 4) {
                        return "Password Can't be less than 5 letters";
                      } else if (value.length >= 100) {
                        return "Password Can't be more than 100 letters";
                      } else {
                        return null;
                      }
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "password",
                    prefixIcon: Icon(
                      Icons.password,
                      color: Colors.purple[900],
                    ),
                    hoverColor: Colors.red,
                    border: textBorders(Colors.purple, 10),
                    hintText: "user password",
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, left: 40, right: 40),
                child: Divider(
                  thickness: 2,
                  color: Colors.purple[900],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                width: double.infinity,
                height: 57,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple[900]),
                        shape: MaterialStateProperty
                            .all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(color: Colors.purple)))),
                    onPressed: () async {
                      await signUp();
                      if (signUpValid!) {
                        print("Sign Up Succeeded");
                        Navigator.pop(context);
                      } else {
                        print("Sign Up Failed");
                      }
                    },
                    child: Text("Sign Up",
                        style: GoogleFonts.dmSans(
                            textStyle: const TextStyle(fontSize: 25)))),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
