enum ICWPublishEvent {
  initSDK("InitSDK"),
  addDevice("AddDevice"),
  addDevices("AddDevices"),
  removeDevice("RemoveDevice"),
  removeDevices("RemoveDevices"),
  otaDevice("OTADevice"),
  otaDevices("OTADevices"),
  stopOTADevice("StopOTADevice"),
  stopOTADevices("StopOTADevices"),
  stopScan("StopScan"),
  startScan("StartScan"),
  updateUserInfo("SetUserInfo"),
  setUserList("SetUserList"),
  configWifi("configWifi"),
  setScaleUnit("setScaleUnit"),
  setRulerUnit("RulerUnitSetting"),
  setRulerMeasureMode("RulerModeSetting"),
  setRulerBodyPartsType("RulerBodyPartSetting"),
  setWeight("SkipSetWeight"),
  KitchenCMD("KitchenCMD"),
  KitchenFactory("KitchenFactory"),
  deleteTareWeight("KitchenTareWeight"),
  powerOffKitchenScale("KitchenPowerOff"),
  setKitchenSaleUnit("KitchenUnitSetting"),
  KitchenSetNutritionFacts("KitchenSetNutritionFacts"),
  stopSkip("SkipStop"),
  startSkip("SkipStart"),
  SetSkipMode("SetSkipMode"),
  lockStSkip("SkipLockSt"),
  skipLightSetting("SkipLightSetting"),
  skipSoundsSetting("SkipSoundSetting"),
  skipSetUserInfo("SkipSetUserInfo"),
  changeStNo("changeStNo"),
  changeStName("changeStName"),
  setOtherParams("setOtherParams"),
  setScaleUIItems("setScaleUIItems"),
  setServerUrl("setServerUrl"),
  queryStAllNode("queryStAllNode"),
  debugCommand("debugCommand"),
  calcBodyFat("CalcBodyFat"),
  getLogPath("LogPath");

  final String value;

  const ICWPublishEvent(this.value);

  String getValue() {
    return value;
  }
}

