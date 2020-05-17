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
