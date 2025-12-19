

import 'package:icdevicemanager_flutter/model/data/ICCoordData.dart';
import 'package:icdevicemanager_flutter/model/data/ICKitchenScaleData.dart';
import 'package:icdevicemanager_flutter/model/data/ICRulerData.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightCenterData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightHistoryData.dart';
import 'package:icdevicemanager_flutter/model/device/ICDevice.dart';
import 'package:icdevicemanager_flutter/model/device/ICDeviceInfo.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';


abstract class ICDeviceManagerDelegate{




  /*
   * SDK初始化完成回调
   * @param bSuccess 初始化是否成功
   */
  void onInitFinish(bool bSuccess);


  /*
      蓝牙改变状态回调

      @param state 蓝牙状态
   */
  void onBleState(ICBleState state);

  /*
      设备连接状态回调

      @param device 设备
      @param state 连接状态
   */
  void onDeviceConnectionChanged(ICDevice device,ICDeviceConnectState state);

  /*
      节点设备连接状态回调

      @param device 设备
      @param nodeId 设备
      @param state 连接状态
   */
  void onNodeConnectionChanged(ICDevice device, int nodeId,ICDeviceConnectState state);

  /*
      体重秤数据回调

      @param device 设备
      @param data 测量数据
   */
  void onReceiveWeightData(ICDevice device, ICWeightData data);

  /*
      厨房秤数据回调

      @param device 设备
      @param data 测量数据
   */
  void onReceiveKitchenScaleData(ICDevice device, ICKitchenScaleData data);

  /*
      厨房秤单位改变

      @param device 设备
      @param unit 改变后的单位
   */
  void onReceiveKitchenScaleUnitChanged(ICDevice device,ICKitchenScaleUnit unit);

  /*
      平衡秤坐标数据回调

      @param device 设备
      @param data 测量坐标数据
   */
  void onReceiveCoordData(ICDevice device, ICCoordData data);

  /*
      围尺数据回调

      @param device 设备
      @param data 测量数据
   */
  void onReceiveRulerData(ICDevice device, ICRulerData data);

  /*
      围尺历史数据回调

      @param device 设备
      @param data 测量数据
   */
  void onReceiveRulerHistoryData(ICDevice device, ICRulerData data);

  /*
      重心秤重心数据回调

      @param device 设备
      @param data 重心数数据
   */
  void onReceiveWeightCenterData(ICDevice device, ICWeightCenterData data);

  /*
      设备单位改变回调

      @param device  设备
      @param unit    设备当前单位
   */
  void onReceiveWeightUnitChanged(ICDevice device,ICWeightUnit unit);

  /*
      围尺单位改变回调

      @param device 设备
      @param unit 设备当前单位
   */
  void onReceiveRulerUnitChanged(ICDevice device,ICRulerUnit unit);

  /*
      围尺测量模式改变回调

      @param device 设备
      @param mode 设备当前测量模式
   */
  void onReceiveRulerMeasureModeChanged(ICDevice device,ICRulerMeasureMode mode);

  /*
      分步骤体重、平衡、阻抗、心率数据回调

      @param device  设备
      @param step    当前处于的步骤
      @param data    数据
   */
  void onReceiveMeasureStepData(ICDevice device,ICMeasureStep step, Object data);

  /*
      体重历史数据回调

      @param device 设备
      @param data 体重历史数据
   */
  void onReceiveWeightHistoryData(ICDevice device, ICWeightHistoryData data);

  /*
      跳绳实时数据回调

      @param device 设备
      @param data 体重历史数据
   */
  void onReceiveSkipData(ICDevice device, ICSkipData data);
  /*
      跳绳历史数据回调

      @param device 设备
      @param data 体重历史数据
   */
  void onReceiveHistorySkipData(ICDevice device, ICSkipData data);


  /*
      电量

      @param device 设备
      @param battery 电量，范围:0~100
      @param ext 扩展字段，如是基站跳绳，则该字段的值表示节点ID，类型：Integer
   */
  void onReceiveBattery(ICDevice device, int battery, Object ext);

  /*
      设备升级状态回调
      @param device 设备
      @param status 升级状态
      @param percent 升级进度,范围:0~100
   */
  void onReceiveUpgradePercent(ICDevice device,ICUpgradeStatus status, int percent);

  /*
      设备信息回调

      @param device 设备
      @param deviceInfo 设备信息
   */
  void onReceiveDeviceInfo(ICDevice device, ICDeviceInfo deviceInfo);

  /*
      调试数据回调

      @param device 设备
      @param type 类型
      @param obj 数据
   */
  void onReceiveDebugData(ICDevice device, int type, Object obj);


  /*
   * 配网结果回调
   * @param device 设备
   * @param state 配网状态
   */
  void onReceiveConfigWifiResult(ICDevice device,ICConfigWifiState state);



  /*
      心率

      @param device 设备
      @param hr 心率，范围:0~255
   */
  void onReceiveHR(ICDevice device, int hr);

}