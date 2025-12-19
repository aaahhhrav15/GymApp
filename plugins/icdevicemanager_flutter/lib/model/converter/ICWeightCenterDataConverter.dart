

import 'dart:convert';
import 'dart:developer';


import 'package:icdevicemanager_flutter/model/data/ICWeightCenterData.dart';
import 'package:json_annotation/json_annotation.dart';

class ICWeightCenterDataConverter implements JsonConverter<ICWeightCenterData, String> {
  const ICWeightCenterDataConverter();

  @override
  ICWeightCenterData fromJson(String data) {
    log("ICWeightCenterDataConverter---=data}   $data");
    Map<String, dynamic> map  = json.decode(data);
    return ICWeightCenterData.fromJson(map);
  }

  @override
  String toJson(ICWeightCenterData data) => json.encode(data);
}
