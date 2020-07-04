import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=744c1599";

void main()async{
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request); //await futuro
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);

  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);

  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Convesor \$"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) { //expecificar o que ele vai mostra na tela
          switch(snapshot.connectionState){ //ver o estado da conexão
            case ConnectionState.none: // não tiver conectado ou
            case ConnectionState.waiting: // esperando uma conexão
              return Center( //ele vai retornar um widgter texto centralizado
                child: Text("Carregando Dados...", // escrito isso
                  style: TextStyle(
                      color: Colors.amber,
                    fontSize: 25.0),
                textAlign: TextAlign.center,)
              );
            default: // causo ao contrario ele tenha obtido alguma coisa
              if(snapshot.hasError){ //Se tem um erro
                return Center( //Ele vai me retornar um outro texto centralizado
                    child: Text("Error ao Carregar Dados :(",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0),
                      textAlign: TextAlign.center,)
                );
              }else { //causo ao contrario, não tenha erro
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView( //tela rolavel
                  padding: EdgeInsets.all(10.0),
                  child: Column( //filho //coluna
                    crossAxisAlignment: CrossAxisAlignment.stretch, //centralizar e alagar tudo
                    children: <Widget>[
                    Icon(Icons.monetization_on, size: 150.0, color: Colors.amber, ),
                      buildTextFielid("Reais", "R\$", realController, _realChanged),
                      Divider(),//isso vai dá um espaço entre as caixinhas
                      buildTextFielid("Dólares", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextFielid("Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        }),
    );
  }
}

Widget buildTextFielid(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}