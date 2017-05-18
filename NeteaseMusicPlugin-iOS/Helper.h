//
//  Header.h
//  NeteaseMusicPlugin-iOS
//
//  Created by Jesse Zhu on 2017/5/12.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface Helper : NSObject

/**
 替换对象方法
 @param originalClass 原始类
 @param originalSelector 原始类的方法
 @param swizzledClass 替换类
 @param swizzledSelector 替换类的方法
 */
void hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);

/**
 替换类方法
 
 @param originalClass 原始类
 @param originalSelector 原始类的类方法
 @param swizzledClass 替换类
 @param swizzledSelector 替换类的类方法
 */
void hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);

@end
