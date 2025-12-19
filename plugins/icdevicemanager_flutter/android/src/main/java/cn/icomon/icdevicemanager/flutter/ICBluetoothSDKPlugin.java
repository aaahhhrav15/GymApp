package cn.icomon.icdevicemanager.flutter;


import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cn.icomon.icdevicemanager.model.data.ICSkipLightSettingData;
import cn.icomon.icdevicemanager.model.data.ICSkipSoundSettingData;
import cn.icomon.icdevicemanager.model.data.ICWeightData;
import cn.icomon.icdevicemanager.model.device.ICDevice;
import cn.icomon.icdevicemanager.model.device.ICUserInfo;
import cn.icomon.icdevicemanager.model.other.ICDeviceManagerConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class ICBluetoothSDKPlugin implements FlutterPlugin, MethodCallHandler {

    private MethodChannel channel;

    private Context mContext;

    private final String TAG = "ICSDKManager";


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ic_bluetooth_sdk");
        mContext = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
        ICSDKManager.channel = channel;

    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Object arguments = call.arguments();
        HashMap<String, Object> params = new HashMap<>();
        HashMap<String, String> resultMap = new HashMap<>();

        if (arguments instanceof HashMap) {
            HashMap<String, Object> map = (HashMap<String, Object>) arguments;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                Log.e("Entry", entry.getKey() + "  -----" + entry.getValue().toString());
            }
            params.putAll(map);
        }
        Object jsonObj = params.get(ICMapKey.JsonValue);
        Object macObj = params.get(ICMapKey.Mac);
        Object enumObj = params.get(ICMapKey.EnumName);
        Object intObj = params.get(ICMapKey.IntValue);


        String mac = "";
        String cmdValue = "";
        List<ICDevice> devList;
        Object path;
        String filePath = "";
        int weight = 0;
        Log.e("onMethodCall", call.method);


        if (jsonObj != null) cmdValue = jsonObj.toString();
        if (macObj != null) mac = macObj.toString();
        if (intObj != null) weight = (int) intObj;

        switch (call.method) {
            case ICWPublishEvent.InitSDK:
                ICDeviceManagerConfig config = new ICDeviceManagerConfig();
                config.setContext(mContext);
                ICSDKManager.getInstance().initSdk(config);
                break;
            case ICWPublishEvent.AddDevice:
                ICSDKManager.getInstance().addDevice(mac, (dev, code) -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.AddDevices:
                devList = ICJson.toJavaList(cmdValue, ICDevice.class);
                ICSDKManager.getInstance().addDevices(devList, (device1, code) -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    resultMap.put(ICMapKey.Mac, device1.macAddr);
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.DeleteDevice:
                ICSDKManager.getInstance().removeDevice(mac, (device1, code) -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.DeleteDevices:
                devList = ICJson.toJavaList(cmdValue, ICDevice.class);
                ICSDKManager.getInstance().removeDevices(devList, (device1, code) -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    resultMap.put(ICMapKey.Mac, device1.macAddr);
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.OTADevice:
                path = params.get(ICMapKey.StringValue);
                if (path != null) {
                    filePath = path.toString();
                }

                ICSDKManager.getInstance().upgradeDevice(mac, filePath, ICDataConvert.getSDKOTAMode(enumObj));
                break;

            case ICWPublishEvent.OTADevices:
                devList = ICJson.toJavaList(cmdValue, ICDevice.class);
                path = params.get(ICMapKey.StringValue);
                if (path != null) {
                    filePath = path.toString();
                }
                ICSDKManager.getInstance().upgradeDevices(devList, filePath, ICDataConvert.getSDKOTAMode(enumObj));
                break;

            case ICWPublishEvent.StopOTADevice:
                ICSDKManager.getInstance().stopUpgradeDevice(mac);
                break;

            case ICWPublishEvent.StopOTADevices:
                devList = ICJson.toJavaList(cmdValue, ICDevice.class);
                ICSDKManager.getInstance().stopUpgradeDevices(devList);
                break;
            case ICWPublishEvent.StartScan:
                ICSDKManager.getInstance().scanDevice();
                break;
            case ICWPublishEvent.StopScan:
                ICSDKManager.getInstance().stopScan();
                break;
            case ICWPublishEvent.ScaleConfigWifi:
                Object ssidObj = params.get(ICMapKey.SSID);
                Object passwordObj = params.get(ICMapKey.Password);
                ICSDKManager.getInstance().configWifi(mac, ssidObj, passwordObj, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.ScaleUnitSetting:
                ICSDKManager.getInstance().setScaleUnit(mac, ICDataConvert.getSDKScaleUnit(enumObj), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.RulerUnitSetting:
                ICSDKManager.getInstance().setRulerUnit(mac, ICDataConvert.getRulerUnit(enumObj), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });

                break;
            case ICWPublishEvent.RulerModeSetting:
                ICSDKManager.getInstance().setRulerMeasureMode(mac, ICDataConvert.getRulerMode(enumObj), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.RulerBodyPartSetting:
                ICSDKManager.getInstance().setRulerBodyPartsType(mac, ICDataConvert.getSDKRulerPart(enumObj), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });

                break;

            case ICWPublishEvent.KitchenUnitSetting:
                ICSDKManager.getInstance().setKitchenScaleUnit(mac, ICDataConvert.getSDKKitchenUnitUnit(enumObj), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });

                break;
            case ICWPublishEvent.KitchenPowerOff:
                ICSDKManager.getInstance().powerOffKitchenScale(mac, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.KitchenCMD:
                break;
            case ICWPublishEvent.KitchenTareWeight:

                ICSDKManager.getInstance().deleteTareWeight(mac, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.KitchenFactory:

                break;

            case ICWPublishEvent.SetSkipMode:
            case ICWPublishEvent.SkipStart:
                Object settingObj = params.get(ICMapKey.IntValue);
                int nSetting = 0;
                if (settingObj != null) nSetting = (int) settingObj;
                ICSDKManager.getInstance().startSkip(mac, ICDataConvert.getSkipMode(enumObj), nSetting, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.SkipStop:
                ICSDKManager.getInstance().stopSkip(mac, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.SkipLightSetting:
                List<SkipLightSettingData> lightSettingData = ICJson.toJavaList(cmdValue, SkipLightSettingData.class);
                List<ICSkipLightSettingData> data = new ArrayList<>();
                for (SkipLightSettingData item : lightSettingData) {
                    data.add(new ICSkipLightSettingData(item.r, item.g, item.b, item.rpm));
                }
                ICSDKManager.getInstance().setSkipLightSetting(mac, data, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });

                break;
            case ICWPublishEvent.SkipSoundSetting:
                ICSkipSoundSettingData soundSettingData = ICJson.typeToObject(cmdValue, ICSkipSoundSettingData.class);
                if (soundSettingData != null) {
                    ICSDKManager.getInstance().setSkipVoiceSetting(mac, soundSettingData, code -> {
                        resultMap.put(ICMapKey.EnumName, code.name());
                        result.success(resultMap);
                    });
                }
                break;
            case ICWPublishEvent.SetUserInfo:
                ICSDKManager.getInstance().syncUserInfo(ICJson.typeToObject(cmdValue, ICUserInfo.class));
                break;
            case ICWPublishEvent.SetUserList:
                ICSDKManager.getInstance().syncUserList(ICJson.toJavaList(cmdValue, ICUserInfo.class));
                break;
            case ICWPublishEvent.SkipSetWeight:
                ICSDKManager.getInstance().setWeight(mac, weight, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.KitchenSetNutritionFacts:
                ICSDKManager.getInstance().setNutritionFacts(mac, ICDataConvert.getSDKNutritionFactType(enumObj), weight, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.SetServerUrl:
                ICSDKManager.getInstance().setServerUrl(mac, params.get(ICMapKey.StringValue), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.SetOtherParams:
                break;
            case ICWPublishEvent.SetScaleUIItems:
                break;
            case ICWPublishEvent.SkipLockSt:
                ICSDKManager.getInstance().lockStSkip(mac, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;
            case ICWPublishEvent.QueryStAllNode:
                ICSDKManager.getInstance().queryStAllNode(mac, code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.ChangeStName:
                ICSDKManager.getInstance().changeStName(mac, params.get(ICMapKey.StringValue), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });

                break;
            case ICWPublishEvent.ChangeStNo:

                ICSDKManager.getInstance().changeStNo(mac, params.get(ICMapKey.DstId), params.get(ICMapKey.StNo), code -> {
                    resultMap.put(ICMapKey.EnumName, code.name());
                    result.success(resultMap);
                });
                break;

            case ICWPublishEvent.GetLogPath:
                String logPath = ICSDKManager.getInstance().getLogPath();
                resultMap.put(ICMapKey.StringValue,logPath);
                result.success(resultMap);
                break;

            case ICWPublishEvent.CalcBodyFat:

                ICWeightData weightData = ICJson.typeToObject(cmdValue, ICWeightData.class);
                Object userJson = params.get(ICMapKey.JsonValue2);
                if (userJson != null) {
                    ICUserInfo userInfo = ICJson.typeToObject((String) userJson, ICUserInfo.class);
                    ICWeightData resultWeight = ICSDKManager.getInstance().CalcBodyFat(weightData, userInfo);
                    resultMap.put(ICMapKey.JsonValue, ICJson.beanToJson(resultWeight));
                    result.success(resultMap);
                }

                break;
            default:
                break;
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

}
