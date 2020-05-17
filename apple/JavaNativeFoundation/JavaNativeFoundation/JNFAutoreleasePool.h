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
 * Utility class used by the JNF_COCOA_ENTER()/JNF_COCOA_EXIT() macros
 * from JNFJNI.h. Do not use this class or releated functions directly.
 */

#import <Foundation/Foundation.h>

#import <JavaNativeFoundation/JNFJNI.h>

__BEGIN_DECLS

typedef void JNFAutoreleasePoolToken;

// JNFNativeMethodEnter - called on entry to each native method by the
// JNF_COCOA_ENTER(env) macro in JNFJNI.h
JNF_EXPORT extern JNFAutoreleasePoolToken *JNFNativeMethodEnter(void);

// JNFNativeMethodExit - called on exit from each native method by the
// JNF_COCOA_EXIT(env) macro in JNFJNI.h
JNF_EXPORT extern void JNFNativeMethodExit(JNFAutoreleasePoolToken *token);

__END_DECLS
