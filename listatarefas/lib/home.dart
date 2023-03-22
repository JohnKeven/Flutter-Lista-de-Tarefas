import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
// ignore_for_file: camel_case_types

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  List _listaDeTarefas = [];
  Map<String, dynamic> itemRemovido = Map();
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File('${diretorio.path}/dados.json ');
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefa = Map();
    tarefa['Titulo'] = textoDigitado;
    tarefa['Realizada'] = false;
    setState(() {
      _listaDeTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = '';
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_listaDeTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch(e){
      return null;
    }
  }

  Widget _criarItemLista(context, indice) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){
        itemRemovido = _listaDeTarefas[indice];
        _listaDeTarefas.removeAt(indice);
        _salvarArquivo();

        var snackbar = SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            content: Text('Tarefa removida!'),
            action: SnackBarAction(
                label: 'Desfazer',
                onPressed: (){
                  setState(() {
                    _listaDeTarefas.insert(indice, itemRemovido);
                  });
                  _salvarArquivo();
                }
            ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);

      },
      background: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Icon(Icons.delete, color: Colors.white,)
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaDeTarefas[indice]['Titulo']),
        value: _listaDeTarefas[indice]['Realizada'],
        onChanged: (valor){
          setState(() {
            _listaDeTarefas[indice]['Realizada'] = valor;
          });
          _salvarArquivo();
        },
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _salvarArquivo();
    _lerArquivo().then(
        (dados){
          setState(() {
            _listaDeTarefas = json.decode(dados);
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Lista de Tarefas')
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _listaDeTarefas.length,
                itemBuilder: _criarItemLista,
              )
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          return showDialog(
            context: context,
            builder: (context){

              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                 controller: _controllerTarefa,
                 decoration: const InputDecoration(
                   labelText: 'Digite sua tarefa',
                 ),
                  onChanged: (text){
                  },
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Salvar'),
                    onPressed: (){
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );

            }
          );
        },
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      /*FloatingActionButton.extended(
        //child: const Icon(Icons.add) ,
        label: const Text('Adicionar'),
        /*shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        )*/
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        //elevation: 12,
        //mini: true,
        onPressed: (){
          print('Botão pressionado');
        },
      ), */
      /*bottomNavigationBar: BottomAppBar(
        //shape: CircularNotchedRectangle(),
        child: Row(
          children: [
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.menu)
            ),
          ],
        ),
      ),*/
    );
  }
}
