import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pokemonprueba/services/storage_service.dart';
import 'package:pokemonprueba/ui/home_screen.dart';
import 'package:pokemonprueba/ui/shared/custom_input.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

final _formKey = GlobalKey<FormState>();

class _LoginViewState extends State<LoginView> {
  validatorInput(value) {
    if (value == null || value.isEmpty) {
      return 'Llene el campo';
    }
    return null;
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  User? user;
  TextEditingController controllerUsr = TextEditingController();
  TextEditingController controllerPsw = TextEditingController();
    static StorageService storageService = StorageService();


   @override
  void initState() {
    super.initState();
    readDataSaved();
  }

   void readDataSaved() async {

  bool exists = await storageService.comprobarClave("username");


    if (exists) {
    
      controllerUsr.value = TextEditingValue(
          text: await storageService.obtenerValor("username") ?? "");
      controllerPsw.value = TextEditingValue(
          text: await storageService.obtenerValor("password") ?? "");
      setState(() {});
    }
  
  }

  void saveData() async{
    if (_formKey.currentState!.validate()) {
      //Guardar los datos
      await storageService.guardarValor("username",controllerUsr.value.text);
      await storageService.guardarValor("password",controllerPsw.value.text);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }else{
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    

    void googleSingnIn() async {
      try {
        GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        await auth.signInWithProvider(googleAuthProvider);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen()),
        );
      } catch (error) {
        print(error);
      }
    }

    Widget googleSignInButton() {
      return Center(
        child: SizedBox(
          height: 50,
          child: SignInButton(
            Buttons.google,
            text: 'Entra con Google',
            onPressed: () {
              googleSingnIn();
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 77, 77),
      body: Stack(
        children: [
          SizedBox(
            height: size.height * 0.2,
            width: size.width,
            child: ClipPath(
              clipper: Encabezado(),
              child: Container(
                color: const Color.fromARGB(255, 186, 58, 49),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 70,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 100,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 130,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: CustomTextFormField(
                      label: 'Nombre',
                      obscureText: false,
                      controller: controllerUsr,
                      validator: (value) => validatorInput(value),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: CustomTextFormField(
                      label: 'Contraseña ',
                      obscureText: true,
                      controller: controllerPsw,
                      validator: (value) => validatorInput(value),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      saveData();
                    },
                    label: Text("Ingresar"),
                    icon: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "O ingresa con",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  googleSignInButton(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Encabezado extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
