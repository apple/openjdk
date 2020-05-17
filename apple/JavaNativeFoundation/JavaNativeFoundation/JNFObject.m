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
