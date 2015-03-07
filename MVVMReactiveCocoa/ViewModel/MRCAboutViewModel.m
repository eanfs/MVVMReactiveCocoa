//
//  MRCAboutViewModel.m
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 15/3/4.
//  Copyright (c) 2015年 leichunfeng. All rights reserved.
//

#import "MRCAboutViewModel.h"
#import "MRCFeedbackViewModel.h"

#define kAppStoreVersionKey @"appStoreVersion"

@implementation MRCAboutViewModel

- (void)initialize {
    [super initialize];
    
    self.title = @"About";
    
    [self detectVersionUpgrade];
    
    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath *indexPath) {
        @strongify(self)
        if (indexPath.row == 3) {
            MRCFeedbackViewModel *feedbackViewModel = [[MRCFeedbackViewModel alloc] initWithServices:self.services params:nil];
            [self.services pushViewModel:feedbackViewModel animated:YES];
        }
        return [RACSignal empty];
    }];
}

- (RACSignal *)requestRemoteDataSignal {
    @weakify(self)
    return [[[self.services
        appStoreService]
        requestAppInfoFromAppStoreWithAppID:MRC_APP_ID]
        doNext:^(NSDictionary *appInfo) {
            @strongify(self)
            NSString *appStoreVersion = [appInfo[@"results"] firstObject][@"version"];
            
            [[NSUserDefaults standardUserDefaults] setValue:appStoreVersion forKey:kAppStoreVersionKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self detectVersionUpgrade];
        }];
}

- (void)detectVersionUpgrade {
    self.isLatestVersion = self.appStoreVersion ? [MRC_APP_VERSION isEqualToString:self.appStoreVersion] : YES;
}

- (NSString *)appStoreVersion {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kAppStoreVersionKey];
}

@end
