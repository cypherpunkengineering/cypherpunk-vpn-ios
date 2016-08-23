//
//  VPNSharedSecretReferenceGenerator.h
//  Cypherpunk
//
//  Created by KeisukeKimura on 2016/08/22.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  VPNSharedSecretReferenceGenerator : NSObject

+ (NSData *)persistentReferenceForSavedPassword:(NSString *)password
                                         forKey:(NSString *)key;

+ (NSData *)persistentReferenceForSavedIdentity:(NSData *)identityData
                                         forKey:(NSString *)key;

+ (void)addCertToKeychain:(NSData *)certInDer;

@end

