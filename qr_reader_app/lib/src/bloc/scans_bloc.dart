import 'dart:async';
import 'package:qr_reader_app/src/providers/db_provider.dart';
import 'package:qr_reader_app/src/bloc/validator.dart';

class ScansBloc with Validators {
  static final ScansBloc _singleton = new ScansBloc._internal();

  factory ScansBloc(){
    return _singleton;
  }
  
  ScansBloc._internal(){
    //Obtener Scans de la Base de Datos
    obtenerScans();
  }

  final _scansController = StreamController<List<ScanModel>>.broadcast();

  Stream<List<ScanModel>> get scansStream      => _scansController.stream.transform(validarGeo);
  Stream<List<ScanModel>> get scansStreamHttp  => _scansController.stream.transform(validarHttp);

  dispose(){
    _scansController?.close(); //Importante el ? para validar
  }

  obtenerScans() async{
    _scansController.sink.add( await DBProvider.db.getTodosScans() );
  }

  agregarScan( ScanModel nuevoScan ) async{
    await DBProvider.db.createScan(nuevoScan);
    obtenerScans();
  }

  borrarScan( int id ) async{
    await DBProvider.db.deleteScan(id);
    obtenerScans();
  }

  borrarScansTodos() async{
    await DBProvider.db.deleteAll();
    obtenerScans();
  }
}