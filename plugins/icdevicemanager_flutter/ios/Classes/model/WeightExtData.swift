//
//  WeightExtData.swift
//  flutter_swift
//
//  Created by 凉茶 on 2022/10/10.
//

class WeightExtData:Codable{
    
    init(data:ICWeightExtData){
        left_arm=data.left_arm
        right_arm=data.right_arm
        left_leg=data.left_leg
        right_leg=data.right_leg
        all_body=data.all_body
        left_arm_kg=data.left_arm_kg
        right_arm_kg=data.right_arm_kg
        left_leg_kg=data.left_leg_kg
        right_leg_kg=data.right_leg_kg
        all_body_kg=data.all_body_kg
        left_arm_muscle=data.left_arm_muscle
        right_arm_muscle=data.right_arm_muscle
        left_leg_muscle=data.left_leg_muscle
        right_leg_muscle=data.right_leg_muscle
        all_body_muscle=data.all_body_muscle
        left_arm_muscle_kg=data.left_arm_muscle_kg
        right_arm_muscle_kg=data.right_arm_muscle_kg
        left_leg_muscle_kg=data.left_leg_muscle_kg
        right_leg_muscle_kg=data.right_leg_muscle_kg
        all_body_muscle_kg=data.all_body_muscle_kg
    };
    
    
    
    /**
          左手体脂率(单位:%, 精度:0.1)
       */
    var left_arm :Float;

      /**
          右手体脂率(单位:%, 精度:0.1)
       */
      var right_arm :Float;

      /**
          左脚体脂率(单位:%, 精度:0.1)
       */
      var left_leg :Float;

      /**
          右脚体脂率(单位:%, 精度:0.1)
       */
      var right_leg :Float;

      /**
          躯干体脂率(单位:%, 精度:0.1)
       */
      var all_body :Float;

      /**
          左手脂肪量(单位:kg, 精度:0.1)
       */
      var left_arm_kg :Float;

      /**
          右手脂肪量率(单位:kg, 精度:0.1)
       */
      var right_arm_kg :Float;

      /**
          左脚脂肪量(单位:kg, 精度:0.1)
       */
      var left_leg_kg :Float;

      /**
          右脚脂肪量(单位:kg, 精度:0.1)
       */
      var right_leg_kg :Float;

      /**
          躯干脂肪量(单位:kg, 精度:0.1)
       */
      var all_body_kg :Float;

      /**
          左手肌肉率(单位:%, 精度:0.1)
       */
      var left_arm_muscle :Float;

      /**
          右手肌肉率(单位:%, 精度:0.1)
       */
      var right_arm_muscle :Float;

      /**
          左脚肌肉率(单位:%, 精度:0.1)
       */
      var left_leg_muscle :Float;

      /**
          右脚肌肉率(单位:%, 精度:0.1)
       */
      var right_leg_muscle :Float;

      /**
          躯干肌肉率(单位:%, 精度:0.1)
       */
      var all_body_muscle :Float;

      /**
          左手肌肉量(单位:kg, 精度:0.1)
       */
      var left_arm_muscle_kg :Float;

      /**
          右手肌肉量(单位:kg, 精度:0.1)
       */
      var right_arm_muscle_kg :Float;

      /**
          左脚肌肉量(单位:kg, 精度:0.1)
       */
      var left_leg_muscle_kg :Float;

      /**
          右脚肌肉量(单位:kg, 精度:0.1)
       */
      var right_leg_muscle_kg :Float;

      /**
          躯干肌肉量(单位:kg, 精度:0.1)
       */
      var all_body_muscle_kg :Float;

}
