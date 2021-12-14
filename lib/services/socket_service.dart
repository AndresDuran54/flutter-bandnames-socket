import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  IO.Socket get socket => _socket; 
  ServerStatus get serverStatus => _serverStatus;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){

    _socket = IO.io('http://192.168.1.7:3000',{
      'transports': ['websocket'],
      'autoConnect': true
    });

    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    // El payload lo mandamos desde el servidor como un objeto de tipo JS(JSNO))
    // Y lo recibimos aca como un objeto de tipo mapa
    // _socket.on('nuevo-mensaje', (payload) {
    //  print('Nombre: ${payload['nombre']}');
    //  print('Mensaje: ${payload['mensaje']}');
    //  print('Mensaje:' + (payload['mensaje2'] ?? "No hay mensaje 2"));
    // });
  }
}