/*
 * Copyright (c) 2000-2014 by Apple Inc.. All rights reserved.
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
 
/*
     File:       TargetConditionals.h
 
     Contains:   Autoconfiguration of TARGET_ conditionals for Mac OS X and iPhone
     
                 Note:  TargetConditionals.h in 3.4 Universal Interfaces works
                        with all compilers.  This header only recognizes compilers
                        known to run on Mac OS X.
  
*/

#ifndef __TARGETCONDITIONALS__
#define __TARGETCONDITIONALS__

/*
 *
 *  TARGET_CPU_*
 *  These conditionals specify which microprocessor instruction set is being
 *  generated.  At most one of these is true, the rest are false.
 *
 *      TARGET_CPU_PPC          - Compiler is generating PowerPC instructions for 32-bit mode
 *      TARGET_CPU_PPC64        - Compiler is generating PowerPC instructions for 64-bit mode
 *      TARGET_CPU_68K          - Compiler is generating 680x0 instructions
 *      TARGET_CPU_X86          - Compiler is generating x86 instructions for 32-bit mode
 *      TARGET_CPU_X86_64       - Compiler is generating x86 instructions for 64-bit mode
 *      TARGET_CPU_ARM          - Compiler is generating ARM instructions for 32-bit mode
 *      TARGET_CPU_ARM64        - Compiler is generating ARM instructions for 64-bit mode
 *      TARGET_CPU_MIPS         - Compiler is generating MIPS instructions
 *      TARGET_CPU_SPARC        - Compiler is generating Sparc instructions
 *      TARGET_CPU_ALPHA        - Compiler is generating Dec Alpha instructions
 */



/*
 *  TARGET_OS_*
 *
 *  These conditionals specify in which Operating System the generated code will
 *  run.  Indention is used to show which conditionals are evolutionary subclasses.
 *
 *  The MAC/WIN32/UNIX conditionals are mutually exclusive.
 *  The IOS/TV/WATCH/VISION conditionals are mutually exclusive.
 *
 *    TARGET_OS_WIN32              - Generated code will run on WIN32 API
 *    TARGET_OS_WINDOWS            - Generated code will run on Windows
 *    TARGET_OS_UNIX               - Generated code will run on some Unix (not macOS)
 *    TARGET_OS_LINUX              - Generated code will run on Linux
 *    TARGET_OS_MAC                - Generated code will run on a variant of macOS
 *      TARGET_OS_OSX                - Generated code will run on macOS
 *      TARGET_OS_IPHONE             - Generated code will run on a variant of iOS (firmware, devices, simulator)
 *        TARGET_OS_IOS                - Generated code will run on iOS
 *          TARGET_OS_MACCATALYST        - Generated code will run on macOS
 *        TARGET_OS_TV                 - Generated code will run on tvOS
 *        TARGET_OS_WATCH              - Generated code will run on watchOS
 *        TARGET_OS_VISION             - Generated code will run on visionOS
 *        TARGET_OS_BRIDGE             - Generated code will run on bridge devices
 *      TARGET_OS_SIMULATOR          - Generated code will run on an iOS, tvOS, watchOS, or visionOS simulator
 *      TARGET_OS_DRIVERKIT          - Generated code will run on macOS, iOS, tvOS, watchOS, or visionOS
 *
 *    TARGET_OS_EMBEDDED           - DEPRECATED: Use TARGET_OS_IPHONE and/or TARGET_OS_SIMULATOR instead
 *    TARGET_IPHONE_SIMULATOR      - DEPRECATED: Same as TARGET_OS_SIMULATOR
 *    TARGET_OS_NANO               - DEPRECATED: Same as TARGET_OS_WATCH
 *
 *    +--------------------------------------------------------------------------------------+
 *    |                                    TARGET_OS_MAC                                     |
 *    | +-----+ +------------------------------------------------------------+ +-----------+ |
 *    | |     | |                  TARGET_OS_IPHONE                          | |           | |
 *    | |     | | +-----------------+ +----+ +-------+ +--------+ +--------+ | |           | |
 *    | |     | | |       IOS       | |    | |       | |        | |        | | |           | |
 *    | | OSX | | | +-------------+ | | TV | | WATCH | | BRIDGE | | VISION | | | DRIVERKIT | |
 *    | |     | | | | MACCATALYST | | |    | |       | |        | |        | | |           | |
 *    | |     | | | +-------------+ | |    | |       | |        | |        | | |           | |
 *    | |     | | +-----------------+ +----+ +-------+ +--------+ +--------+ | |           | |
 *    | +-----+ +------------------------------------------------------------+ +-----------+ |
 *    +--------------------------------------------------------------------------------------+
 */

/*
 *  TARGET_RT_*
 *
 *  These conditionals specify in which runtime the generated code will
 *  run. This is needed when the OS and CPU support more than one runtime
 *  (e.g. Mac OS X supports CFM and mach-o).
 *
 *      TARGET_RT_LITTLE_ENDIAN - Generated code uses little endian format for integers
 *      TARGET_RT_BIG_ENDIAN    - Generated code uses big endian format for integers
 *      TARGET_RT_64_BIT        - Generated code uses 64-bit pointers
 *      TARGET_RT_MAC_CFM       - TARGET_OS_MAC is true and CFM68K or PowerPC CFM (TVectors) are used
 *      TARGET_RT_MAC_MACHO     - TARGET_OS_MAC is true and Mach-O/dlyd runtime is used
 */
 
/*
 * TARGET_OS conditionals can be enabled via clang preprocessor extensions:
 *
 *      __is_target_arch
 *      __is_target_vendor
 *      __is_target_os
 *      __is_target_environment
 *
 *  "-target=x86_64-apple-ios12-macabi"
 *      TARGET_OS_MAC=1
 *      TARGET_OS_IPHONE=1
 *      TARGET_OS_IOS=1
 *      TARGET_OS_MACCATALYST=1
 *
 *  "-target=x86_64-apple-ios12-simulator"
 *      TARGET_OS_MAC=1
 *      TARGET_OS_IPHONE=1
 *      TARGET_OS_IOS=1
 *      TARGET_OS_SIMULATOR=1
 *
 * DYNAMIC_TARGETS_ENABLED indicates that the core TARGET_OS macros were enabled via clang preprocessor extensions.
 * If this value is not set, the macro enablements will fall back to the static behavior.
 * It is disabled by default.
 */

#if !defined(__has_extension) || !__has_extension(define_target_os_macros)
#if defined(__has_builtin)
 #if __has_builtin(__is_target_arch)
  #if __has_builtin(__is_target_vendor)
   #if __has_builtin(__is_target_os)
    #if __has_builtin(__is_target_environment)

    /* "-target=x86_64-apple-ios12-macabi" */
    /* "-target=arm64-apple-ios12-macabi" */
    /* "-target=arm64e-apple-ios12-macabi" */
    #if (__is_target_arch(x86_64) || __is_target_arch(arm64) || __is_target_arch(arm64e)) && __is_target_vendor(apple) && __is_target_os(ios) && __is_target_environment(macabi)
        #define TARGET_OS_MAC               1
        #define TARGET_OS_IPHONE            1
        #define TARGET_OS_IOS               1
        #define TARGET_OS_MACCATALYST       1
        #define TARGET_OS_MACCATALYST            1
        #ifndef TARGET_OS_UIKITFORMAC
         #define TARGET_OS_UIKITFORMAC      1
        #endif
    #define TARGET_OS_UNIX                  0
    #define DYNAMIC_TARGETS_ENABLED         1
    #endif 

    /* "-target=x86_64-apple-ios12-simulator" */
    /* "-target=arm64-apple-ios12-simulator" */
    /* "-target=arm64e-apple-ios12-simulator" */
    #if (__is_target_arch(x86_64) || __is_target_arch(arm64) || __is_target_arch(arm64e)) && __is_target_vendor(apple) && __is_target_os(ios) && __is_target_environment(simulator)
        #define TARGET_OS_MAC               1
        #define TARGET_OS_IPHONE            1
        #define TARGET_OS_IOS               1
        #define TARGET_OS_SIMULATOR         1
        #define TARGET_OS_UNIX              0
        #define DYNAMIC_TARGETS_ENABLED     1
    #endif 



    /* "-target=arm64e-apple-xros1.0[-simulator]" */
    #if __is_target_vendor(apple) && __is_target_os(xros) && (!__is_target_environment(exclavekit) && !__is_target_environment(exclavecore))
        #define TARGET_OS_MAC               1
        #define TARGET_OS_IPHONE            1

        #if __is_target_environment(simulator)
          #define TARGET_OS_SIMULATOR        1
        #else
          #define TARGET_OS_EMBEDDED        1
        #endif
        #define TARGET_OS_VISION            1
        #define TARGET_OS_UNIX              0
        #define DYNAMIC_TARGETS_ENABLED     1
    #endif

    
    #if (__is_target_vendor(apple) && __is_target_environment(exclavecore))
        
        #define TARGET_OS_UNIX              0
        #define DYNAMIC_TARGETS_ENABLED     1
    #endif

    
    #if (__is_target_vendor(apple) && __is_target_environment(exclavekit))
        #define TARGET_OS_MAC               1
        
        #define TARGET_OS_UNIX              0
        #define DYNAMIC_TARGETS_ENABLED     1
    #endif

    /* "-target=x86_64-apple-driverkit19.0" */
    /* "-target=arm64-apple-driverkit19.0" */
    /* "-target=arm64e-apple-driverkit19.0" */
    #if __is_target_vendor(apple) && __is_target_os(driverkit)
        #define TARGET_OS_MAC               1
        #define TARGET_OS_DRIVERKIT         1
        #define TARGET_OS_UNIX              0
        #define DYNAMIC_TARGETS_ENABLED     1
    #endif

    #endif /* #if __has_builtin(__is_target_environment) */
   #endif /* #if __has_builtin(__is_target_os) */
  #endif /* #if __has_builtin(__is_target_vendor) */
 #endif /* #if __has_builtin(__is_target_arch) */
#endif /* #if defined(__has_builtin) */

#ifndef DYNAMIC_TARGETS_ENABLED
     #define DYNAMIC_TARGETS_ENABLED   0
#endif /* DYNAMIC_TARGETS_ENABLED */

/*
 *    gcc based compiler used on Mac OS X
 */
#if defined(__GNUC__) && ( defined(__APPLE_CPP__) || defined(__APPLE_CC__) || defined(__MACOS_CLASSIC__) )
    #if !DYNAMIC_TARGETS_ENABLED
        #define TARGET_OS_MAC               1
        #define TARGET_OS_OSX               1
        #define TARGET_OS_IPHONE            0

        #define TARGET_OS_IOS               0

        #define TARGET_OS_WATCH             0
        
        #define TARGET_OS_TV                0
        #define TARGET_OS_MACCATALYST       0
        #define TARGET_OS_MACCATALYST            0
        #ifndef TARGET_OS_UIKITFORMAC
         #define TARGET_OS_UIKITFORMAC      0
        #endif
        #define TARGET_OS_SIMULATOR         0
        #define TARGET_OS_EMBEDDED          0 
        #define TARGET_OS_UNIX              0
    #endif

/*
 *   CodeWarrior compiler from Metrowerks/Motorola
 */
#elif defined(__MWERKS__)
    #define TARGET_OS_MAC               1

/*
 *   unknown compiler
 */
#else
    #define TARGET_OS_MAC                1
#endif
#endif /* !defined(__has_extension) || !__has_extension(define_target_os_macros) */

// This has to always be defined in the header due to limitations in define_target_os_macros
#define TARGET_OS_RTKIT             0

/*
 *    gcc based compiler used on Mac OS X
 */
#if defined(__GNUC__) && ( defined(__APPLE_CPP__) || defined(__APPLE_CC__) || defined(__MACOS_CLASSIC__) )
    #if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
        #define TARGET_RT_LITTLE_ENDIAN 1
        #define TARGET_RT_BIG_ENDIAN    0
    #else
        #define TARGET_RT_LITTLE_ENDIAN 0
        #define TARGET_RT_BIG_ENDIAN    1
    #endif
    #if __LP64__
        #define TARGET_RT_64_BIT        1
    #else
        #define TARGET_RT_64_BIT        0
    #endif
    #if defined(__ppc__) && __MACOS_CLASSIC__
        #define TARGET_RT_MAC_CFM       1
        #define TARGET_RT_MAC_MACHO     0
    #else
        #define TARGET_RT_MAC_CFM       0
        #define TARGET_RT_MAC_MACHO     1
    #endif

/*
 *   CodeWarrior compiler from Metrowerks/Motorola
 */
#elif defined(__MWERKS__)
    #if defined(__POWERPC__)
        #define TARGET_RT_LITTLE_ENDIAN 0
        #define TARGET_RT_BIG_ENDIAN    1
    #elif defined(__INTEL__)
        #define TARGET_RT_LITTLE_ENDIAN 1
        #define TARGET_RT_BIG_ENDIAN    0
    #else
        #error unknown Metrowerks CPU type
    #endif
    #define TARGET_RT_64_BIT            0
    #ifdef __MACH__
        #define TARGET_RT_MAC_CFM       0
        #define TARGET_RT_MAC_MACHO     1
    #else
        #define TARGET_RT_MAC_CFM       1
        #define TARGET_RT_MAC_MACHO     0
    #endif

/*
 *   unknown compiler
 */
#else
    #if TARGET_CPU_PPC || TARGET_CPU_PPC64
        #define TARGET_RT_BIG_ENDIAN     1
        #define TARGET_RT_LITTLE_ENDIAN  0
    #else
        #define TARGET_RT_BIG_ENDIAN     0
        #define TARGET_RT_LITTLE_ENDIAN  1
    #endif
    #if TARGET_CPU_PPC64 || TARGET_CPU_X86_64
        #define TARGET_RT_64_BIT         1
    #else
        #define TARGET_RT_64_BIT         0
    #endif
    #ifdef __MACH__
        #define TARGET_RT_MAC_MACHO      1
        #define TARGET_RT_MAC_CFM        0
    #else
        #define TARGET_RT_MAC_MACHO      0
        #define TARGET_RT_MAC_CFM        1
    #endif
#endif

/*
 *   __is_target_arch based defines
 */
#if defined(__has_builtin) && __has_builtin(__is_target_arch)
    #if __is_target_arch(arm64)  || __is_target_arch(arm64e) || __is_target_arch(arm64_32)
        #define TARGET_CPU_ARM64        1
    #elif __is_target_arch(arm)
        #define TARGET_CPU_ARM          1
    #elif __is_target_arch(x86_64)
        #define TARGET_CPU_X86_64       1
    #elif __is_target_arch(i386)
        #define TARGET_CPU_X86          1
    #else

            #error unrecognized arch using compiler with __is_target_arch support

    #endif

/*
 *   GCC and older clang fallback
 */
#elif defined(__GNUC__) && ( defined(__APPLE_CPP__) || defined(__APPLE_CC__) || defined(__MACOS_CLASSIC__) )
    #if defined(__ppc__)
        #define TARGET_CPU_PPC          1
    #elif defined(__ppc64__)
        #define TARGET_CPU_PPC64        1
    #elif defined(__i386__)
        #define TARGET_CPU_X86          1
    #elif defined(__x86_64__)
        #define TARGET_CPU_X86_64       1
    #elif defined(__arm__)
        #define TARGET_CPU_ARM          1
    #elif defined(__arm64__)
        #define TARGET_CPU_ARM64        1
    #else
        #error unrecognized GNU C compiler
    #endif

/*
 *   CodeWarrior compiler from Metrowerks/Motorola
 */
#elif defined(__MWERKS__)
    #if defined(__POWERPC__)
        #define TARGET_CPU_PPC          1
    #elif defined(__INTEL__)
        #define TARGET_CPU_X86          1
    #else
        #error unknown Metrowerks CPU type
    #endif

/*
 *   unknown compiler
 */
#else
    #if !defined(TARGET_CPU_PPC) && !defined(TARGET_CPU_PPC64)      \
        && !defined(TARGET_CPU_X86) && !defined(TARGET_CPU_X86_64)  \
        && !defined(TARGET_CPU_ARM) && !defined(TARGET_CPU_ARM64)
        /*
            TargetConditionals.h is designed to be plug-and-play.  It auto detects
            which compiler is being run and configures the TARGET_ conditionals
            appropriately.

            The short term work around is to set the TARGET_CPU_ and TARGET_OS_
            on the command line to the compiler (e.g. -DTARGET_CPU_MIPS=1 -DTARGET_OS_UNIX=1)

            The long term solution is to add suppport for __is_target_arch and __is_target_os
            to your compiler.
        */
        #error TargetConditionals.h: unknown compiler (see comment above)
    #endif
#endif



// Make sure all TARGET_OS_* and TARGET_CPU_* values are defined
#ifndef TARGET_OS_MAC
    #define TARGET_OS_MAC        0
#endif

#ifndef TARGET_OS_OSX
    #define TARGET_OS_OSX        0
#endif

#ifndef TARGET_OS_IPHONE
    #define TARGET_OS_IPHONE     0
#endif

#ifndef TARGET_OS_IOS
    #define TARGET_OS_IOS        0
#endif

#ifndef TARGET_OS_WATCH
    #define TARGET_OS_WATCH      0
#endif

#ifndef TARGET_OS_TV
    #define TARGET_OS_TV         0
#endif

#ifndef TARGET_OS_SIMULATOR
    #define TARGET_OS_SIMULATOR  0
#endif

#ifndef TARGET_OS_EMBEDDED
    #define TARGET_OS_EMBEDDED   0
#endif

#ifndef TARGET_OS_RTKIT
    #define TARGET_OS_RTKIT      0
#endif

#ifndef TARGET_OS_MACCATALYST
    #define TARGET_OS_MACCATALYST 0
#endif

#ifndef TARGET_OS_VISION
    #define TARGET_OS_VISION     0
#endif

#ifndef TARGET_OS_UIKITFORMAC
    #define TARGET_OS_UIKITFORMAC 0
#endif

#ifndef TARGET_OS_DRIVERKIT
    #define TARGET_OS_DRIVERKIT 0
#endif 

#ifndef TARGET_OS_WIN32
    #define TARGET_OS_WIN32     0
#endif

#ifndef TARGET_OS_WINDOWS
    #define TARGET_OS_WINDOWS   0
#endif



#ifndef TARGET_OS_LINUX
    #define TARGET_OS_LINUX     0
#endif

#ifndef TARGET_CPU_PPC
    #define TARGET_CPU_PPC      0
#endif

#ifndef TARGET_CPU_PPC64
    #define TARGET_CPU_PPC64    0
#endif

#ifndef TARGET_CPU_68K
    #define TARGET_CPU_68K      0
#endif

#ifndef TARGET_CPU_X86
    #define TARGET_CPU_X86      0
#endif

#ifndef TARGET_CPU_X86_64
    #define TARGET_CPU_X86_64   0
#endif

#ifndef TARGET_CPU_ARM
    #define TARGET_CPU_ARM      0
#endif

#ifndef TARGET_CPU_ARM64
    #define TARGET_CPU_ARM64    0
#endif

#ifndef TARGET_CPU_MIPS
    #define TARGET_CPU_MIPS     0
#endif

#ifndef TARGET_CPU_SPARC
    #define TARGET_CPU_SPARC    0
#endif

#ifndef TARGET_CPU_ALPHA
    #define TARGET_CPU_ALPHA    0
#endif

#ifndef TARGET_ABI_USES_IOS_VALUES
    #define TARGET_ABI_USES_IOS_VALUES  (!TARGET_CPU_X86_64 || (TARGET_OS_IPHONE && !TARGET_OS_MACCATALYST))
#endif

#ifndef TARGET_IPHONE_SIMULATOR
    #define TARGET_IPHONE_SIMULATOR     TARGET_OS_SIMULATOR /* deprecated */
#endif

#ifndef TARGET_OS_NANO
    #define TARGET_OS_NANO              TARGET_OS_WATCH /* deprecated */
#endif



#endif  /* __TARGETCONDITIONALS__ */
