



import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:json_annotation/json_annotation.dart';


part 'ICScanDeviceInfo.g.dart';
@JsonSerializable()
class ICScanDeviceInfo {
  String? name;
  ICDeviceType? type;
  ICDeviceSubType? subType;
  ICDeviceCommunicationType? communicationType;
  String? macAddr;

  List<String>? services;
  int rssi = 0;
  int st_no = 0;
  int nodeId = 0;
  int deviceFlag = 0;

  ICScanDeviceInfo();

  factory ICScanDeviceInfo.fromJson(Map<String, dynamic> json) => _$ICScanDeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ICScanDeviceInfoToJson(this);

  @override
  String toString() {
    return 'ICScanDeviceInfo{name: $name, type: $type, subType: $subType, communicationType: $communicationType, macAddr: $macAddr, services: $services, rssi: $rssi, st_no: $st_no, nodeId: $nodeId, deviceFlag: $deviceFlag}';
  }
}
