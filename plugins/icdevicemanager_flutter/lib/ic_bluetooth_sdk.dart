import 'package:icdevicemanager_flutter/callback/ICAddDeviceCallBack.dart';
import 'package:icdevicemanager_flutter/callback/ICCommonCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICDeviceManagerCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICFatAlgorithmsSettingCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICRemoveDeviceCallBack.dart';
import 'package:icdevicemanager_flutter/callback/ICScanDeviceDelegate.dart';
import 'package:icdevicemanager_flutter/callback/ICSettingCallback.dart';
import 'package:icdevicemanager_flutter/ic_bluetooth_sdk_platform_interface.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipLightSettingData.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipSoundSettingData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightData.dart';
import 'package:icdevicemanager_flutter/model/device/ICDevice.dart';
import 'package:icdevicemanager_flutter/model/device/ICUserInfo.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:icdevicemanager_flutter/model/other/ICDeviceManagerConfig.dart';



class IcBluetoothSdk {
  static IcBluetoothSdk? _instance;

  IcBluetoothSdk._() {
    IcBluetoothSdkPlatform.instance.onMethodCall();
  }

  static IcBluetoothSdk get instance => _instance ??= IcBluetoothSdk._();

  /*
   * 设置数据回调代理
   */
  void setDeviceManagerDelegate(ICDeviceManagerDelegate? delegate) {
    IcBluetoothSdkPlatform.instance.setDeviceManagerDelegate(delegate);
  }

  /*
   * 设置扫描回调代理
   */
  void setDeviceScanDelegate(ICScanDeviceDelegate delegate) {
    IcBluetoothSdkPlatform.instance.setDeviceScanDelegate(delegate);
  }

  /*
   * SDK初始化
   * @param config  配置
   */
  void initSDK(ICDeviceManagerConfig config) {
    IcBluetoothSdkPlatform.instance.initSDK(config);
  }

  /*
   * 添加单个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void addDevice(ICDevice device, ICAddDeviceCallBack? callBack) async {
    IcBluetoothSdkPlatform.instance.addDevice(device, callBack);
  }

  /*
   * 添加设备列表
   *
   *
   * @param devices   设备
   * @param callBack  回调
   *
   *
   */
  void addDevices(List<ICDevice> devices, ICAddDeviceCallBack? callback) async {
    IcBluetoothSdkPlatform.instance.addDevices(devices, callback);
  }

  /*
   * 删除单个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void removeDevice(ICDevice device, ICRemoveDeviceCallBack? callBack) async {
    IcBluetoothSdkPlatform.instance.removeDevice(device, callBack);
  }

  /*
   * 删除多个设备
   *
   *
   * @param devices   设备
   * @param callBack  回调
   *
   *
   */
  void removeDevices(
      List<ICDevice> devices, ICRemoveDeviceCallBack? callBack) async {
    IcBluetoothSdkPlatform.instance.removeDevices(devices, callBack);
  }

  /*
   * 升级单个设备
   *
   *
   * @param device    device
   * @param callBack  回调
   *
   *
   */
  void upgradeDevice(ICDevice device, String filePath, ICOTAMode mode) {
    IcBluetoothSdkPlatform.instance.upgradeDevice(device, filePath, mode);
  }

  /*
   * 升级多个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void upgradeDevices(List<ICDevice> devices, String filePath, ICOTAMode mode) {
    IcBluetoothSdkPlatform.instance.upgradeDevices(devices, filePath, mode);
  }

  /*
   * 停止升级设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void stopUpgradeDevice(ICDevice device) {
    IcBluetoothSdkPlatform.instance.stopUpgradeDevice(device);
  }

  /*
   * 停止升级多个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void stopUpgradeDevices(List<ICDevice> devices) {
    IcBluetoothSdkPlatform.instance.stopUpgradeDevices(devices);
  }

  /*
     * 扫描设备
     *
     */
  void scanDevice(ICScanDeviceDelegate  delegate) {
    IcBluetoothSdkPlatform.instance.setDeviceScanDelegate(delegate);
    IcBluetoothSdkPlatform.instance.scanDevice();
  }

  /*
   * 停止扫描设备
   *
   */
  void stopScan() {
    IcBluetoothSdkPlatform.instance.setDeviceScanDelegate(null);
    IcBluetoothSdkPlatform.instance.stopScan();
  }

  /*
   * 同步当前用户信息
   *
   * @param userInfo  用户
   *
   */
  void updateUserInfo(ICUserInfo userInfo) {
    IcBluetoothSdkPlatform.instance.updateUserInfo(userInfo);
  }

  /*
   * 下发用户列表
   *
   * @param list    用户列表
   *
   */
  void setUserList(List<ICUserInfo> list) {
    IcBluetoothSdkPlatform.instance.setUserList(list);
  }

  /*
      设置称单位

      @param device          设备
      @param unit            单位
      @param callback        回调
   */
  void setScaleUnit(
      ICDevice device, ICWeightUnit unit, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setScaleUnit(device, unit, callback);
  }

  /*
      设置围尺单位

      @param device      设备
      @param unit        单位
      @param callback    回调
   */
  void setRulerUnit(
      ICDevice device, ICRulerUnit unit, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setRulerUnit(device, unit, callback);
  }

  /*
      设置围尺测量模式

      @param device      设备
      @param mode        测量模式
      @param callback    回调
   */
  void setRulerMeasureMode(ICDevice device, ICRulerMeasureMode mode,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setRulerMeasureMode(device, mode, callback);
  }

  /*
      设置当前围尺身体部位

      @param device      设备
      @param type        身体部位
      @param callback    回调
   */
  void setRulerBodyPartsType(ICDevice device, ICRulerBodyPartsType type,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .setRulerBodyPartsType(device, type, callback);
  }

  /*
      设置重量到厨房秤，单位:毫克

      @param device 设备
      @param weight 重量，单位:毫克，最大不能超过65535毫克
      @param callback 回调
   */
  void setWeight(
      ICDevice device, int weight, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setWeight(device, weight, callback);
  }

  /*
      设置厨房秤去皮重量

      @param device 设备
      @param callback 回调
   */
  void deleteTareWeight(ICDevice device, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.deleteTareWeight(device, callback);
  }

  /*
      厨房秤关机

      @param device 设备
      @param callback 回调
   */
  void powerOffKitchenScale(
      ICDevice device, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.powerOffKitchenScale(device, callback);
  }

  /*
      设置厨房秤计量单位

      @param device 设备
      @param unit 单位，注:如果秤不支持该单位，将不会生效
      @param callback 回调
   */
  void setKitchenScaleUnit(ICDevice device, ICKitchenScaleUnit unit,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setKitchenScaleUnit(device, unit, callback);
  }

  /*
      设置营养成分值到厨房秤

      @param device 设备
      @param type 营养类型
      @param value 营养值
      @param callback 回调
   */
  void setNutritionFacts(ICDevice device, ICKitchenScaleNutritionFactType type,
      int value, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .setNutritionFacts(device, type, value, callback);
  }

  /*
   * 开始跳绳
   * @param device 设备
   * @param mode   跳绳模式
   * @param param  模式参数
   * @param callback 回调
   */
  void startSkipMode(ICDevice device, ICSkipMode mode, int param,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .startSkipMode(device, mode, param, callback);
  }

  /*
   * 停止跳绳
   * @param device 设备
   * @param callback 回调
   */
  void stopSkip(ICDevice device, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.stopSkip(device, callback);
  }

  /*
      设置用户信息给设备，调用该接口后，updateUserInfo接口将不会再对该设备生效
      注意:目前仅跳绳设备支持

      @param device      设备
      @param userInfo    用户信息
   */
  void setUserInfo(ICDevice device, ICUserInfo userInfo) async {
    IcBluetoothSdkPlatform.instance.setUserInfo(device, userInfo);
  }

  /*
   * 设置跳绳设备灯效
   * @param device 设备
   * @param lightEffects 跳绳灯效颜色
   * @param mode 等效的模式
   * @param callback 回调
   */
  void setSkipLightSetting(
      ICDevice device,
      List<ICSkipLightSettingData> lightEffects,
      ICSkipLightMode mode,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .setSkipLightSetting(device, lightEffects, mode, callback);
  }

  /*
   * 设置跳绳设备音效
   * @param device 设备
   * @param config 音效设置
   * @param callback 回调
   */
  void setSkipSoundSetting(ICDevice device, ICSkipSoundSettingData config,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .setSkipSoundSetting(device, config, callback);
  }

  /*
      双模设备配网

      @param device      设备
      @param ssid        WIFI SSID
      @param password    WIFI Password
   */
  void configWifi(ICDevice device, String? ssid, String? password,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .configWifi(device, ssid, password, callback);
  }

  /*
      双模设备设置域名

      @param device      设备
      @param server      App服务器域名,如:https://www.google.com
   */
  void setServerUrl(
      ICDevice device, String server, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setServerUrl(device, server, callback);
  }

  /*
      设置厂商特定参数

      @param device      设备
      @param type        根据客户意思不一样
   */
  void setOtherParams(ICDevice device, int type, Object param,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance
        .setOtherParams(device, type, param, callback);
  }

  /*
   * 设置设备显示的项
   * @param device 设备
   * @param items UI项
   * @param callback 回调
   */
  void setScaleUIItems(
      ICDevice device, List<int> items, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setScaleUIItems(device, items, callback);
  }

  /*
     * 下发准备
     * @param device    基站设备
     * @param callback  回调
     */
  void lockStSkip(ICDevice device, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.lockStSkip(device, callback);
  }

  /*
     * 查询在线状态
     * @param device    基站设备
     * @param callback  回调
     */
  void queryStAllNode(ICDevice device, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.queryStAllNode(device, callback);
  }

  /*
     * 改变广播名
     * @param device    基站设备
     * @param name      广播名
     * @param callback  回调
     */
  void changeStName(
      ICDevice device, String name, ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.changeStName(device, name, callback);
  }

  /*
     * 改变节点ID
     * @param device    基站设备
     * @param dstId     节点设备更改后ID, 0~0xFF
     * @param st_no     基站号码，0~0xFFFFFF
     * @param callback  回调
     */
  void changeStNo(ICDevice device, int dstId, int st_no,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.changeStNo(device, dstId, st_no, callback);
  }

  /*
     * 设置调试命令
     * @param device    设备
     * @param cmd       命令
     * @param callback  回调
     */
  void setDebugCommand(ICDevice device, Map<String, Object> cmd,
      ICSettingCallback? callback) async {
    IcBluetoothSdkPlatform.instance.setDebugCommand(device, cmd, callback);
  }



  void reCalcBodyFatWithWeightData(ICWeightData weightData, ICUserInfo userInfo,ICFatAlgorithmsSettingCallback callback)  {
    IcBluetoothSdkPlatform.instance.reCalcBodyFatWithWeightData(weightData, userInfo, callback);
  }


  void getLogPath(ICCommonCallback callback)  {
    IcBluetoothSdkPlatform.instance.getLogPath(callback);
  }


}
