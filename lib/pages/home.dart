import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 1),
    Band(id: '3', name: 'Héroes del silencio', votes: 2),
    Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) => _bandTile(bands[index])
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: const Icon(Icons.add, size: 40),
        onPressed: addNewBand
      ),
   );
  }

  Dismissible _bandTile(Band band) {
    return Dismissible(
      key: Key(UniqueKey().toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) {
        print("${direction} ${band.id}");
      },
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
        onTap: () {
        },
      ),
    );
  }

  void addNewBand(){
    final textController = TextEditingController();

    if(!Platform.isAndroid){
      showDialog(
        //En un staffulWidget, el context está de manera global
        context: context, 
        builder: (context) {
          return AlertDialog(
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
          );
        }
      );
    }

    if(!Platform.isIOS){
      showCupertinoDialog(
        context: context, 
        builder: (context) {
          return CupertinoAlertDialog(
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
          );
        }
      );
    }
  }

  void addBandToList( String name ){
    if(name.length > 1){
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      //Redibujamos el StatefulWidget
      setState(() {
        
      });
    }

    Navigator.pop(context);
  }
}