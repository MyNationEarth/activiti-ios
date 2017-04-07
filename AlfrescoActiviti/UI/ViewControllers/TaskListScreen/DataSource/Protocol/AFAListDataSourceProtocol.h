/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile iOS App.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import <Foundation/Foundation.h>
@import ActivitiSDK;

@class AFAFilterViewController, AFAGenericFilterModel;
@protocol AFAListDataSourceProtocol;

typedef void (^AFAListHandleCompletionBlock) (id<AFAListDataSourceProtocol>dataSource, NSArray *objectList, NSError *error, ASDKModelPaging *paging);

@protocol AFAListDataSourceProtocol <NSObject, UITableViewDataSource>

@property (strong, nonatomic, readonly) NSArray *dataEntries;

- (instancetype)initWithDataEntries:(NSArray *)dataEntries
                         themeColor:(UIColor *)themeColor;
- (void)loadFilterListForController:(AFAFilterViewController *)filterController;
- (void)loadContentListForFilter:(AFAGenericFilterModel *)filter
             withCompletionBlock:(AFAListHandleCompletionBlock)completionBlock;
- (void)processAdditionalEntries:(NSArray *)additionalEntriesArr
                       forPaging:(ASDKModelPaging *)paging;

@end
