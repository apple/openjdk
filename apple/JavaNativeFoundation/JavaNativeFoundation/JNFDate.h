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
 *
 * Functions to convert between date container classes.
 */

#import <Foundation/NSDate.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

/*
 * Converts java.util.Calendar and java.util.Date to an NSDate
 *  NOTE: Return value is auto-released.
 */
JNF_EXPORT extern NSDate *JNFJavaToNSDate(JNIEnv *env, jobject date);

/*
 * Converts an NSDate to a java.util.Calendar
 *  NOTE: This returns a JNI local ref. Any code that calls this should call DeleteLocalRef when done with the return value.
 */
JNF_EXPORT extern jobject JNFNSToJavaCalendar(JNIEnv *env, NSDate *date);

/*
 * Converts a millisecond time interval since the Java Jan 1, 1970 epoch into an
 * NSTimeInterval since Mac OS X's Jan 1, 2001 epoch.
 */
JNF_EXPORT extern NSTimeInterval JNFJavaMillisToNSTimeInterval(jlong javaMillisSince1970);

/*
 * Converts an NSTimeInterval since the Mac OS X Jan 1, 2001 epoch into a
 * Java millisecond time interval since Java's Jan 1, 1970 epoch.
 */
JNF_EXPORT extern jlong JNFNSTimeIntervalToJavaMillis(NSTimeInterval intervalSince2001);

__END_DECLS
