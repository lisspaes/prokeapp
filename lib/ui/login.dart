import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? user;

  @override
  void initState() {
    auth.authStateChanges().listen((event) {
      setState(() {
        user = event;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    void googleSingnIn(){
      try{
        GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        auth.signInWithProvider(googleAuthProvider);
      }catch(error){
        print(error);
      }
    }

    Widget googleSignInButton(){
      return Center(
        child: SizedBox(
          height: 50,
          child: SignInButton(
            Buttons.google,
            text: 'Entra con Google',
            onPressed: (){
              googleSingnIn();
            },
          ),
        ),
      );
    }

    Widget userInfo(){
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    user!.photoURL!
                  )
                )
              ),
            ),
            Text(user!.email!),
            ElevatedButton(onPressed: auth.signOut, child: const Text("Salir"))
          ],
        ),
      );
    }

    return Scaffold(
      body: user != null 
      ? userInfo()
      : googleSignInButton(),
    );
  }
}