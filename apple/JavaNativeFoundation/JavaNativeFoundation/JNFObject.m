/*
 JNFObject.m
 Java Native Foundation
 Copyright (c) 2008, Apple Inc.
 All rights reserved.
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
