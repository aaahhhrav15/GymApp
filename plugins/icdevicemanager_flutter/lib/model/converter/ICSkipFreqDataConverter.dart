import 'dart:convert';



import 'package:icdevicemanager_flutter/model/data/ICSkipFreqData.dart';
import 'package:json_annotation/json_annotation.dart';

class ICSkipFreqDataConverter implements JsonConverter<List<ICSkipFreqData>?, String> {
  const ICSkipFreqDataConverter();

  @override
  List<ICSkipFreqData>? fromJson(String data) {
    return List<ICSkipFreqData>.from(json.decode(data).map((model)=> ICSkipFreqData.fromJson(model)));
  }

  @override
  String toJson(List<ICSkipFreqData>? data) => json.encode(data);
}
