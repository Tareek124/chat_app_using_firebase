// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? myPassword, myEmail;
  bool? signInValid = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  OutlineInputBorder textBorders(Color color, double radius) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: color));
  }

  signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: myEmail!, password: myPassword!);
        signInValid = true;
      } on FirebaseAuthException catch (e) {
        signInValid = false;
        if (e.code == 'user-not-found') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.TOPSLIDE,
            title: "Error",
            desc: 'Email Doesn\'t exist',
          ).show();

          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.TOPSLIDE,
            desc: 'Wrong Password',
          ).show();

          print('Wrong password provided for that user.');
        }
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
                padding: const EdgeInsets.only(
                    top: 5, left: 40, right: 40, bottom: 20),
                child: Divider(
                  thickness: 2,
                  color: Colors.purple[900],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 40, right: 40),
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
                      await signIn();
                      if (signInValid!) {
                        Navigator.pushNamed(context, 'chat screen');
                        print("Sign In Succeeded");
                      } else {
                        print("Sign In Failed");
                      }
                    },
                    child: Text("Sign In",
                        style: GoogleFonts.dmSans(
                            textStyle: const TextStyle(fontSize: 25)))),
              ),
              Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "don't have account?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      )),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "sign up screen");
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.dmSans(
                            textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.purple[900],
                        )),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5, left: 40, right: 40),
                child: Divider(
                  thickness: 2,
                  color: Colors.purple[900],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
