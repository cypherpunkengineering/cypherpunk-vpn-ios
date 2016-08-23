//
//  VPNSharedSecretReferenceGenerator.m
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/22.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

#import "VPNSharedSecretReferenceGenerator.h"

@implementation VPNSharedSecretReferenceGenerator

+ (NSData *)persistentReferenceForSavedPassword:(NSString *)password
                                         forKey:(NSString *)key
{
    NSData *        result;
    NSData *        passwordData;
    OSStatus        err;
    CFTypeRef      secResult;
    
    NSParameterAssert(password != nil);
    NSParameterAssert(key != nil);
    
    result = nil;
    
    passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    err = SecItemCopyMatching( (__bridge CFDictionaryRef) @{
                                                            (__bridge id) kSecClass:                (__bridge id) kSecClassGenericPassword,
                                                            (__bridge id) kSecAttrService:          key,
                                                            (__bridge id) kSecAttrAccount:          key,
                                                            (__bridge id) kSecReturnPersistentRef:  @YES,
                                                            (__bridge id) kSecReturnData:          @YES
                                                            }, &secResult);
    if (err == errSecSuccess) {
        NSDictionary *  resultDict;
        NSData *        currentPasswordData;
        
        resultDict = CFBridgingRelease( secResult );
        assert([resultDict isKindOfClass:[NSDictionary class]]);
        
        result = resultDict[ (__bridge NSString *) kSecValuePersistentRef ];
        assert([result isKindOfClass:[NSData class]]);
        
        currentPasswordData = resultDict[ (__bridge NSString *) kSecValueData ];
        assert([currentPasswordData isKindOfClass:[NSData class]]);
        
        if ( ! [passwordData isEqual:currentPasswordData] ) {
            err = SecItemUpdate( (__bridge CFDictionaryRef) @{
                                                              (__bridge id) kSecClass:        (__bridge id) kSecClassGenericPassword,
                                                              (__bridge id) kSecAttrService:  key,
                                                              (__bridge id) kSecAttrAccount:  key,
                                                              }, (__bridge CFDictionaryRef) @{
                                                                                              (__bridge id) kSecValueData:    passwordData
                                                                                              } );
            if (err != errSecSuccess) {
                NSLog(@"Error %d saving password (SecItemUpdate)", (int) err);
                result = nil;
            }
        }
    } else if (err == errSecItemNotFound) {
        err = SecItemAdd( (__bridge CFDictionaryRef) @{
                                                       (__bridge id) kSecClass:                (__bridge id) kSecClassGenericPassword,
                                                       (__bridge id) kSecAttrService:          key,
                                                       (__bridge id) kSecAttrAccount:          key,
                                                       (__bridge id) kSecValueData:            passwordData,
                                                       (__bridge id) kSecReturnPersistentRef:  @YES
                                                       }, &secResult);
        if (err == errSecSuccess) {
            result = CFBridgingRelease( secResult );
            assert([result isKindOfClass:[NSData class]]);
        } else {  
            NSLog(@"Error %d saving password (SecItemAdd)", (int) err);  
        }  
    } else {  
        NSLog(@"Error %d saving password (SecItemCopyMatching)", (int) err);  
    }  
    return result;  
}

+ (NSData *)persistentReferenceForSavedIdentity:(NSData *)identityData
                                         forKey:(NSString *)key
{
    NSData *        result;
    OSStatus        err;
    CFTypeRef      secResult;
    
    NSParameterAssert(identityData != nil);
    NSParameterAssert(key != nil);
    
    result = nil;
    
    err = SecItemCopyMatching( (__bridge CFDictionaryRef) @{
                                                            (__bridge id) kSecClass:                (__bridge id) kSecClassIdentity,
                                                            (__bridge id) kSecAttrService:          key,
                                                            (__bridge id) kSecAttrAccount:          key,
                                                            (__bridge id) kSecReturnPersistentRef:  @YES,
                                                            (__bridge id) kSecReturnData:          @YES
                                                            }, &secResult);
    if (err == errSecSuccess) {
        NSDictionary *  resultDict;
        NSData *        currentIdentityData;
        
        resultDict = CFBridgingRelease( secResult );
        assert([resultDict isKindOfClass:[NSDictionary class]]);
        
        result = resultDict[ (__bridge NSString *) kSecValuePersistentRef ];
        assert([result isKindOfClass:[NSData class]]);
        
        currentIdentityData = resultDict[ (__bridge NSString *) kSecValueData ];
        assert([currentIdentityData isKindOfClass:[NSData class]]);
        
        if ( ! [identityData isEqual:currentIdentityData] ) {
            err = SecItemUpdate( (__bridge CFDictionaryRef) @{
                                                              (__bridge id) kSecClass:        (__bridge id) kSecClassIdentity,
                                                              (__bridge id) kSecAttrService:  key,
                                                              (__bridge id) kSecAttrAccount:  key,
                                                              }, (__bridge CFDictionaryRef) @{
                                                                                              (__bridge id) kSecValueData:    identityData
                                                                                              } );
            if (err != errSecSuccess) {
                NSLog(@"Error %d saving password (SecItemUpdate)", (int) err);
                result = nil;
            }
        }
    } else if (err == errSecItemNotFound) {
        err = SecItemAdd( (__bridge CFDictionaryRef) @{
                                                       (__bridge id) kSecClass:                (__bridge id) kSecClassIdentity,
                                                       (__bridge id) kSecAttrService:          key,
                                                       (__bridge id) kSecAttrAccount:          key,
                                                       (__bridge id) kSecValueData:            identityData,
                                                       (__bridge id) kSecReturnPersistentRef:  @YES
                                                       }, &secResult);
        if (err == errSecSuccess) {
            result = CFBridgingRelease( secResult );
            assert([result isKindOfClass:[NSData class]]);
        } else {
            NSLog(@"Error %d saving password (SecItemAdd)", (int) err);
        }
    } else {
        NSLog(@"Error %d saving password (SecItemCopyMatching)", (int) err);
    }
    return result;
}

+ (void)addCertToKeychain:(NSData *)rootCertData
{
    OSStatus err = noErr;
    SecCertificateRef rootCert = SecCertificateCreateWithData(kCFAllocatorDefault, (CFDataRef) rootCertData);
    
    CFTypeRef result;
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          (id)kSecClassCertificate, kSecClass,
                          rootCert, kSecValueRef,
                          nil];
    
    err = SecItemAdd((CFDictionaryRef)dict, &result);
    
    if( err == noErr) {
        NSLog(@"Install root certificate success");
    } else if( err == errSecDuplicateItem ) {
        NSLog(@"duplicate root certificate entry");
    } else {
        NSLog(@"install root certificate failure");
    }}

@end