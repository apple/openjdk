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
