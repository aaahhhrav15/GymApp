

import 'package:icdevicemanager_flutter/model/device/ICScanDeviceInfo.dart';

abstract class  ICScanDeviceDelegate{
  /*
   * 扫描结果回调
   * @param deviceInfo 扫描到的设备信息
   */
  void onScanResult(ICScanDeviceInfo deviceInfo);
}