//
//  NSObject+JKExtension.h
//  利用 runtime 进行解归档
//
//  Created by 李佳贵 on 16/4/22.
//  Copyright © 2016年 李佳贵. All rights reserved.
//

// 注意枚举的使用
/*
 typedef enum {
 SexMale,
 SexFemale} Sex;
 @interface User : NSObject
 @property (copy, nonatomic) NSString *name;
 @property (copy, nonatomic) NSString *icon;
 @property (assign, nonatomic) int age;
 @property (assign, nonatomic) double height;
 @property (strong, nonatomic) NSNumber *money;
 @property (assign, nonatomic) Sex sex;
 @end
 
 NSDictionary *dict = @{
 @"name" : @"Jack",
 @"icon" : @"lufy.png",
 @"age" : @20,
 @"height" : @"1.55",
 @"money" : @100.9,
 @"sex" : @(SexFemale)
 };

 
 */


#import <Foundation/Foundation.h>

@interface NSObject (JKExtension)

//0.    --------字典转模型相关-----
// 获取所有属性数组里存的什么类型的数据,生成一个  @{@"数组属性名1" : @"所存模型类型1",@"数组属性名2" : @"所存模型类型2"}
// 如果不声明则给对应的属性赋值为字典数组 或者是 字符串数组
- (NSDictionary *)objectClassInProArray;

// 字典转模型
- (void)setDict:(NSDictionary *)dict;
+ (instancetype)objectWithDict:(NSDictionary *)dict;



//1.     ---------归档相关---------
// 如果有不需要归档的属性,请实现此方法,返回需要忽略的参数名
// eg. return @[@"name"] 或者 return @[@"_name"] 两个效果一样
- (NSArray *)ignoreNames;
- (void)encode:(NSCoder *)encoder;
- (instancetype)decode:(NSCoder *)decoder;

#define JKCodingImplement \
- (void)encodeWithCoder:(NSCoder *)encoder\
{\
    [self encode:encoder];\
    \
}\
- (instancetype)initWithCoder:(NSCoder *)decoder\
{\
    self = [super init];\
    if (self) {\
        [self decode:decoder];\
    }\
    return self;\
}





@end
