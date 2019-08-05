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
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;
  final textoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _lista = json.decode(data);
      });
    });
  }

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
          child: RefreshIndicator(child: lista_exibicao(), onRefresh: refrash),
        )
      ],
    );
  }

  ListView lista_exibicao() {
    return ListView.separated(
      itemCount: _lista.length,
      padding: EdgeInsets.only(top: 20),
      itemBuilder: deslizarItem,
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  Dismissible deslizarItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.8, 0),
          child: Icon(Icons.delete_forever, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: listItemBuilder(context, index),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_lista[index]);
          _lastRemovedPos = index;
          _lista.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \" ${_lastRemoved["title"]} \" removida !"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _lista.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  CheckboxListTile listItemBuilder(context, index) {
    return CheckboxListTile(
      title: Text(_lista[index]["title"]),
      value: _lista[index]["ok"],
      activeColor: Colors.pink,
      secondary: CircleAvatar(
        child: Icon(_lista[index]["ok"] ? Icons.check : Icons.error),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      onChanged: (b) {
        setState(() {
          _lista[index]["ok"] = b;
          _saveData();
        });
      },
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
      _saveData();
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

  Future<void> refrash() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _lista.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
  }
}
