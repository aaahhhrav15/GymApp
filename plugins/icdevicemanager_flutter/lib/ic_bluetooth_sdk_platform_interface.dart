
import 'package:icdevicemanager_flutter/callback/ICAddDeviceCallBack.dart';
import 'package:icdevicemanager_flutter/callback/ICCommonCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICDeviceManagerCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICFatAlgorithmsSettingCallback.dart';
import 'package:icdevicemanager_flutter/callback/ICRemoveDeviceCallBack.dart';
import 'package:icdevicemanager_flutter/callback/ICScanDeviceDelegate.dart';
import 'package:icdevicemanager_flutter/callback/ICSettingCallback.dart';
import 'package:icdevicemanager_flutter/ic_bluetooth_sdk_method_channel.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipLightSettingData.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipSoundSettingData.dart';
import 'package:icdevicemanager_flutter/model/data/ICWeightData.dart';
import 'package:icdevicemanager_flutter/model/device/ICDevice.dart';
import 'package:icdevicemanager_flutter/model/device/ICUserInfo.dart';
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';



import 'model/other/ICDeviceManagerConfig.dart';

abstract class IcBluetoothSdkPlatform extends PlatformInterface {
  /// Constructs a IcBluetoothSdkPlatform.
  IcBluetoothSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static IcBluetoothSdkPlatform _instance = MethodChannelIcBluetoothSdk();

  /// The default instance of [IcBluetoothSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelIcBluetoothSdk].
  static IcBluetoothSdkPlatform get instance => _instance;

  static set instance(IcBluetoothSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /*
      设置称单位

      @param device          设备
      @param unit            单位
      @param callback        回调
   */
  void setScaleUnit(
      ICDevice device, ICWeightUnit unit, ICSettingCallback? callback);

  /*
      设置围尺单位

      @param device      设备
      @param unit        单位
      @param callback    回调
   */
  void setRulerUnit(
      ICDevice device, ICRulerUnit unit, ICSettingCallback? callback);

  /*
      设置围尺测量模式

      @param device      设备
      @param mode        测量模式
      @param callback    回调
   */
  void setRulerMeasureMode(
      ICDevice device, ICRulerMeasureMode mode, ICSettingCallback? callback);

  /*
      设置当前围尺身体部位

      @param device      设备
      @param type        身体部位
      @param callback    回调
   */
  void setRulerBodyPartsType(
      ICDevice device, ICRulerBodyPartsType type, ICSettingCallback? callback);

  /*
      设置重量到厨房秤，单位:毫克

      @param device 设备
      @param weight 重量，单位:毫克，最大不能超过65535毫克
      @param callback 回调
   */
  void setWeight(ICDevice device, int weight, ICSettingCallback? callback);

  /*
      设置厨房秤去皮重量

      @param device 设备
      @param callback 回调
   */
  void deleteTareWeight(ICDevice device, ICSettingCallback? callback);

  /*
      厨房秤关机

      @param device 设备
      @param callback 回调
   */
  void powerOffKitchenScale(ICDevice device, ICSettingCallback? callback);

  /*
      设置厨房秤计量单位

      @param device 设备
      @param unit 单位，注:如果秤不支持该单位，将不会生效
      @param callback 回调
   */
  void setKitchenScaleUnit(
      ICDevice device, ICKitchenScaleUnit unit, ICSettingCallback? callback);

  /*
      设置营养成分值到厨房秤

      @param device 设备
      @param type 营养类型
      @param value 营养值
      @param callback 回调
   */
  void setNutritionFacts(ICDevice device, ICKitchenScaleNutritionFactType type,
      int value, ICSettingCallback? callback);

  /*
   * 开始跳绳
   * @param device 设备
   * @param mode   跳绳模式
   * @param param  模式参数
   * @param callback 回调
   */
  void startSkipMode(
      ICDevice device, ICSkipMode mode, int param, ICSettingCallback? callback);

  /*
   * 停止跳绳
   * @param device 设备
   * @param callback 回调
   */
  void stopSkip(ICDevice device, ICSettingCallback? callback);

  /*
      设置用户信息给设备，调用该接口后，updateUserInfo接口将不会再对该设备生效
      注意:目前仅跳绳设备支持

      @param device      设备
      @param userInfo    用户信息
   */
  void setUserInfo(ICDevice device, ICUserInfo userInfo);

  /*
      双模设备配网

      @param device      设备
      @param ssid        WIFI SSID
      @param password    WIFI Password
   */
  void configWifi(ICDevice device, String? ssid, String? password,
      ICSettingCallback? callback);

  /*
      双模设备设置域名

      @param device      设备
      @param server      App服务器域名,如:https://www.google.com
   */
  void setServerUrl(
      ICDevice device, String server, ICSettingCallback? callback);

  /*
      设置厂商特定参数

      @param device      设备
      @param type        根据客户意思不一样
   */
  void setOtherParams(
      ICDevice device, int type, Object param, ICSettingCallback? callback);

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
      ICSettingCallback? callback);

  /*
   * 设置设备显示的项
   * @param device 设备
   * @param items UI项
   * @param callback 回调
   */
  void setScaleUIItems(
      ICDevice device, List<int> items, ICSettingCallback? callback);

  /*
   * 设置跳绳设备音效
   * @param device 设备
   * @param config 音效设置
   * @param callback 回调
   */
  void setSkipSoundSetting(ICDevice device, ICSkipSoundSettingData config,
      ICSettingCallback? callback);

  /*
     * 下发准备
     * @param device    基站设备
     * @param callback  回调
     */
  void lockStSkip(ICDevice device, ICSettingCallback? callback);

  /*
     * 查询在线状态
     * @param device    基站设备
     * @param callback  回调
     */
  void queryStAllNode(ICDevice device, ICSettingCallback? callback);

  /*
     * 改变广播名
     * @param device    基站设备
     * @param name      广播名
     * @param callback  回调
     */
  void changeStName(ICDevice device, String name, ICSettingCallback? callback);

  /*
     * 改变节点ID
     * @param device    基站设备
     * @param dstId     节点设备更改后ID, 0~0xFF
     * @param st_no     基站号码，0~0xFFFFFF
     * @param callback  回调
     */
  void changeStNo(
      ICDevice device, int dstId, int st_no, ICSettingCallback? callback);

  /*
     * 设置调试命令
     * @param device    设备
     * @param cmd       命令
     * @param callback  回调
     */
  void setDebugCommand(
      ICDevice device, Map<String, Object> cmd, ICSettingCallback? callback);

  /*
     * SDK初始化
     * @param config  配置
     */
  void initSDK(ICDeviceManagerConfig config);

  /*
     * 扫描设备
     *
     */
  void scanDevice();

  /*
   * 停止扫描设备
   *
   */
  void stopScan();

  /*
   * 添加单个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void addDevice(ICDevice device, ICAddDeviceCallBack? callBack);

  /*
   * 添加设备列表
   *
   *
   * @param devices   设备
   * @param callBack  回调
   *
   *
   */
  void addDevices(List<ICDevice> devices, ICAddDeviceCallBack? callback);

  /*
   * 删除单个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void removeDevice(ICDevice device, ICRemoveDeviceCallBack? callBack);

  /*
   * 删除多个设备
   *
   *
   * @param devices   设备
   * @param callBack  回调
   *
   *
   */
  void removeDevices(List<ICDevice> devices, ICRemoveDeviceCallBack? callBack);

  /*
   * 升级单个设备
   *
   *
   * @param device    device
   * @param callBack  回调
   *
   *
   */
  void upgradeDevice(ICDevice device, String filePath, ICOTAMode mode);

  /*
   * 升级多个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void upgradeDevices(List<ICDevice> devices, String filePath, ICOTAMode mode);

  /*
   * 停止升级设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void stopUpgradeDevice(ICDevice device);

  /*
   * 停止升级多个设备
   *
   *
   * @param device    设备
   * @param callBack  回调
   *
   *
   */
  void stopUpgradeDevices(List<ICDevice> devices);

  /*
   * 同步当前用户信息
   *
   * @param userInfo  用户
   *
   */
  void updateUserInfo(ICUserInfo userInfo);

  /*
   * 下发用户列表
   *
   * @param list    用户列表
   *
   */
  void setUserList(List<ICUserInfo> list);

  void onMethodCall();

  /*
   * 设置数据回调代理
   */
  void setDeviceManagerDelegate(ICDeviceManagerDelegate? delegate);

  /*
   * 设置扫描回调代理
   */
  void setDeviceScanDelegate(ICScanDeviceDelegate? delegate);

  /*
   * 获取日记地址
   */
  void  getLogPath(ICCommonCallback? callback);

  /*
  * @param weightData    体重信息
   *@param userInfo      用户信息
   *重算体脂率
   */
  void reCalcBodyFatWithWeightData(ICWeightData weightData, ICUserInfo userInfo,ICFatAlgorithmsSettingCallback callBack) ;
}
