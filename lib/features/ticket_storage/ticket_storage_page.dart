import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/model.dart';

/// Экран “Хранения билетов”.
class TicketStoragePage extends StatefulWidget {
  const TicketStoragePage({Key? key}) : super(key: key);

  @override
  State<TicketStoragePage> createState() => _TicketStoragePageState();
}

class _TicketStoragePageState extends State<TicketStoragePage> {
  final _textFieldController = TextEditingController();
  List<PdfFile> _pdfFiles = [];
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _addPdf() {
    if (_key.currentState!.validate()) {
      _downloadPdfFile(_textFieldController.text);
      _textFieldController.clear();
      Navigator.of(context).pop();
    }
  }


  // Добавление файла 
  void _downloadPdfFile(String url) async {
    try {
      Response response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      if (response.statusCode == 200) {
        final String dir = (await getApplicationDocumentsDirectory()).path;
        final String filename =
            'my_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('$dir/$filename');
        await file.writeAsBytes(response.data);

        setState(() {
          _pdfFiles.add(PdfFile(url, filename));
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid PDF URL'),
              content:
                  Text('The provided URL is not valid or cannot be accessed.'),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  void _delete(int index){
    setState(() {
      _pdfFiles.removeAt(index);
    });
  }

  void _startDownload(int index) async {
    final pdfFile = _pdfFiles[index];
    pdfFile.downloading = true;

    try {
      await Dio().download(
          pdfFile.url,
          (await getApplicationDocumentsDirectory()).path +
              '/' +
              pdfFile.filename, onReceiveProgress: (receivedBytes, totalBytes) {
        if (totalBytes > 0) {
          pdfFile.progress = receivedBytes / totalBytes;
          setState(() {});
        }
      });

      pdfFile.progress = 1.0;
      pdfFile.downloading = false;

      setState(() {});
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Download Error'),
            content: Text('There was an error downloading the PDF file.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 30,
                ),
                Form(
                  key: _key,
                  child: TextFormField(
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.only(
                        left: 17.74,
                        top: 12,
                        bottom: 12.15,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(139, 41, 244, 1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(104, 42, 245, 1)),
                      ),
                      hintText: "Ссылка на pdf",
                    ),
                    obscureText: false,
                    validator: validateEmail,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                      backgroundColor: const Color.fromARGB(255, 197, 152, 223),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                  onPressed: _addPdf,
                  child: const Text(
                    "Добавить",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Хранение билетов",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: _pdfFiles.isEmpty
          ? Center(child: const Text("Здесь пока ничего нет", style: TextStyle(color: Colors.black, fontSize: 20,),))
          : ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(_pdfFiles[index].filename),
                  subtitle: 
                      LinearProgressIndicator(
                          value: _pdfFiles[index].progress),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20.0),
                        backgroundColor:
                            const Color.fromARGB(255, 197, 152, 223),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    onPressed:(){
                            _startDownload(index);
                          },
                    child: Text('Download'),
                  ),
                );
              },
              itemCount: _pdfFiles.length,
            ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20.0),
            backgroundColor: const Color.fromARGB(255, 197, 152, 223),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
        onPressed: _showBottomSheet,
        child: const Text(
          "Добавить",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String? validateEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return "E-mail address is required.";
    }

    String pattern = r'^https?:\/\/.+\.pdf$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(formEmail)) {
      return "Invalid format.";
    }
    return null;
  }
}
