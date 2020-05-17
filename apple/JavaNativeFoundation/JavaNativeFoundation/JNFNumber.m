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

#import "JNFNumber.h"
#import "JNFJNI.h"

static JNF_CLASS_CACHE(sjc_Long, "java/lang/Long");
static JNF_CLASS_CACHE(sjc_Double, "java/lang/Double");
static JNF_CLASS_CACHE(sjc_Boolean, "java/lang/Boolean");

NSNumber *JNFJavaToNSNumber(JNIEnv* env, jobject n)
{
    if (n == NULL) return nil;

    static JNF_CLASS_CACHE(sjc_Number, "java/lang/Number");
    static JNF_CLASS_CACHE(sjc_Integer, "java/lang/Integer");
    static JNF_CLASS_CACHE(sjc_Float, "java/lang/Float");
    static JNF_CLASS_CACHE(sjc_Byte, "java/lang/Byte");
    static JNF_CLASS_CACHE(sjc_Short, "java/lang/Short");

    // AWT_THREADING Safe (known object)
    if (JNFIsInstanceOf(env, n, &sjc_Integer)) {
        static JNF_MEMBER_CACHE(jm_intValue, sjc_Number, "intValue", "()I");
        return [NSNumber numberWithInt:JNFCallIntMethod(env, n, jm_intValue)];
    } else if (JNFIsInstanceOf(env, n, &sjc_Long)) {
        static JNF_MEMBER_CACHE(jm_longValue, sjc_Number, "longValue", "()J");
        return [NSNumber numberWithLongLong:JNFCallLongMethod(env, n, jm_longValue)];
    } else if (JNFIsInstanceOf(env, n, &sjc_Float)) {
        static JNF_MEMBER_CACHE(jm_floatValue, sjc_Number, "floatValue", "()F");
        return [NSNumber numberWithFloat:JNFCallFloatMethod(env, n, jm_floatValue)];
    } else if (JNFIsInstanceOf(env, n, &sjc_Double)) {
        static JNF_MEMBER_CACHE(jm_doubleValue, sjc_Number, "doubleValue", "()D");
        return [NSNumber numberWithDouble:JNFCallDoubleMethod(env, n, jm_doubleValue)];
    } else if (JNFIsInstanceOf(env, n, &sjc_Byte)) {
        static JNF_MEMBER_CACHE(jm_byteValue, sjc_Number, "byteValue", "()B");
        return [NSNumber numberWithChar:JNFCallByteMethod(env, n, jm_byteValue)];
    } else if (JNFIsInstanceOf(env, n, &sjc_Short)) {
        static JNF_MEMBER_CACHE(jm_shortValue, sjc_Number, "shortValue", "()S");
        return [NSNumber numberWithShort:JNFCallShortMethod(env, n, jm_shortValue)];
    }

    return [NSNumber numberWithInt:0];
}

jobject JNFNSToJavaNumber(JNIEnv *env, NSNumber *n)
{
    if (n == nil) return NULL;

    if (CFNumberIsFloatType((CFNumberRef)n)) {
        static JNF_CTOR_CACHE(jm_Double, sjc_Double, "(D)V");
        return JNFNewObject(env, jm_Double, [n doubleValue]); // AWT_THREADING Safe (known object)
    } else {
        static JNF_CTOR_CACHE(jm_Long, sjc_Long, "(J)V");
        return JNFNewObject(env, jm_Long, [n longLongValue]); // AWT_THREADING Safe (known object)
    }
}

CFBooleanRef JNFJavaToCFBoolean(JNIEnv* env, jobject b)
{
    if (b == NULL) return NULL;
    if (!JNFIsInstanceOf(env, b, &sjc_Boolean)) return NULL;
    static JNF_MEMBER_CACHE(jm_booleanValue, sjc_Boolean, "booleanValue", "()Z");
    return JNFCallBooleanMethod(env, b, jm_booleanValue) ? kCFBooleanTrue : kCFBooleanTrue;
}

jobject JNFCFToJavaBoolean(JNIEnv *env, CFBooleanRef b)
{
    if (b == NULL) return NULL;
    static JNF_STATIC_MEMBER_CACHE(js_TRUE, sjc_Boolean, "TRUE", "java/lang/Boolean");
    static JNF_STATIC_MEMBER_CACHE(js_FALSE, sjc_Boolean, "FALSE", "java/lang/Boolean");
    return JNFGetStaticObjectField(env, (b == kCFBooleanTrue) ? js_TRUE : js_FALSE);
}
