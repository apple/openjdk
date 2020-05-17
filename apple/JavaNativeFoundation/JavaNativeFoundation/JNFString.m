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

#import "JNFString.h"

#import "JNFJNI.h"
#import "JNFAssert.h"
#import "debug.h"

#define STACK_BUFFER_SIZE 64

/*
 * Utility function to convert java String to NSString. We don't go through intermediate cString
 * representation, since we are trying to preserve unicode characters from Java to NSString.
 */
NSString *JNFJavaToNSString(JNIEnv *env, jstring javaString)
{
    // We try very hard to only allocate and memcopy once. 
    if (javaString == NULL) return nil;

    jsize length = (*env)->GetStringLength(env, javaString);
    unichar *buffer = (unichar *)calloc((size_t)length, sizeof(unichar));
    (*env)->GetStringRegion(env, javaString, 0, length, buffer);
    NSString *str = (NSString *)CFStringCreateWithCharactersNoCopy(NULL, buffer, length, kCFAllocatorMalloc);
    //	NSLog(@"%@", str);
    return [(NSString *)CFMakeCollectable(str) autorelease];
}

/*
 * Utility function to convert NSString to Java string. We don't go through intermediate cString
 * representation, since we are trying to preserve unicode characters in translation.
 */
jstring JNFNSToJavaString(JNIEnv *env, NSString *nsString)
{
    jstring res = nil;
    if (nsString == nil) return NULL;

    unsigned long length = [nsString length];
    unichar *buffer;
    unichar stackBuffer[STACK_BUFFER_SIZE];
    if (length > STACK_BUFFER_SIZE) {
        buffer = (unichar *)calloc(length, sizeof(unichar));
    } else {
        buffer = stackBuffer;
    }

    JNF_ASSERT_COND(buffer != NULL);
    [nsString getCharacters:buffer];	
    res = (*env)->NewString(env, buffer, (jsize)length);
    if (buffer != stackBuffer) free(buffer);
    return res;
}

const unichar *JNFGetStringUTF16UniChars(JNIEnv *env, jstring javaString)
{
    const jchar *unichars = NULL;
    JNF_ASSERT_COND(javaString != NULL);
    unichars = (*env)->GetStringChars(env, javaString, NULL);
    if (unichars == NULL) [JNFException raise:env as:kNullPointerException reason:"unable to obtain characters from GetStringChars"];
    return (const unichar *)unichars;
}

void JNFReleaseStringUTF16UniChars(JNIEnv *env, jstring javaString, const unichar *unichars)
{
    JNF_ASSERT_COND(unichars != NULL);
    (*env)->ReleaseStringChars(env, javaString, (const jchar *)unichars);
}

const char *JNFGetStringUTF8Chars(JNIEnv *env, jstring javaString)
{
    const char *chars = NULL;
    JNF_ASSERT_COND(javaString != NULL);
    chars = (*env)->GetStringUTFChars(env, javaString, NULL);
    if (chars == NULL) [JNFException raise:env as:kNullPointerException reason:"unable to obtain characters from GetStringUTFChars"];
    return chars;
}

void JNFReleaseStringUTF8Chars(JNIEnv *env, jstring javaString, const char *chars)
{
    JNF_ASSERT_COND(chars != NULL);
    (*env)->ReleaseStringUTFChars(env, javaString, (const char *)chars);
}
