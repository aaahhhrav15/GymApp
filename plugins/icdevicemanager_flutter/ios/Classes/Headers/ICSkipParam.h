//
//  ICSkipParam.h
//  ICDeviceManager
//
//  Created by symons on 2022/9/21.
//  Copyright © 2022 Symons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICSkipParam : NSObject

/**
 模式
 */
@property (nonatomic, assign) ICSkipMode mode;

/**
 跳绳参数/ 间歇跳，单轮时长/单轮次数（S2）

 */
@property (nonatomic, assign) NSUInteger param;

/**
 间歇跳，单轮休息时长
 */
@property (nonatomic, assign) NSUInteger rest_time;

/**
 间歇跳，组数
 */
@property (nonatomic, assign) NSUInteger group;


@end

NS_ASSUME_NONNULL_END
