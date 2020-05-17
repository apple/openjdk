/*
 * Copyright (c) 2008-2020 Apple Inc. All rights reserved.
 *
 * @GPLv2-CPE_LICENSE_HEADER_START@
 *
 * The contents of this file are licensed under the terms of the
 * GNU Public License (version 2 only) with the "Classpath" exception.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only with
 * classpath exception, as published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * @GPLv2-CPE_LICENSE_HEADER_END@
 */

#import "JNFObject.h"

#import "JNFJNI.h"
#import "JNFString.h"

static JNF_CLASS_CACHE(sjc_Object, "java/lang/Object");

BOOL JNFObjectEquals(JNIEnv* env, jobject a, jobject b)
{
    if ((a == NULL) && (b == NULL)) return YES;
    if ((a == NULL) || (b == NULL)) return NO;

    static JNF_MEMBER_CACHE(jm_equals, sjc_Object, "equals", "(Ljava/lang/Object;)Z");
    return (BOOL)JNFCallBooleanMethod(env, a, jm_equals, b); // AWT_THREADING Safe (!appKit)
}

NSString *JNFObjectToString(JNIEnv *env, jobject obj)
{
    static JNF_MEMBER_CACHE(jm_toString, sjc_Object, "toString", "()Ljava/lang/String;");
    jobject name = JNFCallObjectMethod(env, obj, jm_toString); // AWT_THREADING Safe (known object)

    id result = JNFJavaToNSString(env, name);
    (*env)->DeleteLocalRef(env, name);
    return result;
}

NSString *JNFObjectClassName(JNIEnv* env, jobject obj)
{
    static JNF_MEMBER_CACHE(jm_getClass, sjc_Object, "getClass", "()Ljava/lang/Class;");

    jobject clz = JNFCallObjectMethod(env, obj, jm_getClass); // AWT_THREADING Safe (known object)
    NSString *result = JNFObjectToString(env, clz);
    (*env)->DeleteLocalRef(env, clz);
    return result;
}
