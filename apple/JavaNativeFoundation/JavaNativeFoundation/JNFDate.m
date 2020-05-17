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

#import "JNFDate.h"
#import "JNFJNI.h"


static JNF_CLASS_CACHE(sjc_Calendar, "java/util/Calendar");
static JNF_CLASS_CACHE(sjc_Date, "java/util/Date");

JNF_EXPORT extern NSTimeInterval JNFJavaMillisToNSTimeInterval(jlong javaMillisSince1970)
{
    return (NSTimeInterval)(((double)javaMillisSince1970 / 1000.0) - NSTimeIntervalSince1970);
}

JNF_EXPORT extern jlong JNFNSTimeIntervalToJavaMillis(NSTimeInterval intervalSince2001)
{
    return (jlong)((intervalSince2001 + NSTimeIntervalSince1970) * 1000.0);
}

JNF_EXPORT extern NSDate *JNFJavaToNSDate(JNIEnv *env, jobject date)
{
    if (date == NULL) return nil;

    jlong millis = 0;
    if (JNFIsInstanceOf(env, date, &sjc_Calendar)) {
        static JNF_MEMBER_CACHE(jm_getTimeInMillis, sjc_Calendar, "getTimeInMillis", "()J");
        millis = JNFCallLongMethod(env, date, jm_getTimeInMillis);
    } else if (JNFIsInstanceOf(env, date, &sjc_Date)) {
        static JNF_MEMBER_CACHE(jm_getTime, sjc_Date, "getTime", "()J");
        millis = JNFCallLongMethod(env, date, jm_getTime);
    }

    if (millis == 0) {
        return nil;
    }

    return [NSDate dateWithTimeIntervalSince1970:((double)millis / 1000.0)];
}

JNF_EXPORT extern jobject JNFNSToJavaCalendar(JNIEnv *env, NSDate *date)
{
    if (date == nil) return NULL;

    const jlong millis = (jlong)([date timeIntervalSince1970] * 1000.0);

    static JNF_STATIC_MEMBER_CACHE(jsm_getInstance, sjc_Calendar, "getInstance", "()Ljava/util/Calendar;");
    jobject calendar = JNFCallStaticObjectMethod(env, jsm_getInstance);

    static JNF_MEMBER_CACHE(jm_setTimeInMillis, sjc_Calendar, "setTimeInMillis", "(J)V");
    JNFCallVoidMethod(env, calendar, jm_setTimeInMillis, millis);

    return calendar;
}
