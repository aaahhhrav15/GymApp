package cn.icomon.icdevicemanager.flutter;


import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;

import java.util.HashMap;
import java.util.List;

import cn.icomon.icdevicemanager.ICDeviceManager;
import cn.icomon.icdevicemanager.ICDeviceManagerDelegate;
import cn.icomon.icdevicemanager.ICDeviceManagerSettingManager;
import cn.icomon.icdevicemanager.callback.ICScanDeviceDelegate;
import cn.icomon.icdevicemanager.common.ICLoggerHandler;
import cn.icomon.icdevicemanager.model.data.ICCoordData;
import cn.icomon.icdevicemanager.model.data.ICKitchenScaleData;
import cn.icomon.icdevicemanager.model.data.ICRulerData;
import cn.icomon.icdevicemanager.model.data.ICSkipData;
import cn.icomon.icdevicemanager.model.data.ICSkipLightSettingData;
import cn.icomon.icdevicemanager.model.data.ICSkipSoundSettingData;
import cn.icomon.icdevicemanager.model.data.ICWeightCenterData;
import cn.icomon.icdevicemanager.model.data.ICWeightData;
import cn.icomon.icdevicemanager.model.data.ICWeightHistoryData;
import cn.icomon.icdevicemanager.model.device.ICDevice;
import cn.icomon.icdevicemanager.model.device.ICDeviceInfo;
import cn.icomon.icdevicemanager.model.device.ICScanDeviceInfo;
import cn.icomon.icdevicemanager.model.device.ICUserInfo;
import cn.icomon.icdevicemanager.model.other.ICConstant;
import cn.icomon.icdevicemanager.model.other.ICDeviceManagerConfig;
import io.flutter.plugin.common.MethodChannel;


public class ICSDKManager implements ICDeviceManagerDelegate,
        ICDeviceManagerSettingManager.ICSettingCallback,
        ICConstant.ICAddDeviceCallBack,
        ICConstant.ICRemoveDeviceCallBack,
        ICScanDeviceDelegate {

    private final String TAG = "ICSDKManager";

    private volatile static ICSDKManager sdkManager;


    public static MethodChannel channel;



    private  Handler handler = new Handler();
    /**
     * 7-14 1.2.0_build_687_71e503b_20220714164005
     */
    private ICDeviceManager icDeviceManager;

    public static ICSDKManager getInstance() {
        if (sdkManager == null) {
            synchronized (ICSDKManager.class) {
                if (sdkManager == null) {
                    sdkManager = new ICSDKManager();
                }
            }
        }
        return sdkManager;

    }

    public MethodChannel getChannel() {
        if (channel == null) {
          //  channel = ICFlutterMessageChannel.getInstance().getChannel();
        }
        return channel;
    }

    public void setChannel(MethodChannel channel) {
        ICSDKManager.channel = channel;
    }


    public ICSDKManager() {
        icDeviceManager = ICDeviceManager.shared();
        icDeviceManager.setDelegate(this);
    }


    public ICDeviceManager getDeviceMgr() {
        if (icDeviceManager == null) {
            icDeviceManager = ICDeviceManager.shared();
            icDeviceManager.setDelegate(this);
        }
        return icDeviceManager;
    }


    public void sendMsgToFlutter(String name, Object obj) {
        handler.post(() -> {
            MethodChannel channel = getChannel();
            if (channel != null) {
                Log.e(TAG, "安卓端发送信息 " + name);
                channel.invokeMethod(name, obj);
            }
        });

    }

    public void addDevice(String macAddr, ICConstant.ICAddDeviceCallBack callBack) {
        if (TextUtils.isEmpty(macAddr)) return;
        getDeviceMgr().addDevice(getICDeviceByMac(macAddr), callBack);
    }

    public void addDevices(List<ICDevice> devices, ICConstant.ICAddDeviceCallBack callBack) {
        getDeviceMgr().addDevices(devices, callBack);
    }


    public void removeDevice(String macAddr,ICConstant.ICRemoveDeviceCallBack callBack) {
        if (TextUtils.isEmpty(macAddr)) return;
        getDeviceMgr().removeDevice(getICDeviceByMac(macAddr), callBack);

    }


    public void removeDevices(List<ICDevice> devices,ICConstant.ICRemoveDeviceCallBack callBack) {
        getDeviceMgr().removeDevices(devices, callBack);

    }

    public void upgradeDevice(String macAddr, String path, ICConstant.ICOTAMode icotaMode) {
        if (TextUtils.isEmpty(macAddr)) return;
        getDeviceMgr().upgradeDevice(getICDeviceByMac(macAddr), path, icotaMode);

    }

    public void upgradeDevices(List<ICDevice> devices, String path, ICConstant.ICOTAMode icotaMode) {
        getDeviceMgr().upgradeDevices(devices, path, icotaMode);

    }

    public void stopUpgradeDevice(String macAddr) {
        if (TextUtils.isEmpty(macAddr)) return;
        getDeviceMgr().stopUpgradeDevice(getICDeviceByMac(macAddr));

    }

    public void stopUpgradeDevices(List<ICDevice> devices) {
        getDeviceMgr().stopUpgradeDevices(devices);

    }

    public void scanDevice() {
        getDeviceMgr().scanDevice(this);


    }

    public void stopScan() {
        getDeviceMgr().stopScan();


    }

    public void initSdk(ICDeviceManagerConfig config) {
        getDeviceMgr().initMgrWithConfig(config);
    }


    public void configWifi(String macAddr, Object ssid, Object password,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr) || ssid == null || password == null) return;
        ICLoggerHandler.logInfo(TAG, "configWifi " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().configWifi(getICDeviceByMac(macAddr), ssid.toString(), password.toString(),callback);

    }

    public void setScaleUnit(String macAddr, ICConstant.ICWeightUnit unit,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setScaleUnit " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().setScaleUnit(getICDeviceByMac(macAddr), unit, callback);


    }
    /*尺子设置-----------------------start*/


    /**
     * 设置尺子单位
     *
     * @param macAddr
     * @param unit
     */
    public void setRulerUnit(String macAddr, ICConstant.ICRulerUnit unit,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setRulerUnit " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().setRulerUnit(getICDeviceByMac(macAddr), unit, callback);

    }


    public void setRulerBodyPartsType(String macAddr, ICConstant.ICRulerBodyPartsType unit,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setRulerBodyPartsType " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().setRulerBodyPartsType(getICDeviceByMac(macAddr), unit, callback);

    }

    /**
     * 设置测模式
     *
     * @param macAddr
     * @param mode
     */
    public void setRulerMeasureMode(String macAddr, ICConstant.ICRulerMeasureMode mode,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setRulerMeasureMode " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().setRulerMeasureMode(getICDeviceByMac(macAddr), mode, callback);

    }



    /*尺子设置-----------------------end*/















    /*厨房秤设置-----------------------start*/


    /**
     * 设置厨房秤单位
     *
     * @param macAddr
     * @param unit
     */
    public void setKitchenScaleUnit(String macAddr, ICConstant.ICKitchenScaleUnit unit,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setKitchenScaleUnit " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().setKitchenScaleUnit(getICDeviceByMac(macAddr), unit, callback);


    }

    /**
     * 厨房秤去皮
     */
    public void deleteTareWeight(String macAddr,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "deleteTareWeight " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().deleteTareWeight(getICDeviceByMac(macAddr), callback);


    }


    /**
     * 关机
     */
    public void powerOffKitchenScale(String macAddr,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "powerOffKitchenScale " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().powerOffKitchenScale(getICDeviceByMac(macAddr), callback);


    }


    public void setNutritionFacts(String macAddr, ICConstant.ICKitchenScaleNutritionFactType type, int value,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setNutritionFacts " );
        getDeviceMgr().getSettingManager().setNutritionFacts(getICDeviceByMac(macAddr), type, value, callback);


    }



    /*厨房秤设置-----------------------end*/


    /*彩屏称设置-----------------------start*/

    public void setServerUrl(String macAddr, Object service,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr) || service == null) return;
        ICLoggerHandler.logInfo(TAG, "setServerUrl " );
        getDeviceMgr().getSettingManager().setServerUrl(getICDeviceByMac(macAddr), service.toString(), callback);

    }


    public void setOtherParams(String strMac ,int type, Object object,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac)) return;
        ICLoggerHandler.logInfo(TAG, "setOtherParams " );
        getDeviceMgr().getSettingManager().setOtherParams(getICDeviceByMac(strMac),type,object,callback);

    }


    public void queryStAllNode(String strMac,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac)) return;
        ICLoggerHandler.logInfo(TAG, "queryStAllNode " );
        getDeviceMgr().getSettingManager().queryStAllNode(getICDeviceByMac(strMac),callback);

    }


    public void changeStName(String strMac, Object name,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac) || name == null) return;
        ICLoggerHandler.logInfo(TAG, "changeStName " );
        getDeviceMgr().getSettingManager().changeStName(getICDeviceByMac(strMac), name.toString(), callback);

    }

    public void changeStNo(String strMac, Object dstId, Object st_no,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac) || dstId == null || st_no == null) return;
        int id = 0, no = 0;
        if (dstId instanceof Integer) id = (int) dstId;
        if (st_no instanceof Integer) no = (int) st_no;
        ICLoggerHandler.logInfo(TAG, "changeStNo " );
        getDeviceMgr().getSettingManager().changeStNo(getICDeviceByMac(strMac), id, no, callback);

    }
    public ICWeightData CalcBodyFat(ICWeightData weightData,ICUserInfo userInfo) {
        ICLoggerHandler.logInfo(TAG, "CalcBodyFat " );
        return getDeviceMgr().getBodyFatAlgorithmsManager().reCalcBodyFatWithWeightData(weightData,userInfo);

    }


    public String getLogPath() {
        ICLoggerHandler.logInfo(TAG, "getLogPath " );
        return getDeviceMgr().getLogPath();

    }

    /*彩屏称设置-----------------------end*/

    public void syncUserInfo(ICUserInfo userInfo) {
        if (userInfo == null) return;
        getDeviceMgr().updateUserInfo(userInfo);
        ICLoggerHandler.logInfo(TAG, "syncUserInfo " );
    }

    public void syncUserList(List<ICUserInfo> list) {
        getDeviceMgr().setUserList(list);
        ICLoggerHandler.logInfo(TAG, "syncUserList " );
    }


    public void setWeight(String macAddr, int weight,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(macAddr)) return;
        ICLoggerHandler.logInfo(TAG, "setWeight " +  " mac: "+macAddr);
        getDeviceMgr().getSettingManager().setWeight(getICDeviceByMac(macAddr), weight,callback);


    }
    /*跳绳设置-----------------------start*/

    public void startSkip(String strMac, ICConstant.ICSkipMode skipMode, int nSetting,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac)) return;
        ICLoggerHandler.logInfo(TAG, "startSkip " +  " mac: "+strMac);
        getDeviceMgr().getSettingManager().startSkipMode(getICDeviceByMac(strMac), skipMode, nSetting,callback);

    }

    public void stopSkip(String strMac,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac)) return;
        ICLoggerHandler.logInfo(TAG, "stopSkip " +  " mac: "+strMac);
        getDeviceMgr().getSettingManager().stopSkip(getICDeviceByMac(strMac),callback);

    }

    /**
     * 设置灯效跳绳设备灯效
     */
    public void setSkipLightSetting(String strMac, List<ICSkipLightSettingData> data,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac) || data == null) return;
        ICLoggerHandler.logInfo(TAG, "setSkipLightSetting " +  " mac: "+strMac);
        getDeviceMgr().getSettingManager().setSkipLightSetting(getICDeviceByMac(strMac), data, ICConstant.ICSkipLightMode.ICSkipLightModeRPM,callback);

    }

    /**
     * 设置语音跳绳语音参数
     */
    public void setSkipVoiceSetting(String strMac, ICSkipSoundSettingData data,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac) || data == null) return;
        ICLoggerHandler.logInfo(TAG, "setSkipVoiceSetting " +  " mac: "+strMac);
        getDeviceMgr().getSettingManager().setSkipSoundSetting(getICDeviceByMac(strMac), data, callback);

    }


    public void lockStSkip(String strMac,ICDeviceManagerSettingManager.ICSettingCallback callback) {
        if (TextUtils.isEmpty(strMac)) return;
        ICLoggerHandler.logInfo(TAG, "lockStSkip " +  " mac: "+strMac);
        getDeviceMgr().getSettingManager().lockStSkip(getICDeviceByMac(strMac),callback);

    }


    /*跳绳设置-----------------------end*/


    public ICDevice getICDeviceByMac(String strMac) {
        ICDevice icDevice = new ICDevice();
        icDevice.setMacAddr(strMac);
        return icDevice;
    }


    @Override
    public void onInitFinish(boolean b) {
        ICLoggerHandler.logInfo(TAG, "onInitFinish " + b);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.BoolValue, b);
        sendMsgToFlutter(ICWUploadEvent.TypeInitSDK, map);
    }

    @Override
    public void onBleState(ICConstant.ICBleState icBleState) {
        ICLoggerHandler.logInfo(TAG, "onBleState " + icBleState.toString());
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.EnumName, icBleState.name());
        sendMsgToFlutter(ICWUploadEvent.TypeBluetoothChange, map);
    }

    @Override
    public void onDeviceConnectionChanged(ICDevice icDevice, ICConstant.ICDeviceConnectState state) {
        ICLoggerHandler.logInfo(TAG, "onDeviceConnectionChanged " + state.toString());
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, state.name());
        sendMsgToFlutter(ICWUploadEvent.TypeConnectChange, map);
    }


    @Override
    public void onNodeConnectionChanged(ICDevice device, int nodeId, ICConstant.ICDeviceConnectState state) {
        Log.e(TAG, "onReceiveWeightData " + device.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, device.getMacAddr());
        map.put(ICMapKey.EnumName,state.name());
        map.put(ICMapKey.IntValue,nodeId);
        sendMsgToFlutter(ICWUploadEvent.onNodeConnectionChanged, map);
    }

    @Override
    public void onReceiveWeightData(ICDevice icDevice, ICWeightData data) {
        Log.e(TAG, "onReceiveWeightData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.TypeScaleData, map);


    }

    @Override
    public void onReceiveKitchenScaleData(ICDevice icDevice, ICKitchenScaleData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveKitchenScaleData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.TypeKitchenData, map);
    }

    @Override
    public void onReceiveKitchenScaleUnitChanged(ICDevice icDevice, ICConstant.ICKitchenScaleUnit unit) {
        ICLoggerHandler.logInfo(TAG, "onReceiveKitchenScaleUnitChanged " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, unit.name());
        sendMsgToFlutter(ICWUploadEvent.KitchenScaleUnitChanged, map);
    }

    @Override
    public void onReceiveCoordData(ICDevice icDevice, ICCoordData icCoordData) {
        ICLoggerHandler.logInfo(TAG, "onReceiveCoordData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(icCoordData));
        sendMsgToFlutter(ICWUploadEvent.TypeCoordData, map);
    }

    @Override
    public void onReceiveRulerData(ICDevice icDevice, ICRulerData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveRulerData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.TypeRulerData, map);
    }

    @Override
    public void onReceiveRulerHistoryData(ICDevice icDevice, ICRulerData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveRulerHistoryData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.RulerHistoryData, map);
    }

    @Override
    public void onReceiveWeightCenterData(ICDevice icDevice, ICWeightCenterData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveWeightCenterData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.TypeScaleCenterData, map);
    }

    @Override
    public void onReceiveWeightUnitChanged(ICDevice icDevice, ICConstant.ICWeightUnit unit) {
        ICLoggerHandler.logInfo(TAG, "onReceiveWeightUnitChanged " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, unit.name());
        sendMsgToFlutter(ICWUploadEvent.TypeScaleUnitChange, map);
    }

    @Override
    public void onReceiveRulerUnitChanged(ICDevice icDevice, ICConstant.ICRulerUnit unit) {
        ICLoggerHandler.logInfo(TAG, "onReceiveRulerUnitChanged " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, unit.name());
        sendMsgToFlutter(ICWUploadEvent.TypeRulerUnitChange, map);
    }

    @Override
    public void onReceiveRulerMeasureModeChanged(ICDevice icDevice, ICConstant.ICRulerMeasureMode mode) {
        ICLoggerHandler.logInfo(TAG, "onReceiveRulerMeasureModeChanged " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, mode.name());
        sendMsgToFlutter(ICWUploadEvent.TypeRulerModeChange, map);
    }

    @Override
    public void onReceiveMeasureStepData(ICDevice icDevice, ICConstant.ICMeasureStep step, Object o) {
        ICLoggerHandler.logInfo(TAG, "onReceiveMeasureStepData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
      //  ICWeightData data = (ICWeightData) o;
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, step.name());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(o));
        sendMsgToFlutter(ICWUploadEvent.TypeScaleStepData, map);
    }

    @Override
    public void onReceiveWeightHistoryData(ICDevice icDevice, ICWeightHistoryData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveWeightHistoryData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.TypeScaleHistoryData, map);
    }

    @Override
    public void onReceiveSkipData(ICDevice icDevice, ICSkipData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveSkipData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(ICDataConvert.getSkipData(data)));
        sendMsgToFlutter(ICWUploadEvent.TypeSkipData, map);
    }

    @Override
    public void onReceiveHistorySkipData(ICDevice icDevice, ICSkipData data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveHistorySkipData " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(ICDataConvert.getSkipData(data)));
        sendMsgToFlutter(ICWUploadEvent.TypeSkipHistoryData, map);
    }

    @Override
    public void onReceiveBattery(ICDevice icDevice, int percent, Object o) {
        ICLoggerHandler.logInfo(TAG, "onReceiveBattery " +  " mac: "+icDevice.macAddr);
        ICLoggerHandler.logInfo(TAG, "onReceiveBattery " + icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.IntValue, percent);
        sendMsgToFlutter(ICWUploadEvent.TypeBattery, map);


    }


    @Override
    public void onReceiveUpgradePercent(ICDevice icDevice, ICConstant.ICUpgradeStatus icUpgradeStatus, int percent) {
        ICLoggerHandler.logInfo(TAG, "onReceiveUpgradePercent " +  " mac: "+icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.EnumName, icUpgradeStatus.name());
        map.put(ICMapKey.IntValue, percent);
        sendMsgToFlutter(ICWUploadEvent.TypeUpgrade, map);
    }

    @Override
    public void onReceiveDeviceInfo(ICDevice icDevice, ICDeviceInfo data) {
        ICLoggerHandler.logInfo(TAG, "onReceiveDeviceInfo " +  " mac: "+icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.getMacAddr());
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(data));
        sendMsgToFlutter(ICWUploadEvent.TypeDeviceInfo, map);
    }


    @Override
    public void onReceiveDebugData(ICDevice icDevice, int i, Object o) {
        ICLoggerHandler.logInfo(TAG, "onReceiveDebugData " +  " mac: "+icDevice.macAddr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.macAddr);
        map.put(ICMapKey.IntValue, i);
        map.put(ICMapKey.ObjectValue, o);
        sendMsgToFlutter(ICWUploadEvent.TypeDebugData, map);
    }

    @Override
    public void onReceiveConfigWifiResult(ICDevice icDevice, ICConstant.ICConfigWifiState result) {
        ICLoggerHandler.logInfo(TAG, "onReceiveConfigWifiResult " + result);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.macAddr);
        map.put(ICMapKey.EnumName, result.name());
        sendMsgToFlutter(ICWUploadEvent.TypeConfigWifi, map);
    }

    @Override
    public void onReceiveHR(ICDevice icDevice, int hr) {
        ICLoggerHandler.logInfo(TAG, "onReceiveHR " + " mac: "+icDevice.macAddr+" Hr:"+hr);
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.IntValue, hr);
        map.put(ICMapKey.Mac, icDevice.macAddr);
        sendMsgToFlutter(ICWUploadEvent.TypeHrData, map);
    }

    @Override
    public void onScanResult(ICScanDeviceInfo icScanDeviceInfo) {
        ICLoggerHandler.logInfo(TAG, "onScanResult " + icScanDeviceInfo.toString());
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.JsonValue, ICJson.beanToJson(icScanDeviceInfo));
        sendMsgToFlutter(ICWUploadEvent.TypeDeviceScan, map);
    }

    @Override
    public void onCallBack(ICConstant.ICSettingCallBackCode code) {
        ICLoggerHandler.logInfo(TAG, "onCallBack " + code.toString());
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.EnumName, code.name());
        sendMsgToFlutter(ICWUploadEvent.TypeSettingResult, map);
    }

    @Override
    public void onCallBack(ICDevice icDevice, ICConstant.ICAddDeviceCallBackCode code) {
        ICLoggerHandler.logInfo(TAG, "ICAddDeviceCallBackCode " + code.toString());
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.macAddr);
        map.put(ICMapKey.EnumName, code.name());
        sendMsgToFlutter(ICWUploadEvent.TypeAddDeviceResult, map);
    }

    @Override
    public void onCallBack(ICDevice icDevice, ICConstant.ICRemoveDeviceCallBackCode code) {
        ICLoggerHandler.logInfo(TAG, "ICRemoveDeviceCallBackCode " + code.toString());
        HashMap<String, Object> map = new HashMap<>();
        map.put(ICMapKey.Mac, icDevice.macAddr);
        map.put(ICMapKey.EnumName, code.name());
        sendMsgToFlutter(ICWUploadEvent.TypeRemoveDeviceResult, map);
    }


}
