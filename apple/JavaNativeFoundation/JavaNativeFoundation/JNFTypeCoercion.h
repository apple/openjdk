/*
 * Copyright (c) 2008-2020 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 *
 * Type Coercion system that translates between Java VM objects and Objective-C Foundation objects.
 *
 * JNFTypeCoercions are registered into JNFTypeCoercers, which can be chained to other
 * JNFTypeCoercers using -deriveCoercer or -initWithParent. If the set of Coercions
 * in a Coercer aren't capable of converting an object, the Coercer will delegate up to
 * it's parent.
 *
 * Coercions are registered by Objective-C class and Java class name. If an object is an
 * instance of the registered class name, the coercion will be invoked. Default
 * implementations for several basic types are provided by JNFDefaultCoercions, and can
 * be installed in any order. More specific coercions should be placed farther down
 * a coercer chain, and more generic coercions should be placed higher. A Coercer can be
 * initialized with a basic Coercion that may want to handle "all cases", like calling
 * Object.toString() and -describe on all objects passed to it.
 *
 * Coercions are passed the Coercion-object that was originally invoked on the
 * target object. This permits the lowest level Coercion to be used for subsequent
 * object translations for composite objects. The provided List, Map, and Set Coercions
 * only handle object hierarchies, and will infinitely recurse if confronted with a
 * cycle in the object graph.
 *
 * Null and nil are both perfectly valid return types for Coercions, and do not indicate
 * a failure to coerce an object. Coercers are not thread safe.
 */

#import <Foundation/Foundation.h>
#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

@class JNFTypeCoercion;

JNF_EXPORT
@protocol JNFTypeCoercion

- (jobject) coerceNSObject:(id)obj withEnv:(JNIEnv *)env usingCoercer:(JNFTypeCoercion *)coercer;
- (id) coerceJavaObject:(jobject)obj withEnv:(JNIEnv *)env usingCoercer:(JNFTypeCoercion *)coercer;

@end


JNF_EXPORT
@interface JNFTypeCoercer : NSObject <JNFTypeCoercion>

- (id) init;
- (id) initWithParent:(NSObject <JNFTypeCoercion> *)parentIn;
- (JNFTypeCoercer *) deriveCoercer;
- (void) addCoercion:(NSObject <JNFTypeCoercion> *)coercion forNSClass:(Class)nsClass javaClass:(NSString *)javaClassName;

- (jobject) coerceNSObject:(id)obj withEnv:(JNIEnv *)env;
- (id) coerceJavaObject:(jobject)obj withEnv:(JNIEnv *)env;

@end


JNF_EXPORT
@interface JNFDefaultCoercions : NSObject { }

+ (void) addStringCoercionTo:(JNFTypeCoercer *)coercer;
+ (void) addNumberCoercionTo:(JNFTypeCoercer *)coercer;
+ (void) addDateCoercionTo:(JNFTypeCoercer *)coercer;
+ (void) addListCoercionTo:(JNFTypeCoercer *)coercer;
+ (void) addMapCoercionTo:(JNFTypeCoercer *)coercer;
+ (void) addSetCoercionTo:(JNFTypeCoercer *)coercer;

+ (JNFTypeCoercer *) defaultCoercer; // returns autoreleased copy, not shared, not thread safe

@end

__END_DECLS
