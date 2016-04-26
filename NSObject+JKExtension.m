//
//  NSObject+JKExtension.m
//  利用 runtime 进行解归档
//
//  Created by 李佳贵 on 16/4/22.
//  Copyright © 2016年 李佳贵. All rights reserved.
//

#import "NSObject+JKExtension.h"
#import <objc/runtime.h>
// 忽略没有实现声明方法的警告
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (JKExtension)
//#pragma clang diagnostic pop


#pragma mark ************* 归档必须实现的方法 ****************
- (void)encode:(NSCoder *)encoder{
    
    Class c = self.class;
    while (c && c != [NSObject class]) {
        unsigned int outCount;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            // 获取属性名称
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            if ([self respondsToSelector:@selector(ignoreNames)]){
                NSString *no_key = [key substringFromIndex:1];
                if ([[self ignoreNames] containsObject:key] || [[self ignoreNames] containsObject:no_key]) continue;
            }
            // 通过 key 获取对应成员变量的值
            id value =[self valueForKeyPath:key];
            [encoder encodeObject:value forKey:key];
        }
        free(ivars);
        
        c = [c superclass];
    }
}
#pragma mark ************* 解档必须要实现的方法 ****************
- (instancetype)decode:(NSCoder *)decoder{
        Class c = self.class;
        while (c && c != [NSObject class]) {
            
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList([self class], &outCount);
            for (int i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                // 获取属性名称
                const char *name = ivar_getName(ivar);
                NSString *key = [NSString stringWithUTF8String:name];
                if ([self respondsToSelector:@selector(ignoreNames)]){
                    NSString *no_key = [key substringFromIndex:1]; // 去掉_
                    if ([[self ignoreNames] containsObject:key] || [[self ignoreNames] containsObject:no_key]) continue;
                }
                // 获取 key 对应的值
                id value = [decoder decodeObjectForKey:key];
                [self setValue:value forKeyPath:key];
            }
            free(ivars);
            c = [c superclass];
        }
    return self;
}


// 创建对象,字典转模型
+ (instancetype)objectWithDict:(NSDictionary *)dict{
    NSObject *object = [[self alloc] init];
    [object setDict:dict];
    return object;
}

- (void)setDict:(NSDictionary *)dict{
    
    Class c = self.class;
    while (c && c!= [NSObject class]) {
        unsigned int outCount;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            // 获取属性名称
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            key = [key substringFromIndex:1]; // 去掉_
            id value = dict[key];
            if (value == nil)  continue; // 防止 setValue forKey :方法中 value 不能为空
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            NSRange range = [type rangeOfString:@"@"];
            if (range.location != NSNotFound) { // 是@开头的类型
                type = [type substringWithRange:NSMakeRange(2,type.length - 3)];
                if (![type hasPrefix:@"NS"]) { // 排除系统类
                    NSLog(@"%@",type);
                    Class class = NSClassFromString(type);
                    value = [class objectWithDict:value];
                }else if([type isEqualToString:@"NSArray"]){
                    
                    if ([self respondsToSelector:@selector(objectClassInProArray)]) {
                        NSDictionary *classInArrayDic =[self objectClassInProArray];
                        NSObject *classInArrayPro = classInArrayDic[key]; // 根据 key 名取出属性数组中元素类型
                        if (classInArrayPro) { // 获取到类型
                            NSArray *array = value;
                            NSMutableArray *mArray = [NSMutableArray array];
                            Class class = NSClassFromString(classInArrayPro);
                            for (NSDictionary *dict in array) {
                                
                                [mArray addObject:[class objectWithDict:dict]];
                            }
                            value = mArray;
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
            
            [self setValue:value forKeyPath:key];
        }
        free(ivars);
        c = [c superclass];
    }
}

@end
