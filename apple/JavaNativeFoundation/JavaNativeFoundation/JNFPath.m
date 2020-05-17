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

#import "JNFPath.h"

#import <Cocoa/Cocoa.h>

#import "JNFString.h"

jstring JNFNormalizedJavaStringForPath(JNIEnv *env, NSString *inString)
{	
    if (inString == nil) return NULL;

    CFMutableStringRef mutableDisplayName = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)inString);
    CFStringNormalize(mutableDisplayName, kCFStringNormalizationFormC);
    jstring returnValue = JNFNSToJavaString(env, (NSString *)mutableDisplayName);
    CFRelease(mutableDisplayName);

    return returnValue;
}

NSString *JNFNormalizedNSStringForPath(JNIEnv *env, jstring javaString)
{
    if (javaString == NULL) return nil;

    // We were given a filename, so convert it to a compatible representation for the file system.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *fileName = JNFJavaToNSString(env, javaString);
    const char *compatibleFilename = [fm fileSystemRepresentationWithPath:fileName];
    return [fm stringWithFileSystemRepresentation:compatibleFilename length:strlen(compatibleFilename)];
}
