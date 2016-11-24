/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Activiti Mobile SDK.
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

#import "ASDKNetworkProxyBaseTest.h"

@interface ASDKUserNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKUserNetworkServices *userNetworkService;

@end

@implementation ASDKUserNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.userNetworkService = [ASDKUserNetworkServices new];
    self.userNetworkService.resultsQueue = dispatch_get_main_queue();
    self.userNetworkService.parserOperationManager = self.parserOperationManager;
    self.userNetworkService.servicePathFactory = [ASDKServicePathFactory new];
    
    ASDKUserParserOperationWorker *userParserWorker = [ASDKUserParserOperationWorker new];
    [self.userNetworkService.parserOperationManager registerWorker:userParserWorker
                                                       forServices:[userParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItFetchesUsers {
    // given
    id userRequestRepresentation = OCMClassMock([ASDKUserRequestRepresentation class]);
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *fetchUsersExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"UserListResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.userNetworkService.requestOperationManager = requestOperationManager;
    [self.userNetworkService fetchUsersWithUserRequestRepresentation:userRequestRepresentation
                                                     completionBlock:^(NSArray *users, NSError *error, ASDKModelPaging *paging) {
                                                         XCTAssert(users.count == 2);
                                                         XCTAssertNotNil(paging);
                                                         XCTAssertNil(error);
                                                         
                                                         [fetchUsersExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesFetchUsersRequestFailure {
    // given
    id userRequestRepresentation = OCMClassMock([ASDKUserRequestRepresentation class]);
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *fetchUsersExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [NSError errorWithDomain:@"error"
                                                   code:0
                                               userInfo:nil]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.userNetworkService.requestOperationManager = requestOperationManager;
    [self.userNetworkService fetchUsersWithUserRequestRepresentation:userRequestRepresentation
                                                     completionBlock:^(NSArray *users, NSError *error, ASDKModelPaging *paging) {
                                                         XCTAssertNil(users);
                                                         XCTAssertNil(paging);
                                                         XCTAssertNotNil(error);
                                                         
                                                         [fetchUsersExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesPictureForUser {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *fetchUserPictureExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"alfresco-icon" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        
        successBlock(dataTask, image);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.userNetworkService.requestOperationManager = requestOperationManager;
    [self.userNetworkService fetchPictureForUserID:@"id"
                                   completionBlock:^(UIImage *profileImage, NSError *error) {
                                       XCTAssertNil(error);
                                       XCTAssertNotNil(profileImage);
                                       
                                       [fetchUserPictureExpectation fulfill];
                                   }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesFetchPictureForUserRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *fetchUserPictureExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [NSError errorWithDomain:@"error"
                                                   code:0
                                               userInfo:nil]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.userNetworkService.requestOperationManager = requestOperationManager;
    [self.userNetworkService fetchPictureForUserID:@"id"
                                   completionBlock:^(UIImage *profileImage, NSError *error) {
                                       XCTAssertNotNil(error);
                                       XCTAssertNil(profileImage);
                                       
                                       [fetchUserPictureExpectation fulfill];
                                   }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end
