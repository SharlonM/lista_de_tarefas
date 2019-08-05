import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _lista = [];
  final textoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          centerTitle: true,
          backgroundColor: Colors.pink,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(0, 1, 5, 1),
          child: layoutPrincipal(),
        ));
  }

  Widget layoutPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: campoDeTexto(),
              ),
            ),
            botao()
          ],
        ),
        Expanded(
          child: lista_exibicao(),
        )
      ],
    );
  }

  ListView lista_exibicao() {
    return ListView.separated(
      itemCount: _lista.length,
      padding: EdgeInsets.only(top: 20),
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(_lista[index]["title"]),
          value: _lista[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(_lista[index]["ok"] ? Icons.check : Icons.error),
          ),
          onChanged: (b){
            setState(() {
              _lista[index]["ok"] = b;
            });
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  void addList() {
    setState(() {
      String tarefa = textoController.text;
      Map<String, dynamic> novaLista = new Map();
      novaLista["title"] = tarefa;
      novaLista["ok"] = false;
      _lista.add(novaLista);
      textoController.clear();
    });
  }

  RaisedButton botao() {
    return RaisedButton(
      onPressed: addList,
      textColor: Colors.white,
      color: Colors.pink,
      padding: EdgeInsets.only(left: 8, right: 8, top: 7, bottom: 7),
      child: Container(
          child: Text(
        "Add",
        style: TextStyle(fontSize: 15),
      )),
    );
  }

  TextField campoDeTexto() {
    return TextField(
      decoration: InputDecoration(
          labelText: "Nova Tarefa",
          labelStyle: TextStyle(color: Colors.pink, fontSize: 15)),
      textAlign: TextAlign.start,
      style: TextStyle(color: Colors.black, fontSize: 18),
      controller: textoController,
    );
  }

  Future<File> _getFile() async {
    final diretory = await getApplicationDocumentsDirectory();
    return File("${diretory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_lista);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
