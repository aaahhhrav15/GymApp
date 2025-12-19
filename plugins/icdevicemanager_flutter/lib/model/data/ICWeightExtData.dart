import 'package:json_annotation/json_annotation.dart';

part 'ICWeightExtData.g.dart';

@JsonSerializable()
class ICWeightExtData {
  /**
      左手体脂率(单位:%, 精度:0.1)
   */
  double left_arm = 0.0;

  /**
      右手体脂率(单位:%, 精度:0.1)
   */
  double right_arm = 0.0;

  /**
      左脚体脂率(单位:%, 精度:0.1)
   */
  double left_leg = 0.0;

  /**
      右脚体脂率(单位:%, 精度:0.1)
   */
  double right_leg = 0.0;

  /**
      躯干体脂率(单位:%, 精度:0.1)
   */
  double all_body = 0.0;

  /**
      左手脂肪量(单位:kg, 精度:0.1)
   */
  double left_arm_kg = 0.0;

  /**
      右手脂肪量率(单位:kg, 精度:0.1)
   */
  double right_arm_kg = 0.0;

  /**
      左脚脂肪量(单位:kg, 精度:0.1)
   */
  double left_leg_kg = 0.0;

  /**
      右脚脂肪量(单位:kg, 精度:0.1)
   */
  double right_leg_kg = 0.0;

  /**
      躯干脂肪量(单位:kg, 精度:0.1)
   */
  double all_body_kg = 0.0;

  /**
      左手肌肉率(单位:%, 精度:0.1)
   */
  double left_arm_muscle = 0.0;

  /**
      右手肌肉率(单位:%, 精度:0.1)
   */
  double right_arm_muscle = 0.0;

  /**
      左脚肌肉率(单位:%, 精度:0.1)
   */
  double left_leg_muscle = 0.0;

  /**
      右脚肌肉率(单位:%, 精度:0.1)
   */
  double right_leg_muscle = 0.0;

  /**
      躯干肌肉率(单位:%, 精度:0.1)
   */
  double all_body_muscle = 0.0;

  /**
      左手肌肉量(单位:kg, 精度:0.1)
   */
  double left_arm_muscle_kg = 0.0;

  /**
      右手肌肉量(单位:kg, 精度:0.1)
   */
  double right_arm_muscle_kg = 0.0;

  /**
      左脚肌肉量(单位:kg, 精度:0.1)
   */
  double left_leg_muscle_kg = 0.0;

  /**
      右脚肌肉量(单位:kg, 精度:0.1)
   */
  double right_leg_muscle_kg = 0.0;

  /**
      躯干肌肉量(单位:kg, 精度:0.1)
   */
  double all_body_muscle_kg = 0.0;

  ICWeightExtData();

  factory ICWeightExtData.fromJson(Map<String, dynamic> json) =>
      _$ICWeightExtDataFromJson(json);

  Map<String, dynamic> toJson() => _$ICWeightExtDataToJson(this);

  @override
  String toString() {
    return 'ICWeightExtData{left_arm: $left_arm, right_arm: $right_arm, left_leg: $left_leg, right_leg: $right_leg, all_body: $all_body, left_arm_kg: $left_arm_kg, right_arm_kg: $right_arm_kg, left_leg_kg: $left_leg_kg, right_leg_kg: $right_leg_kg, all_body_kg: $all_body_kg, left_arm_muscle: $left_arm_muscle, right_arm_muscle: $right_arm_muscle, left_leg_muscle: $left_leg_muscle, right_leg_muscle: $right_leg_muscle, all_body_muscle: $all_body_muscle, left_arm_muscle_kg: $left_arm_muscle_kg, right_arm_muscle_kg: $right_arm_muscle_kg, left_leg_muscle_kg: $left_leg_muscle_kg, right_leg_muscle_kg: $right_leg_muscle_kg, all_body_muscle_kg: $all_body_muscle_kg}';
  }
}
