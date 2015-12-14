//
//  HTTPTools.h
//  ADSD_FinalProject
//
//  Created by Chang on 12/13/15.
//  Copyright © 2015 changcode.github.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void(^SuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void(^FailBlock) (AFHTTPRequestOperation *operation, NSError *error);

@interface HTTPTools : NSObject

+ (void)requestNearByPoint:(NSNumber*)distance Longitude:(NSNumber*)longitude Latitude:(NSNumber*)latitude success:(SuccessBlock)success failBlock:(FailBlock)fail;

@end
