//
//  HTTPTools.m
//  ADSD_FinalProject
//
//  Created by Chang on 12/13/15.
//  Copyright © 2015 changcode.github.io. All rights reserved.
//

#import "HTTPTools.h"

#define REQUEST_URL    @"http://changcode.pythonanywhere.com/nearbyAPI"

@implementation HTTPTools

+ (AFHTTPRequestOperationManager *)initAFHttpManager {
    static AFHTTPRequestOperationManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer =[AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
        manager.operationQueue.maxConcurrentOperationCount = 1;
    });
    
    return manager;
}

+ (void)requestNearByPoint:(NSNumber*)distance Longitude:(NSNumber*)longitude Latitude:(NSNumber*)latitude success:(SuccessBlock)success failBlock:(FailBlock)fail {
    AFHTTPRequestOperationManager *manager = [HTTPTools initAFHttpManager];
    NSDictionary *parameters = @{@"lon": longitude, @"lat": latitude, @"dis": distance};
    [manager POST:REQUEST_URL parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        fail(operation, error);
    }];
}

@end

