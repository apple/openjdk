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
