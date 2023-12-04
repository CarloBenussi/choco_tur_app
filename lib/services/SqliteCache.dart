import 'dart:io';
import 'dart:typed_data';

import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteCache {
  static const _toursTableName = "tours";
  static const _tourStopsTableName = "tourStops";
  static const _chocolatesTableName = "chocolates";
  static const _tourStopsRelationsTableName = "tourStopsRelations";
  static const _tourStopChocolatesRelationsTableName =
      "tourStopChocolatesRelations";

  static const String _toursTableSchema =
      "id INTEGER PRIMARY KEY, name TEXT, costEuro REAL, lengthKm REAL, avgDuration TEXT, description TEXT, numStops INTEGER, numTastings INTEGER, mainImageUrl TEXT";
  static const String _tourStopsTableSchema =
      "id INTEGER PRIMARY KEY, name TEXT, description TEXT, latitude REAL, longitude REAL, hasTasting INTEGER, mainImageUrl TEXT";
  static const String _chocolatesTableSchema =
      "id INTEGER PRIMARY KEY, name TEXT, description TEXT, mainImageUrl TEXT";
  static const String _tourStopsRelationsSchema =
      "id INTEGER PRIMARY KEY, tourId INTEGER, stopId INTEGER, stopPosition INTEGER";
  static const String _stopChocolatesRelationsSchema =
      "id INTEGER PRIMARY KEY, stopId INTEGER, chocolateId INTEGER";

  static Future<Database>? _db;
  static SqliteCache? _cache;

  static void init() async {
    String path = join(
      await getDatabasesPath(),
      'choco_tur_cache.db',
    );

    bool exists = await databaseExists(path);
    if (!exists) {
      // Copy from asset.
      ByteData data =
          await rootBundle.load(url.join("assets/mock_db", "mock_tours.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written.
      await File(path).writeAsBytes(bytes, flush: true);
    }

    _db = openDatabase(
      path,
      onCreate: (db, version) async {
        db.execute(
          'CREATE TABLE $_toursTableName($_toursTableSchema)',
        );
        db.execute(
          'CREATE TABLE $_tourStopsTableName($_tourStopsTableSchema)',
        );
        db.execute(
          'CREATE TABLE $_chocolatesTableName($_chocolatesTableSchema)',
        );
        db.execute(
          'CREATE TABLE $_tourStopsRelationsTableName($_tourStopsRelationsSchema)',
        );
        db.execute(
          'CREATE TABLE $_tourStopChocolatesRelationsTableName($_stopChocolatesRelationsSchema)',
        );
      },
      version: 1,
    );
  }

  static Future<SqliteCache> getInstance() async {
    return (_cache != null) ? _cache! : SqliteCache();
  }

  Future<List<ChocoTurTour>> getAllTours() async {
    final database = await _db!;

    List<Map<String, dynamic>> tourMaps = await database.query(
      _toursTableName,
      columns: [
        'id',
        'name',
        'costEuro',
        'lengthKm',
        'avgDuration',
        'description',
        'numStops',
        'numTastings',
        'mainImageUrl'
      ],
    );

    List<ChocoTurTour> tours = [];
    for (var i = 0; i < tourMaps.length; ++i) {
      tours.add(ChocoTurTour.fromMap(tourMaps[i]));
    }

    return tours;
  }

  Future<List<ChocoTurTourStop>> getTourStops(String tourId) async {
    final database = await _db!;

    List<Map<String, dynamic>> tourRelationsMaps = await database.query(
      _tourStopsRelationsTableName,
      columns: [
        'id',
        'tourId',
        'stopId',
        'stopPosition',
      ],
      where: "tourId = ?",
      whereArgs: [tourId],
      orderBy: "stopPosition ASC",
    );

    if (tourRelationsMaps.isEmpty) {
      return Future.error(Exception('Got no stops for tour $tourId'));
    }

    List<ChocoTurTourStop> tourStops = [];
    for (var i = 0; i < tourRelationsMaps.length; ++i) {
      tourStops.add(await getTourStopFromId(tourRelationsMaps[i]['stopId']));
    }

    return tourStops;
  }

  Future<List<String>> getTourStopIds(String tourId) async {
    final database = await _db!;

    List<Map<String, dynamic>> tourRelationsMaps = await database.query(
      _tourStopsRelationsTableName,
      columns: [
        'id',
        'tourId',
        'stopId',
        'stopPosition',
      ],
      where: "tourId = ?",
      whereArgs: [tourId],
      orderBy: "stopPosition ASC",
    );

    if (tourRelationsMaps.isEmpty) {
      return Future.error(Exception('Got no stops for tour $tourId'));
    }

    List<String> tourStopIds = [];
    for (var i = 0; i < tourRelationsMaps.length; ++i) {
      tourStopIds.add(tourRelationsMaps[i]['stopId']);
    }

    return tourStopIds;
  }

  Future<ChocoTurTourStop> getTourStopFromId(String stopId) async {
    final database = await _db!;

    List<Map<String, dynamic>> tourStopMap = await database.query(
      _tourStopsTableName,
      columns: [
        'id',
        'name',
        'description',
        'latitude',
        'longitude',
        'hasTasting',
        'mainImageUrl',
      ],
      where: "id = ?",
      whereArgs: [stopId],
    );

    if (tourStopMap.isEmpty) {
      return Future.error(Exception('Found no stop with id $stopId'));
    }

    if (tourStopMap.length > 1) {
      return Future.error(Exception('Found multiple stops with id $stopId'));
    }

    return ChocoTurTourStop.fromMap(tourStopMap[0]);
  }

  Future<Chocolate?> getStopchocolate(String stopId) async {
    final database = await _db!;

    List<Map<String, dynamic>> stopChocolateRelationsMap = await database.query(
      _tourStopChocolatesRelationsTableName,
      columns: [
        'id',
        'stopId',
        'chocolateId',
      ],
      where: "stopId = ?",
      whereArgs: [stopId],
    );

    if (stopChocolateRelationsMap.isEmpty) {
      LoggerInstance.logger.d('Stop $stopId has no chocolate tastings.');
      return null;
    }

    if (stopChocolateRelationsMap.length > 1) {
      LoggerInstance.logger.w(
          'Found multiple chocolates for stop $stopId, only the first one will be considered.');
    }

    return getChocolateFromId(stopChocolateRelationsMap[0]['chocolateId']);
  }

  Future<Chocolate?> getChocolateFromId(String chocolateId) async {
    final database = await _db!;

    List<Map<String, dynamic>> chocolateMap = await database.query(
      _chocolatesTableName,
      columns: [
        'id',
        'name',
        'description',
        'mainImageUrl',
      ],
      where: "id = ?",
      whereArgs: [chocolateId],
    );

    if (chocolateMap.isEmpty) {
      return Future.error(Exception('Found no chocolate with id $chocolateId'));
    }

    if (chocolateMap.length > 1) {
      return Future.error(
          Exception('Found multiple chocolates with id $chocolateId'));
    }

    return Chocolate.fromMap(chocolateMap[0]);
  }
}
