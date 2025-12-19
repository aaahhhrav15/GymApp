import 'package:icdevicemanager_flutter/model/converter/ICDeviceInfoExtConverter.dart';
import 'package:icdevicemanager_flutter/model/device/ICDeviceInfoExt.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ICDeviceInfo.g.dart';

@JsonSerializable()
class ICDeviceInfo {
  String mac = "";

  String model = "";

  String sn = "";

  String firmwareVer = "";

  String softwareVer = "";

  String hardwareVer = "";

  String manufactureName = "";

  int kg_scale_division=0;
  int lb_scale_division=0;
  bool isSupportHr=false;
  bool isSupportGravity=false;
  bool isSupportBalance=false;
  bool isSupportOTA=false;
  bool isSupportOffline=false;
  int bfDataCalcType=0;
  bool isSupportUserInfo=false;
  int maxUserCount=0;
  int batteryType=0;
  ICBFAType? bfaType;
  ICBFAType? bfaType2;
  bool isSupportUnitKg=false;
  bool isSupportUnitLb=false;
  bool isSupportUnitStLb=false;
  bool isSupportUnitJin=false;
  bool isSupportChangePole=false;
  int pole=0;
  int impendenceType=0;
  int impendenceCount=0;
  int impendencePrecision=0;
  int impendencePropert=0;
  bool enableMeasureImpendence=false;
  bool enableMeasureHr=false;
  bool enableMeasureBalance=false;
  bool enableMeasureGravity =false;

  @ICDeviceInfoExtConverter()
  ICDeviceInfoExt? extInfo;

  ICDeviceInfo();

  factory ICDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$ICDeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ICDeviceInfoToJson(this);

  @override
  String toString() {
    return 'ICDeviceInfo{mac: $mac, model: $model, sn: $sn, firmwareVer: $firmwareVer, softwareVer: $softwareVer, hardwareVer: $hardwareVer, manufactureName: $manufactureName, kg_scale_division: $kg_scale_division, lb_scale_division: $lb_scale_division, isSupportHr: $isSupportHr, isSupportGravity: $isSupportGravity, isSupportBalance: $isSupportBalance, isSupportOTA: $isSupportOTA, isSupportOffline: $isSupportOffline, bfDataCalcType: $bfDataCalcType, isSupportUserInfo: $isSupportUserInfo, maxUserCount: $maxUserCount, batteryType: $batteryType, bfaType: $bfaType, bfaType2: $bfaType2, isSupportUnitKg: $isSupportUnitKg, isSupportUnitLb: $isSupportUnitLb, isSupportUnitStLb: $isSupportUnitStLb, isSupportUnitJin: $isSupportUnitJin, isSupportChangePole: $isSupportChangePole, pole: $pole, impendenceType: $impendenceType, impendenceCount: $impendenceCount, impendencePrecision: $impendencePrecision, impendencePropert: $impendencePropert, enableMeasureImpendence: $enableMeasureImpendence, enableMeasureHr: $enableMeasureHr, enableMeasureBalance: $enableMeasureBalance, enableMeasureGravity: $enableMeasureGravity, extInfo: $extInfo}';
  }
}
