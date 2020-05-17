/*
 JNFPath.m
 Java Native Foundation
 Copyright (c) 2008, Apple Inc.
 All rights reserved.
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
