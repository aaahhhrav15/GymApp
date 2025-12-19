/**
    设备类型
 **/
enum ICDeviceType {
  /// 未知
  ///*/
  ICDeviceTypeUnKnown,

  /// 体重秤
  ///*/
  ICDeviceTypeWeightScale,

  /// 脂肪秤
  ///*/
  ICDeviceTypeFatScale,

  /// 脂肪秤(带温度显示)
  ///*/
  ICDeviceTypeFatScaleWithTemperature,

  /// 厨房秤
  ///*/
  ICDeviceTypeKitchenScale,

  /// 围尺
  ///*/
  ICDeviceTypeRuler,

  /// 平衡秤
  ///*/
  ICDeviceTypeBalance,

  /// 跳绳
  ///*/
  ICDeviceTypeSkip,

  /// HR
  ///*/
  ICDeviceTypeHR,
}

/**
    蓝牙状态
 */
enum ICBleState {
  /// 未知状态
  ///*/
  ICBleStateUnknown,

  /// 手机不支持BLE
  ///*/
  ICBleStateUnsupported,

  /// 应用未获取蓝牙授权
  ///*/
  ICBleStateUnauthorized,

  /// 蓝牙关闭
  ///*/
  ICBleStatePoweredOff,

  /// 蓝牙打开
  ///*/
  ICBleStatePoweredOn,

  /// 蓝牙异常,建议开关蓝牙或重启手机
  ///*/
  ICBleStateException



}

/**
    设备子类型
 **/
enum ICDeviceSubType {
  /// 默认
  ///*/
  ICDeviceSubTypeDefault,

  /// 8电极设备
  ///*/
  ICDeviceSubTypeEightElectrode,

  /// 身高设备
  ///*/
  ICDeviceSubTypeHeight,

  /// 8电极设备2
  ///*/
  ICDeviceSubTypeEightElectrode2,

  /// 双模设备
  ///*/
  ICDeviceSubTypeScaleDual,

  /// 跳绳带灯效
  ///*/
  ICDeviceSubTypeLightEffect,

  /// 彩屏秤
  ///*/
  ICDeviceSubTypeColor,

  /// 跳绳带语音
  ///*/
  ICDeviceSubTypeSound,

  /// 跳绳带灯效和语音
  ///*/
  ICDeviceSubTypeLightAndSound,

  /// 基站
  ICDeviceSubTypeBaseSt,
}

/**
    设备通讯方式

 */
enum ICDeviceCommunicationType  {
  /**
      未知
   */
  ICDeviceCommunicationTypeUnknown,

  /**
      连接式
   */
  ICDeviceCommunicationTypeConnect,

  /**
      广播式
   */
  ICDeviceCommunicationTypeBroadcast,
}

/**
    设备连接状态

 */
enum ICDeviceConnectState {
  /// 已连接
  ///*/
  ICDeviceConnectStateConnected,

  /// 已断开
  ///*/
  ICDeviceConnectStateDisconnected;




}

/// 添加设备回调代码
enum ICAddDeviceCallBackCode {
  /// 添加成功
  ICAddDeviceCallBackCodeSuccess,

  /// 添加失败,SDK未初始化
  ICAddDeviceCallBackCodeFailedAndSDKNotInit,

  /// 添加失败，设备已存在
  ICAddDeviceCallBackCodeFailedAndExist,

  /// 添加失败，设备参数有错
  ICAddDeviceCallBackCodeFailedAndDeviceParamError;

}

/// 删除设备回调代码
enum ICRemoveDeviceCallBackCode {
  /// 删除成功
  ICRemoveDeviceCallBackCodeSuccess,

  /// 删除失败,SDK未初始化
  ICRemoveDeviceCallBackCodeFailedAndSDKNotInit,

  /// 删除失败，设备不存在
  ICRemoveDeviceCallBackCodeFailedAndNotExist,

  /// 删除失败，设备参数有错
  ICRemoveDeviceCallBackCodeFailedAndDeviceParamError;


}

/**
    设置回调错误代码

 */
enum ICSettingCallBackCode {
  /// 设置成功
  ///*/
  ICSettingCallBackCodeSuccess,

  /// 设置失败，SDK没有初始化
  ///*/
  ICSettingCallBackCodeSDKNotInit,

  /// 设置失败，SDK没有启动
  ///*/
  ICSettingCallBackCodeSDKNotStart,

  /// 设置失败，找不到设备或者设备未连接，请等待设备连接上后再设置
  ///*/
  ICSettingCallBackCodeDeviceNotFound,

  /// 设置失败，设备不支持该功能
  ///*/
  ICSettingCallBackCodeFunctionIsNotSupport,

  /// 设置失败，设备已断开
  ///*/
  ICSettingCallBackCodeDeviceDisConnected,

  /// 设置失败，无效参数
  ///*/
  ICSettingCallBackCodeInvalidParameter,

  /// 设置失败
  ///*/
  ICSettingCallBackCodeFailed


}

/**
    体重秤单位
 */
enum ICWeightUnit {
  /// 公斤
  ICWeightUnitKg,

  /// 磅
  ICWeightUnitLb,

  /// 英石
  ICWeightUnitSt,

  /// 斤
  ICWeightUnitJin;



}

/**
    围尺单位
 */
enum ICRulerUnit {
  /// 厘米cm
  ICRulerUnitCM,

  /// 英寸inch
  ICRulerUnitInch,

  /// 英尺'英寸
  ICRulerUnitFtInch;


}

/**
    围尺测量模式
 */
enum ICRulerMeasureMode {
  /// 长度模式
  ICRulerMeasureModeLength,

  /// 围度模式
  ICRulerMeasureModeGirth;

}

/**
    围尺设置的部位类型
 */
enum ICRulerBodyPartsType {
  /// 肩膀
  ICRulerPartsTypeShoulder,

  /// 手臂
  ICRulerPartsTypeBicep,

  /// 胸
  ICRulerPartsTypeChest,

  /// 腰
  ICRulerPartsTypeWaist,

  /// 臀
  ICRulerPartsTypeHip,

  /// 大腿
  ICRulerPartsTypeThigh,

  /// 小腿
  ICRulerPartsTypeCalf;



}

/**
    性别
 */
enum ICSexType {
  /// 未知/保密
  ICSexTypeUnknown,

  /// 男
  ICSexTypeMale,

  /// 女
  ICSexTypeFemale
}

/**
    厨房秤单位
 */
enum ICKitchenScaleUnit {
  /// 克
  ICKitchenScaleUnitG,

  /// ml(water)
  ICKitchenScaleUnitMl,

  /// 磅
  ICKitchenScaleUnitLb,

  /// 盎司
  ICKitchenScaleUnitOz,

  /// 毫克
  ICKitchenScaleUnitMg,

  /// ml(牛奶)
  ICKitchenScaleUnitMlMilk,

  /// 盎司(水)
  ICKitchenScaleUnitFlOzWater,

  /// 盎司(牛奶)
  ICKitchenScaleUnitFlOzMilk



}

/**
    厨房秤营养成分类型
 */
enum ICKitchenScaleNutritionFactType {
  /*
         *  卡路里, 最大不超过4294967295
         */
  ICKitchenScaleNutritionFactTypeCalorie,

  /*
         *  总卡路里, 最大不超过4294967295
         */
  ICKitchenScaleNutritionFactTypeTotalCalorie,

  /*
         *  总脂肪
         */
  ICKitchenScaleNutritionFactTypeTotalFat,

  /*
         *  总蛋白质
         */
  ICKitchenScaleNutritionFactTypeTotalProtein,

  /*
         *  总碳水化合物
         */
  ICKitchenScaleNutritionFactTypeTotalCarbohydrates,

  /*
         *  总脂肪纤维
         */
  ICKitchenScaleNutritionFactTypeTotalFiber,

  /*
         *  总胆固醇
         */
  ICKitchenScaleNutritionFactTypeTotalCholesterd,

  /*
         *  总钠含量
         */
  ICKitchenScaleNutritionFactTypeTotalSodium,

  /*
         *  总糖含量
         */
  ICKitchenScaleNutritionFactTypeTotalSugar,

  /*
         * 脂肪
         */
  ICKitchenScaleNutritionFactTypeFat,

  /*
         * 蛋白质
         */
  ICKitchenScaleNutritionFactTypeProtein,

  /*
         * 碳水化合物
         */
  ICKitchenScaleNutritionFactTypeCarbohydrates,

  /*
         * 膳食纤维
         */
  ICKitchenScaleNutritionFactTypeFiber,

  /*
         * 胆固醇
         */
  ICKitchenScaleNutritionFactTypeCholesterd,

  /*
         * 钠含量
         */
  ICKitchenScaleNutritionFactTypeSodium,

  /*
         * 糖含量
         */
  ICKitchenScaleNutritionFactTypeSugar,
}

/**
    算法版本
 */
enum ICBFAType {

  ICBFATypeWLA01,
  ICBFATypeWLA02,
  ICBFATypeWLA03,
  ICBFATypeWLA04,
  ICBFATypeWLA05,
  ICBFATypeWLA06,
  ICBFATypeWLA07,
  ICBFATypeWLA08,
  ICBFATypeWLA09,
  ICBFATypeWLA10,
  ICBFATypeWLA11,
  ICBFATypeWLA12,
  ICBFATypeWLA13,
  ICBFATypeWLA14,
  ICBFATypeWLA15,
  ICBFATypeWLA16,
  ICBFATypeWLA17,
  ICBFATypeWLA18,
  ICBFATypeWLA19,
  ICBFATypeWLA20,
  ICBFATypeWLA22,
  ICBFATypeWLA23,
  ICBFATypeWLA24,
  ICBFATypeWLA25,
  ICBFATypeWLA26,
  ICBFATypeWLA27,
  ICBFATypeWLA28,
  ICBFATypeWLA29,
  ICBFATypeUnknown,
  ICBFATypeRev;



  static ICBFAType valueOf(int value) {
    switch (value) {
      // #if WLA01
      case 0:
        return ICBFATypeWLA01;
      // #endif WLA01
      // #if WLA02
      case 1:
        return ICBFATypeWLA02;
      // #endif WLA02
      // #if WLA03
      case 2:
        return ICBFATypeWLA03;
      // #endif WLA03
      // #if WLA04
      case 3:
        return ICBFATypeWLA04;
      // #endif WLA04
      // #if WLA05
      case 4:
        return ICBFATypeWLA05;
      // #endif WLA05
      // #if WLA06
      case 5:
        return ICBFATypeWLA06;
      // #endif WLA06
      // #if WLA07
      case 6:
        return ICBFATypeWLA07;
      // #endif WLA07
      // #if WLA08
      case 7:
        return ICBFATypeWLA08;
      // #endif WLA08
      // #if WLA09
      case 8:
        return ICBFATypeWLA09;
      // #endif WLA09
      // #if WLA10
      case 9:
        return ICBFATypeWLA10;
      // #endif WLA10
      // #if WLA11
      case 10:
        return ICBFATypeWLA11;
      // #endif WLA11
      // #if WLA12
      case 11:
        return ICBFATypeWLA12;
      // #endif WLA12
      // #if WLA13
      case 12:
        return ICBFATypeWLA13;
      // #endif WLA13
      // #if WLA14
      case 13:
        return ICBFATypeWLA14;
      // #endif WLA14
      // #if WLA15
      case 14:
        return ICBFATypeWLA15;
      // #endif WLA15
      // #if WLA16
      case 15:
        return ICBFATypeWLA16;
      // #endif WLA16
      // #if WLA17
      case 16:
        return ICBFATypeWLA17;
      // #endif WLA17
      // #if WLA18
      case 17:
        return ICBFATypeWLA18;
      // #endif WLA18
      // #if WLA19
      case 18:
        return ICBFATypeWLA19;
      // #endif WLA19
      // #if WLA22
      case 21:
        return ICBFATypeWLA22;
      // #endif WLA22
      // #if WLA23
      case 22:
        return ICBFATypeWLA23;
      // #endif WLA23
      // #if WLA24
      case 23:
        return ICBFATypeWLA24;
      // #endif WLA24
      // #if WLA25
      case 24:
        return ICBFATypeWLA25;
      // #endif WLA25
      // #if WLA26
      case 25:
        return ICBFATypeWLA26;
      // #endif WLA26
      // #if WLA27
      case 26:
        return ICBFATypeWLA27;
      // #endif WLA27
      // #if WLA28
      case 27:
        return ICBFATypeWLA28;
      // #endif WLA28
      // #if WLA29
      case 28:
        return ICBFATypeWLA29;
      // #endif WLA29
    }
    return ICBFATypeRev;
  }
}

/**
    用户类型
 */
enum ICPeopleType {
  /*
         * 普通人
         */
  ICPeopleTypeNormal,

  /*
         * 运动员
         */
  ICPeopleTypeSportman,
}

/**
    数据类型
 */
enum ICMeasureStep {
  /*
         * 测量体重 (ICWeightData)
         */
  ICMeasureStepMeasureWeightData("ICMeasureStepMeasureWeightData"),

  /*
         * 测量平衡 (ICWeightCenterData)
         */
  ICMeasureStepMeasureCenterData("ICMeasureStepMeasureWeightData"),

  /*
         * 开始测量阻抗
         */
  ICMeasureStepAdcStart("ICMeasureStepAdcStart"),

  /*
         * 测量阻抗结束 (ICWeightData)
         */
  ICMeasureStepAdcResult("ICMeasureStepAdcResult"),

  /*
         * 开始测量心率
         */
  ICMeasureStepHrStart("ICMeasureStepHrStart"),

  /*
         * 测量心率结束 (ICWeightData)
         */
  ICMeasureStepHrResult("ICMeasureStepHrResult"),

  /*
         * 测量结束
         */
  ICMeasureStepMeasureOver("ICMeasureStepMeasureOver");

  final String value;

  const ICMeasureStep(this.value);


}

/// 跳绳模式
enum ICSkipMode {
  /// 自由跳
  ICSkipModeFreedom,
  /// 计时跳
  ICSkipModeTiming,

  /// 计次跳
  ICSkipModeCount;


}

/*
     * 跳绳灯效模式
     */
enum ICSkipLightMode {
  /*
         * 无
         */
  ICSkipLightModeNone,
  /*
         * 速度模式
         */
  ICSkipLightModeRPM,
  /*
         * 计时模式
         */
  ICSkipLightModeTimer,
  /*
         * 计次模式
         */
  ICSkipLightModeCount,
  /*
         * 百分比模式
         */
  ICSkipLightModePercent,
  /*
         * 绊绳次数模式
         */
  ICSkipLightModeTripRope,
  /*
         * 测量模式模式
         */
  ICSkipLightModeMeasuring,
}

/// 升级状态
enum ICUpgradeStatus {
  /// 升级成功
  ICUpgradeStatusSuccess,

  /// 升级中
  ICUpgradeStatusUpgrading,

  /// 升级失败
  ICUpgradeStatusFail,

  /// 升级失败，文件无效
  ICUpgradeStatusFailFileInvalid,

  /// 升级失败，设备不支持升级
  ICUpgradeStatusFailNotSupport


}

/// Wifi配网状态
enum ICConfigWifiState {
  ICConfigWifiStateSuccess,
  ICConfigWifiStateWifiConnecting,
  ICConfigWifiStateServerConnecting,
  ICConfigWifiStateWifiConnectFail,
  ICConfigWifiStateServerConnectFail,
  ICConfigWifiStatePasswordFail,
  ICConfigWifiStateFail


}

/*
     * 语音类型
     */
enum ICSkipSoundType {
  /*
         * 无
         */
  ICSkipSoundTypeNone,
  /*
         * 标准中文女声
         */
  ICSkipSoundTypeFemale,
  /*
         * 标准中文男声
         */
  ICSkipSoundTypeMale,
}

/*
     * 语音模式
     */
enum ICSkipSoundMode {
  /*
         * 无
         */
  ICSkipSoundModeNone,
  /*
         * 按间隔时长
         */
  ICSkipSoundModeTime,
  /*
         * 按间隔个数
         */
  ICSkipSoundModeCount,
}

/*
     * 升级模式
     */
enum ICOTAMode {
  /*
         * 自动模式
         */
  ICOTAModeAuto,
  /*
         * 模式1
         */
  ICOTAMode1,
  /*
         * 模式2
         */
  ICOTAMode2,
  /*
         * 模式3
         */
  ICOTAMode3,
}
