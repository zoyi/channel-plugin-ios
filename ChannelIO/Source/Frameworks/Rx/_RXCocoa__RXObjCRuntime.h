//
//  _RXObjCRuntime.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !DISABLE_SWIZZLING

/**
 ################################################################################
 This file is part of RX private API
 ################################################################################
 */

/**
 This flag controls `RELEASE` configuration behavior in case race was detecting while modifying
 ObjC runtime.

 In case this value is set to `YES`, after runtime race is detected, `abort()` will be called.
 Otherwise, only error will be reported using normal error reporting mechanism.

 In `DEBUG` mode `abort` will be always called in case race is detected.
 
 Races can't happen in case this is the only library modifying ObjC runtime, but in case there are multiple libraries
 changing ObjC runtime, race conditions can occur because there is no way to synchronize multiple libraries unaware of
 each other.

 To help remedy this situation this library will use `synchronized` on target object and it's meta-class, but
 there aren't any guarantees of how other libraries will behave.

 Default value is `NO`.

 */
extern BOOL _RXCocoa_RXAbortOnThreadingHazard;

/// Error domain for RXObjCRuntime.
extern NSString * __nonnull const _RXCocoa_RXObjCRuntimeErrorDomain;

/// `userInfo` key with additional information is interceptor probably KVO.
extern NSString * __nonnull const _RXCocoa_RXObjCRuntimeErrorIsKVOKey;

typedef NS_ENUM(NSInteger, _RXCocoa_RXObjCRuntimeError) {
    _RXCocoa_RXObjCRuntimeErrorUnknown                                           = 1,
    _RXCocoa_RXObjCRuntimeErrorObjectMessagesAlreadyBeingIntercepted             = 2,
    _RXCocoa_RXObjCRuntimeErrorSelectorNotImplemented                            = 3,
    _RXCocoa_RXObjCRuntimeErrorCantInterceptCoreFoundationTollFreeBridgedObjects = 4,
    _RXCocoa_RXObjCRuntimeErrorThreadingCollisionWithOtherInterceptionMechanism  = 5,
    _RXCocoa_RXObjCRuntimeErrorSavingOriginalForwardingMethodFailed              = 6,
    _RXCocoa_RXObjCRuntimeErrorReplacingMethodWithForwardingImplementation       = 7,
    _RXCocoa_RXObjCRuntimeErrorObservingPerformanceSensitiveMessages             = 8,
    _RXCocoa_RXObjCRuntimeErrorObservingMessagesWithUnsupportedReturnType        = 9,
};

/// Transforms normal selector into a selector with RX prefix.
SEL _Nonnull _RXCocoa_RX_selector(SEL _Nonnull selector);

/// Transforms selector into a unique pointer (because of Swift conversion rules)
void * __nonnull _RXCocoa_RX_reference_from_selector(SEL __nonnull selector);

/// Protocol that interception observers must implement.
@protocol _RXCocoa_RXMessageSentObserver

/// In case the same selector is being intercepted for a pair of base/sub classes,
/// this property will differentiate between interceptors that need to fire.
@property (nonatomic, assign, readonly) IMP __nonnull targetImplementation;

-(void)messageSentWithArguments:(NSArray* __nonnull)arguments;
-(void)methodInvokedWithArguments:(NSArray* __nonnull)arguments;

@end

/// Protocol that deallocating observer must implement.
@protocol _RXCocoa_RXDeallocatingObserver

/// In case the same selector is being intercepted for a pair of base/sub classes,
/// this property will differentiate between interceptors that need to fire.
@property (nonatomic, assign, readonly) IMP __nonnull targetImplementation;

-(void)deallocating;

@end

/// Ensures interceptor is installed on target object.
IMP __nullable _RXCocoa_RX_ensure_observing(id __nonnull target, SEL __nonnull selector, NSError *__autoreleasing __nullable * __nullable error);

#endif

/// Extracts arguments for `invocation`.
NSArray * __nonnull _RXCocoa_RX_extract_arguments(NSInvocation * __nonnull invocation);

/// Returns `YES` in case method has `void` return type.
BOOL _RXCocoa_RX_is_method_with_description_void(struct objc_method_description method);

/// Returns `YES` in case methodSignature has `void` return type.
BOOL _RXCocoa_RX_is_method_signature_void(NSMethodSignature * __nonnull methodSignature);

/// Default value for `RXInterceptionObserver.targetImplementation`.
IMP __nonnull _RXCocoa_RX_default_target_implementation(void);
