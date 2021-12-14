import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

//La lógica y el estado interno de un StatefulWidget .
class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  //Se llama cuando este objeto se inserta en el árbol.
  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload){
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
      setState(() {
    });
  }

  //Se llama cuando este objeto se elimina del árbol de forma permanente
  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    SocketService socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus.index == 0)?
            const Icon(Icons.check_circle, color: Colors.blue):
            const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ]
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) => _bandTile(bands[index])
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: const Icon(Icons.add, size: 40),
        onPressed: addNewBand
      ),
   );
  }

  Dismissible _bandTile(Band band) {

    SocketService socketService = Provider.of<SocketService>(context, listen: false);
    
    return Dismissible(
      key: Key(UniqueKey().toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) => socketService.socket.emit('delete-band', {"id": band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          child: Text('Delete Band', style: TextStyle(color: Colors.white),),
          alignment: Alignment.centerLeft,
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('vote-band', {"id": band.id}),
      ),
    );
  }

  void addNewBand(){
    final textController = TextEditingController();

    if(Platform.isAndroid){
      showDialog(
        //En un staffulWidget, el context está de manera global
        context: context, 
        builder: (BuildContext context) =>
          AlertDialog(
          title: const Text('New band name: '),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text)
            )
          ],
        )
      );
    }

    if(Platform.isIOS){
      showCupertinoDialog(
        context: context, 
        builder: (context) =>
          CupertinoAlertDialog(
            title: const Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                //Cuando se presione enter, este va a ser el botón por defecto
                isDefaultAction: true,
                child: const Text('Add'),
                onPressed: () => addBandToList(textController.text)
              ),
              CupertinoDialogAction(
                //Cuando se presione enter, este va a ser el botón por defecto
                isDestructiveAction: true,
                child: const Text('Dismiss'),
                onPressed: () => Navigator.pop(context)
              )
            ]
          )
      );
    }
  }

  void addBandToList( String name ){

    SocketService socketService = Provider.of<SocketService>(context, listen: false);

    if(name.trim().length > 1){
      socketService.socket.emit('add-band', {"name": name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = {};

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap)
    );
  }
}