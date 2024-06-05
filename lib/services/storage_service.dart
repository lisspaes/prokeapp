import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService{
  static const storage = FlutterSecureStorage();
  //Recupera los datos del usuario 
  Future<String?> obtenerValor(String nombre) async {
    return await storage.read(key: nombre);
  }

  ///Guarda los datos del usuario 
  Future guardarValor(String nombre, String value) async{
    await storage.write(key: nombre, value: value);
  }

  //Comprueba si existe la clave
  Future<bool> comprobarClave(String clave){
    return storage.containsKey(key: clave);
  }
  //Comprueba si existe la clave
  Future<void> eliminarTodo(){
    return storage.deleteAll();
  }

  }