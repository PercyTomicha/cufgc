import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:qr_reader_app/src/models/scan_model.dart';
export 'package:qr_reader_app/src/models/scan_model.dart';

class DBProvider{
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async{
    if( _database != null ) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async{
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join( documentsDirectory.path,'ScansDB.db' ); //Para que no salga error import 'package:path/path.dart';

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: ( Database db, int version ) async{
        await db.execute(
          'CREATE TABLE Scans ('
          ' id INTEGER PRIMARY KEY,'
          ' tipo TEXT,'
          ' valor TEXT'
          ')'
        );
      }
    );
  }

  //Crear Registros
  nuevoScanRaw( ScanModel nuevoScan ) async{
    final db = await database;
    final res = await db.rawInsert(
      "INSERT INTO Scans (id, tipo, valor) "
      "VALUES( ${nuevoScan.id}, '${nuevoScan.tipo}', '${nuevoScan.valor}' )"
    );
    return res;
  }

  createScan( ScanModel nuevoScan ) async{
    final db = await database;
    final res = await db.insert('Scans', nuevoScan.toJson() );
    //print(res);
    return res;
  }

  //Select - Obtener Información
  Future<ScanModel> getScanId( int id ) async{
    final db = await database;
    final res = await db.query('Scans',where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ?
            ScanModel.fromJson( res.first ) : null;
  }

  Future<List<ScanModel>> getTodosScans() async{
    final db = await database;
    final res = await db.query('Scans');
    List<ScanModel> list = res.isNotEmpty
                            ? res.map( (scan) => ScanModel.fromJson(scan) ).toList()
                            : [];
    return list;
  }

  Future<List<ScanModel>> getScansPorTipo( String tipo ) async{
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo = '$tipo'");
    List<ScanModel> list = res.isNotEmpty
                            ? res.map( (scan) => ScanModel.fromJson(scan) ).toList()
                            : [];
    return list;
  }

  //Actualizar Registros
  Future<int> updateScan( ScanModel nuevoScan ) async{
    final db = await database;
    final res = await db.update('Scans', nuevoScan.toJson(), where: 'id = ?', whereArgs: [nuevoScan.id] );
    return res;
  }

  //Eliminar Registros
  Future<int> deleteScan( int id ) async{
    final db = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id] );
    return res;
  }
  
  Future<int> deleteAll() async{
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Scans');
    return res;
  }
}