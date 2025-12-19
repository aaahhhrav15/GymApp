import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:icdevicemanager_flutter/callback/ICAddDeviceCallBack.dart';
import 'package:icdevicemanager_flutter/callback/ICDeviceManagerCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICFatAlgorithmsSettingCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICRemoveDeviceCallBack.dart';
import 'package:icdevicemanager_flutter/callback/ICScanDeviceDelegate.dart';
import 'package:icdevicemanager_flutter/callback/ICSettingCallback.dart';
import 'package:icdevicemanager_flutter/ic_bluetooth_sdk_platform_interface.dart';
import 'package:icdevicemanager_flutter/model/data/ICCoordData.dart';
import 'package:icdevicemanager_flutter/model/data/ICKitchenScaleData.dart';
import 'package:icdevicemanager_flutter/model/data/ICRulerData.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipData.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipLightSettingData.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipSoundSettingData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightCenterData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightHistoryData.dart';
import 'package:icdevicemanager_flutter/model/device/ICDevice.dart';
import 'package:icdevicemanager_flutter/model/device/ICDeviceInfo.dart';
import 'package:icdevicemanager_flutter/model/device/ICScanDeviceInfo.dart';
import 'package:icdevicemanager_flutter/model/device/ICUserInfo.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:icdevicemanager_flutter/model/other/ICDeviceManagerConfig.dart';
import 'package:icdevicemanager_flutter/model/other/ICMapKey.dart';
import 'package:icdevicemanager_flutter/model/other/ICWPublishEvent.dart';
import 'package:icdevicemanager_flutter/model/other/ICWUploadEvent.dart';
import 'package:icdevicemanager_flutter/utils/ICConverUtil.dart';

import 'callback/ICCommonCallback.dart';



class MethodChannelIcBluetoothSdk extends IcBluetoothSdkPlatform {
  @visibleForTesting
  final channel = const MethodChannel('ic_bluetooth_sdk');

  ICScanDeviceDelegate? scanDeviceDelegate;

  ICDeviceManagerDelegate? deviceManagerDelegate;

  @override
  void setDeviceManagerDelegate(ICDeviceManagerDelegate? delegate) {
    print("🔧 [MethodChannel] setDeviceManagerDelegate called");
    deviceManagerDelegate = delegate;
    if (delegate != null) {
      // Notify native side
      channel.invokeMethod('SetDeviceManagerDelegate');
      print("✅ [MethodChannel] SetDeviceManagerDelegate sent to native");
    }
  }

  @override
  void setDeviceScanDelegate(ICScanDeviceDelegate? delegate) {
    print("🔧 [MethodChannel] setDeviceScanDelegate called");
    scanDeviceDelegate = delegate;
    if (delegate != null) {
      // Notify native side
      channel.invokeMethod('SetDeviceScanDelegate');
      print("✅ [MethodChannel] SetDeviceScanDelegate sent to native");
    }
  }

  @override
  void onMethodCall() {
    channel.setMethodCallHandler((call) => onReceiveMsg(call));
  }

  @override
  void initSDK(ICDeviceManagerConfig config) async {
    channel.invokeMethod<String>(ICWPublishEvent.initSDK.value);
    log("initSdk---");
    var result = await channel.invokeMethod(ICWPublishEvent.initSDK.value, "");

  }


  @override
  void addDevice(ICDevice device, ICAddDeviceCallBack? callBack) async {
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    if (device.macAddr == null) return;
    var result =
        await channel.invokeMethod(ICWPublishEvent.addDevice.value, hashMap);
    var resultCode = result[ICMapKey.EnumName];
    if (callBack != null) {
      callBack.callBack(device, ICConverUtil.AddDeviceCallBackCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$result  method");
  }

  @override
  void addDevices(List<ICDevice> devices, ICAddDeviceCallBack? callback) async {
    for (var device in devices) {
      var hashMap = HashMap();
      hashMap[ICMapKey.Mac] = device.macAddr;
      if (device.macAddr == null) return;
      var result =
          await channel.invokeMethod(ICWPublishEvent.addDevice.value, hashMap);
      var resultCode = result[ICMapKey.EnumName];
      if (callback != null) {
        callback.callBack(device, ICConverUtil.AddDeviceCallBackCodeNameOf(resultCode));
      }
      log("ICBluetoothManger result---$result  method");
    }





  }

  @override
  void changeStName(
      ICDevice device, String name, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result =
        await channel.invokeMethod(ICWPublishEvent.changeStName.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void changeStNo(ICDevice device, int dstId, int st_no,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.DstId] = dstId;
    hashMap[ICMapKey.StNo] = st_no;

    var result =
        await channel.invokeMethod(ICWPublishEvent.changeStName.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void configWifi(ICDevice device, String? ssid, String? password,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    if (ssid == null) return;
    if (password == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.SSID] = ssid;
    hashMap[ICMapKey.Password] = password;

    var result =
        await channel.invokeMethod(ICWPublishEvent.configWifi.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name method");
  }

  @override
  void deleteTareWeight(ICDevice device, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;

    var result = await channel.invokeMethod(
        ICWPublishEvent.deleteTareWeight.value, hashMap);
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    var name = result[ICMapKey.Method];
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void lockStSkip(ICDevice device, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result =
        await channel.invokeMethod(ICWPublishEvent.lockStSkip.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void powerOffKitchenScale(
      ICDevice device, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result = await channel.invokeMethod(
        ICWPublishEvent.powerOffKitchenScale.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void queryStAllNode(ICDevice device, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result = await channel.invokeMethod(
        ICWPublishEvent.queryStAllNode.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void removeDevice(ICDevice device, ICRemoveDeviceCallBack? callBack) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result =
        await channel.invokeMethod(ICWPublishEvent.removeDevice.value, hashMap);
    var name = result[ICMapKey.Method];
    var resultCode = result[ICMapKey.EnumName];
    if (callBack != null) {
      callBack.callBack(device, ICConverUtil.removeDeviceCallBackCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name method");
  }

  @override
  void removeDevices(
      List<ICDevice> devices, ICRemoveDeviceCallBack? callBack) async {
    if (devices.isEmpty) return;
    for (var device in devices) {
      var hashMap = HashMap();
      hashMap[ICMapKey.Mac] = device.macAddr;
      var result = await channel.invokeMethod(
          ICWPublishEvent.removeDevice.value, hashMap);
      var name = result[ICMapKey.Method];
      var resultCode = result[ICMapKey.EnumName];
      if (callBack != null) {
        callBack.callBack(
            device, ICConverUtil.removeDeviceCallBackCodeNameOf(resultCode));
      }
      log("ICBluetoothManger result---$name method");
    }
  }

  @override
  void scanDevice() async {
    channel.invokeMethod(ICWPublishEvent.startScan.value, "");
  }

  @override
  void setDebugCommand(ICDevice device, Map<String, Object> cmd,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    channel.invokeMethod(ICWPublishEvent.debugCommand.value, cmd);
  }

  @override
  void setKitchenScaleUnit(ICDevice device, ICKitchenScaleUnit unit,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = unit.name;

    var result = await channel.invokeMethod(
        ICWPublishEvent.setKitchenSaleUnit.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setNutritionFacts(ICDevice device, ICKitchenScaleNutritionFactType type,
      int value, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = type.name;

    var result = await channel.invokeMethod(
        ICWPublishEvent.KitchenSetNutritionFacts.value, hashMap);
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
  }

  @override
  void setOtherParams(ICDevice device, int type, Object param,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.ObjectValue] = param;
    var result = await channel.invokeMethod(
        ICWPublishEvent.setOtherParams.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setRulerBodyPartsType(ICDevice device, ICRulerBodyPartsType type,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = type.name;
    var result = await channel.invokeMethod(
        ICWPublishEvent.setRulerBodyPartsType.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setRulerMeasureMode(ICDevice device, ICRulerMeasureMode mode,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = mode.name;
    var result = await channel.invokeMethod(
        ICWPublishEvent.setRulerMeasureMode.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setRulerUnit(
      ICDevice device, ICRulerUnit unit, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = unit.name;

    var result =
        await channel.invokeMethod(ICWPublishEvent.setRulerUnit.value, hashMap);

    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setScaleUIItems(
      ICDevice device, List<int> items, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.JsonValue] = json.encode(items);
    var result = await channel.invokeMethod(
        ICWPublishEvent.setScaleUIItems.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setScaleUnit(
      ICDevice device, ICWeightUnit unit, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = unit.name;
    log("ICBluetoothManger flutter 设置单位22222---${unit.name}");
    var result =
        await channel.invokeMethod(ICWPublishEvent.setScaleUnit.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setServerUrl(
      ICDevice device, String server, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.StringValue] = server;
    var result =
        await channel.invokeMethod(ICWPublishEvent.setServerUrl.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setSkipLightSetting(
      ICDevice device,
      List<ICSkipLightSettingData> lightEffects,
      ICSkipLightMode mode,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    List<Map<String, dynamic>> jsonData =
        lightEffects.map((dev) => dev.toJson()).toList();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = mode.name;
    hashMap[ICMapKey.JsonValue] = json.encode(jsonData);
    var result = await channel.invokeMethod(
        ICWPublishEvent.skipLightSetting.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setSkipSoundSetting(ICDevice device, ICSkipSoundSettingData config,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.JsonValue] = json.encode(config.toJson());
    var result = await channel.invokeMethod(
        ICWPublishEvent.skipSoundsSetting.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setUserInfo(ICDevice device, ICUserInfo userInfo) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.JsonValue] = json.encode(userInfo.toJson());
    hashMap[ICMapKey.Mac] = device.macAddr;

    var result =
        await channel.invokeMethod(ICWPublishEvent.skipSetUserInfo.value, hashMap);
    var name = result[ICMapKey.Method];

    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setUserList(List<ICUserInfo> list) async {
    var hashMap = HashMap();
    List<Map<String, dynamic>> jsonData =
        list.map((dev) => dev.toJson()).toList();
    hashMap[ICMapKey.JsonValue] = json.encode(jsonData);

    var result =
        await channel.invokeMethod(ICWPublishEvent.setUserList.value, hashMap);
    var name = result[ICMapKey.Method];

    log("ICBluetoothManger result---$name key:");
  }

  @override
  void setWeight(
      ICDevice device, int weight, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.IntValue] = weight;
    var result =
        await channel.invokeMethod(ICWPublishEvent.setWeight.value, hashMap);
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    var name = result[ICMapKey.Method];
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void startSkipMode(ICDevice device, ICSkipMode mode, int setting,
      ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.EnumName] = mode.name;
    hashMap[ICMapKey.IntValue] = setting;
    var result =
        await channel.invokeMethod(ICWPublishEvent.startSkip.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void stopScan() async {
    scanDeviceDelegate = null;
    channel.invokeMethod(ICWPublishEvent.stopScan.value, "");
  }

  @override
  void stopSkip(ICDevice device, ICSettingCallback? callback) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result =
        await channel.invokeMethod(ICWPublishEvent.stopSkip.value, hashMap);
    var name = result[ICMapKey.Method];
    if (callback != null) {
      var resultCode = result[ICMapKey.EnumName];
      callback.callBack(ICConverUtil.settingCodeNameOf(resultCode));
    }
    log("ICBluetoothManger result---$name key:");
  }

  @override
  void stopUpgradeDevice(ICDevice device) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    var result = await channel.invokeMethod(
        ICWPublishEvent.stopOTADevice.value, hashMap);
    var name = result[ICMapKey.Method];
    log("ICBluetoothManger result---$name method");
  }

  @override
  void stopUpgradeDevices(List<ICDevice> devices) async {
    var hashMap = HashMap();
    List<Map<String, dynamic>> jsonData =
        devices.map((dev) => dev.toJson()).toList();
    hashMap[ICMapKey.JsonValue] = json.encode(jsonData);

    var result = await channel.invokeMethod(
        ICWPublishEvent.stopOTADevices.value, hashMap);
    var name = result[ICMapKey.Method];
    log("ICBluetoothManger result---$name method");
  }

  @override
  void updateUserInfo(ICUserInfo userInfo) async {
    var hashMap = HashMap();
    hashMap[ICMapKey.JsonValue] = json.encode(userInfo.toJson());

    var result = await channel.invokeMethod(
        ICWPublishEvent.updateUserInfo.value, hashMap);
    var name = result[ICMapKey.Method];

    log("ICBluetoothManger result---$name key:");
  }

  @override
  void upgradeDevice(ICDevice device, String filePath, ICOTAMode mode) async {
    if (device.macAddr == null) return;
    var hashMap = HashMap();
    hashMap[ICMapKey.Mac] = device.macAddr;
    hashMap[ICMapKey.StringValue] = filePath;
    hashMap[ICMapKey.EnumName] = mode.name;
    var result =
        await channel.invokeMethod(ICWPublishEvent.otaDevice.value, hashMap);
    var name = result[ICMapKey.Method];
    log("ICBluetoothManger result---$name method");
  }

  @override
  void upgradeDevices(
      List<ICDevice> devices, String filePath, ICOTAMode mode) async {
    var hashMap = HashMap();
    List<Map<String, dynamic>> jsonData =
        devices.map((dev) => dev.toJson()).toList();

    hashMap[ICMapKey.JsonValue] = json.encode(jsonData);
    hashMap[ICMapKey.StringValue] = filePath;
    hashMap[ICMapKey.EnumName] = mode.name;
    var result =
        await channel.invokeMethod(ICWPublishEvent.otaDevices.value, hashMap);
    var name = result[ICMapKey.Method];
    log("ICBluetoothManger result---$name method");
  }


  @override
  void  reCalcBodyFatWithWeightData(ICWeightData weightData, ICUserInfo userInfo,ICFatAlgorithmsSettingCallback callBack) async {
      var hashMap = HashMap();
      hashMap[ICMapKey.JsonValue] = json.encode(weightData.toJson());
      hashMap[ICMapKey.JsonValue2] = json.encode(userInfo.toJson());
      var result = await channel.invokeMethod(ICWPublishEvent.calcBodyFat.value, hashMap);
      var data = result[ICMapKey.JsonValue];
      Map<String, dynamic> map = json.decode(data);
      callBack.callBack(ICWeightData.fromJson(map));
  }

  @override
  void  getLogPath(ICCommonCallback? callback) async {
    var hashMap = HashMap();
    var result = await channel.invokeMethod(ICWPublishEvent.getLogPath.value, hashMap);
    var data = result[ICMapKey.StringValue];
    if (callback != null&&data!=null) {
      callback.callBack(data);
    }

  }



  onReceiveMsg(MethodCall call) {
    String method = call.method;
    log("onReceiveMsg-------------$method");
    var map = call.arguments;
    map.forEach((key, value) {
      log("onReceiveMsg-------------$key  value $value");
    });
    var mac = map[ICMapKey.Mac];
    var jsonValue = map[ICMapKey.JsonValue];
    var enumName = map[ICMapKey.EnumName];
    var boolValue = map[ICMapKey.BoolValue];
    var intValue = map[ICMapKey.IntValue];

    log("onReceiveMsg---method:$method mac: $mac value:$jsonValue "
        " step: $enumName code:  $boolValue    ");

    if (ICWUploadEvent.initSDK.value == method) {
      onInitFinish(boolValue as bool);
    } else if (ICWUploadEvent.onBleState.value == method) {
      onBleState(enumName as String);
    } else if (ICWUploadEvent.onDeviceConnectionChanged.value == method) {
      onDeviceConnectionChanged(mac as String, enumName as String);
    } else if (ICWUploadEvent.onNodeConnectionChanged.value == method) {
      onNodeConnectionChanged(mac as String, 0, enumName as String);
    } else if (ICWUploadEvent.onReceiveWeightData.value == method) {
      onReceiveWeightData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveKitchenScaleData.value == method) {
      onReceiveKitchenScaleData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveKitchenScaleUnitChanged.value ==
        method) {
      onReceiveKitchenScaleUnitChanged(mac as String, enumName as String);
    } else if (ICWUploadEvent.onReceiveCoordData.value == method) {
      onReceiveCoordData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveRulerData.value == method) {
      onReceiveRulerData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveHrData.value == method) {
      onReceiveHrData(mac as String, intValue as int);
    } else if (ICWUploadEvent.onReceiveRulerHistoryData.value == method) {
      onReceiveRulerHistoryData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveWeightCenterData.value == method) {
      onReceiveWeightCenterData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveWeightUnitChanged.value == method) {
      onReceiveWeightUnitChanged(mac as String, enumName as String);
    } else if (ICWUploadEvent.onReceiveRulerUnitChanged.value == method) {
      onReceiveRulerUnitChanged(mac as String, enumName as String);
    } else if (ICWUploadEvent.onReceiveRulerMeasureModeChanged.value ==
        method) {
      onReceiveRulerMeasureModeChanged(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveMeasureStepData.value == method) {
      onReceiveMeasureStepData(
          mac as String, enumName as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveWeightHistoryData.value == method) {
      onReceiveWeightHistoryData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveSkipData.value == method) {
      onReceiveSkipData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveHistorySkipData.value == method) {
      onReceiveHistorySkipData(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveSkipBattery.value == method) {
      onReceiveSkipBattery(mac as String, jsonValue as int);
    } else if (ICWUploadEvent.onReceiveUpgradePercent.value == method) {
      onReceiveUpgradePercent(
          mac as String, enumName as String, intValue as int);
    } else if (ICWUploadEvent.onReceiveDeviceInfo.value == method) {
      onReceiveDeviceInfo(mac as String, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveBattery.value == method) {
      onReceiveBattery(mac as String, jsonValue as int);
    } else if (ICWUploadEvent.onReceiveDebugData.value == method) {
      onReceiveDebugData(mac as String, 0, jsonValue as String);
    } else if (ICWUploadEvent.onReceiveConfigWifiResult.value == method) {
      onReceiveConfigWifiResult(mac as String, enumName as String);
    } else if (ICWUploadEvent.onScanResult.value == method) {
      onScanResult(jsonValue as String);
    } else if (ICWUploadEvent.onSettingCallBack.value == method) {
      onSettingCallBack(enumName as String);
    }
  }

  void onInitFinish(bool finish) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onInitFinish(finish);
    }
  }

  void onBleState(String data) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onBleState(ICConverUtil.nameOf(data));
    }
  }

  void onDeviceConnectionChanged(String mac, String stateName) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onDeviceConnectionChanged(
          ICDevice(mac),ICConverUtil.connectStateNameOf(stateName));
    }
  }

  void onNodeConnectionChanged(String mac, int nodeId, String state) {}

  void onReceiveWeightData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveWeightData(ICDevice(mac), ICWeightData.fromJson(map));
    }
  }

  void onReceiveKitchenScaleData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!.onReceiveKitchenScaleData(
          ICDevice(mac), ICKitchenScaleData.fromJson(map));
    }
  }

  void onReceiveKitchenScaleUnitChanged(String mac, String data) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveKitchenScaleUnitChanged(
          ICDevice(mac), ICConverUtil.kitChenScaleUnitNameOf(data));
    }
  }

  void onReceiveCoordData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveCoordData(ICDevice(mac), ICCoordData.fromJson(map));
    }
  }

  void onReceiveRulerData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveRulerData(ICDevice(mac), ICRulerData.fromJson(map));
    }
  }

  void onReceiveHrData(String mac, int hr) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveHR(ICDevice(mac), hr);
    }
  }

  void onReceiveRulerHistoryData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveRulerHistoryData(ICDevice(mac), ICRulerData.fromJson(map));
    }
  }

  void onReceiveWeightCenterData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!.onReceiveWeightCenterData(
          ICDevice(mac), ICWeightCenterData.fromJson(map));
    }
  }

  void onReceiveWeightUnitChanged(String mac, String data) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveWeightUnitChanged(ICDevice(mac), ICConverUtil.weightUnitNameOf(data));
    }
  }

  void onReceiveRulerUnitChanged(String mac, String data) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!
          .onReceiveRulerUnitChanged(ICDevice(mac), ICConverUtil.rulerUnitNameOf(data));
    }
  }

  void onReceiveRulerMeasureModeChanged(String mac, String data) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveRulerMeasureModeChanged(
          ICDevice(mac), ICConverUtil.rulerMeasureModeNameOf(data));
    }
  }

  void onReceiveMeasureStepData(String mac, String step, String data) {
    Map<String, dynamic> map = json.decode(data);
    if (deviceManagerDelegate != null) {
      var measureStep =  ICConverUtil.measureStepNameOf(step);
      if (measureStep == ICMeasureStep.ICMeasureStepMeasureCenterData) {
        deviceManagerDelegate!.onReceiveMeasureStepData(ICDevice(mac),
            ICConverUtil.measureStepNameOf(step), ICWeightCenterData.fromJson(map));
      } else {
        deviceManagerDelegate!.onReceiveMeasureStepData(ICDevice(mac),
            ICConverUtil.measureStepNameOf(step), ICWeightData.fromJson(map));
      }
    }
  }

  void onReceiveWeightHistoryData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!.onReceiveWeightHistoryData(
          ICDevice(mac), ICWeightHistoryData.fromJson(map));
    }
  }

  void onReceiveSkipData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveSkipData(ICDevice(mac), ICSkipData.fromJson(map));
    }
  }

  void onReceiveHistorySkipData(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveSkipData(ICDevice(mac), ICSkipData.fromJson(map));
    }
  }

  void onReceiveSkipBattery(String mac, int i) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveBattery(ICDevice(mac), i, Object());
    }
  }

  void onReceiveUpgradePercent(String mac, String step, int i) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveUpgradePercent(
          ICDevice(mac),  ICConverUtil.upgradeStatusNameOf(step), i);
    }
  }

  void onReceiveDeviceInfo(String mac, String data) {
    if (deviceManagerDelegate != null) {
      Map<String, dynamic> map = json.decode(data);
      deviceManagerDelegate!
          .onReceiveDeviceInfo(ICDevice(mac), ICDeviceInfo.fromJson(map));
    }
  }

  void onReceiveBattery(String mac, int i) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveBattery(ICDevice(mac), i, Object());
    }
  }

  void onReceiveDebugData(String mac, int i, String o) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveDebugData(ICDevice(mac), i, Object());
    }
  }

  void onReceiveConfigWifiResult(String mac, String data) {
    if (deviceManagerDelegate != null) {
      deviceManagerDelegate!.onReceiveConfigWifiResult(
          ICDevice(mac), ICConverUtil.wifiStateNameOf(data));
    }
  }

  void onScanResult(String data) {
    if (scanDeviceDelegate != null) {
      Map<String, dynamic> map = json.decode(data);

      var icScanDeviceInfo = ICScanDeviceInfo.fromJson(map);
      scanDeviceDelegate!.onScanResult(icScanDeviceInfo);
    }
  }

  void onSettingCallBack(String data) {

  }





}
