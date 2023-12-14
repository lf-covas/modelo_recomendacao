import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _topnController = TextEditingController();
  List<Recommendation> _recommendations = [];
  bool isLoading = false;

  void _fetchData() {
    String fullURL = "${_urlController.text}?user_id=${_userIdController.text}&topn=${_topnController.text}";
    http.get(Uri.parse(fullURL)).then((response) {
      var jsonData = json.decode(response.body);
      var recommendationsData = json.decode(jsonData['recommendations']) as List;

      List<Recommendation> movie_recommendations = recommendationsData.map((model) =>
        Recommendation(model["id"], model["filme"], model["similaridade"])
      ).cast<Recommendation>().toList();

      setState(() {
        _recommendations = movie_recommendations;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildTextField(_urlController, 'URL'),
          _buildTextField(_userIdController, 'User ID', TextInputType.number),
          _buildTextField(_topnController, 'Top N', TextInputType.number),
          _buildFetchButton(),
          const SizedBox(height: 20),
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }

  Widget _buildFetchButton() {
    return ElevatedButton(
      onPressed: _fetchData,
      child: const Text('Fetch Data'),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Filme')),
        DataColumn(label: Text('Similaridade')),
      ],
      rows: _recommendations.map<DataRow>((recommendation) => DataRow(
        cells: <DataCell>[
          DataCell(Text(recommendation.id.toString())),
          DataCell(Text(recommendation.filme)),
          DataCell(Text(recommendation.similaridade.toStringAsFixed(3))),
        ],
      )).toList(),
    );
  }
}

class Recommendation {
  final int id;
  final String filme;
  final double similaridade;

  Recommendation(this.id, this.filme, this.similaridade);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filme': filme,
      'similaridade': similaridade,
    };
  }
}
