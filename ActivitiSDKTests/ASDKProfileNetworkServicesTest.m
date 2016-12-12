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

@interface ASDKProfileNetworkServicesTest : ASDKNetworkProxyBaseTest

@property (strong, nonatomic) ASDKProfileNetworkServices *profileNetworkService;

@end

@implementation ASDKProfileNetworkServicesTest

- (void)setUp {
    [super setUp];
    
    self.profileNetworkService = [ASDKProfileNetworkServices new];
    self.profileNetworkService.resultsQueue = dispatch_get_main_queue();
    self.profileNetworkService.parserOperationManager = self.parserOperationManager;
    self.profileNetworkService.servicePathFactory = [ASDKServicePathFactory new];
    
    ASDKProfileParserOperationWorker *profileParserWorker = [ASDKProfileParserOperationWorker new];
    [self.profileNetworkService.parserOperationManager registerWorker:profileParserWorker
                                                          forServices:[profileParserWorker availableServices]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatItAuthenticatesUser {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *authenticateUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, @{});
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService authenticateUser:@"test"
                                    withPassword:@"test"
                             withCompletionBlock:^(BOOL didAutheticate, NSError *error) {
                                 XCTAssertTrue(didAutheticate);
                                 XCTAssertNil(error);
                                 
                                 [authenticateUserExpectation fulfill];
                             }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesAuthenticateUserRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *authenticateUserExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
        NSUInteger successBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService authenticateUser:@"test"
                                    withPassword:@"test"
                             withCompletionBlock:^(BOOL didAutheticate, NSError *error) {
                                 XCTAssertFalse(didAutheticate);
                                 XCTAssertNotNil(error);
                                 
                                 [authenticateUserExpectation fulfill];
                             }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesProfileData {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *fetchProfileExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProfileDetailsResponse"]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService fetchProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(profile);
        
        [fetchProfileExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesFetchProfileDataRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *fetchProfileExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService fetchProfileWithCompletionBlock:^(ASDKModelProfile *profile, NSError *error) {
        XCTAssertNil(profile);
        XCTAssertNotNil(error);
        
        [fetchProfileExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

- (void)testThatItUpdatesProfile {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    ASDKModelProfile *profile = OCMClassMock([ASDKModelProfile class]);
    OCMStub([profile userFirstName]).andReturn(@"John");
    OCMStub([profile userLastName]).andReturn(@"Doe");
    OCMStub([profile email]).andReturn(@"john.doe@alfresco.com");
    OCMStub([profile companyName]).andReturn(@"Alfresco");
    
    // expect
    XCTestExpectation *updateProfileExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProfileDetailsResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService updateProfileWithModel:profile
                                       completionBlock:^(ASDKModelProfile *profile, NSError *error) {
                                           XCTAssertNil(error);
                                           XCTAssertNotNil(profile);
                                           
                                           [updateProfileExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:.5
                                 handler:nil];
}

- (void)testThatItHandlesProfileUpdateRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    ASDKModelProfile *profile = OCMClassMock([ASDKModelProfile class]);
    OCMStub([profile userFirstName]).andReturn(@"John");
    OCMStub([profile userLastName]).andReturn(@"Doe");
    OCMStub([profile email]).andReturn(@"john.doe@alfresco.com");
    OCMStub([profile companyName]).andReturn(@"Alfresco");
    
    // expect
    XCTestExpectation *updateProfileExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService updateProfileWithModel:profile
                                       completionBlock:^(ASDKModelProfile *profile, NSError *error) {
                                           XCTAssertNil(profile);
                                           XCTAssertNotNil(error);
                                           
                                           [updateProfileExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItFetchesProfileImage {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *profileImageExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
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
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService fetchProfileImageWithCompletionBlock:^(UIImage *profileImage, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(profileImage);
        
        [profileImageExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProfileImageRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    //expect
    XCTestExpectation *profileImageExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] GET:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService fetchProfileImageWithCompletionBlock:^(UIImage *profileImage, NSError *error) {
        XCTAssertNil(profileImage);
        XCTAssertNotNil(error);
        
        [profileImageExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProfilePasswordUpdate {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *profilePasswordExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, @{});
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService updateProfileWithNewPassword:@"test"
                                                 oldPassword:@"test1"
                                             completionBlock:^(BOOL isPasswordUpdated, NSError *error) {
                                                 XCTAssertTrue(isPasswordUpdated);
                                                 XCTAssertNil(error);
                                                 
                                                 [profilePasswordExpectation fulfill];
                                             }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProfilePasswordUpdateRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    
    // expect
    XCTestExpectation *profilePasswordExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger failureBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService updateProfileWithNewPassword:@"test"
                                                 oldPassword:@"test1"
                                             completionBlock:^(BOOL isPasswordUpdated, NSError *error) {
                                                 XCTAssertFalse(isPasswordUpdated);
                                                 XCTAssertNotNil(error);
                                                 
                                                 [profilePasswordExpectation fulfill];
                                             }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProfileImageUploadProgress {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:10];
    
    // expect
    XCTestExpectation *imageUploadExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^progressBlock)(NSProgress * _Nonnull uploadProgress);
        NSUInteger progressBlockParameterIdxInMethodSignature = 5;
        [invocation getArgument:&progressBlock
                        atIndex:progressBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        NSProgress *progress = [NSProgress progressWithTotalUnitCount:100];
        progress.completedUnitCount = 20;
        
        progressBlock(progress);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY constructingBodyWithBlock:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService uploadProfileImageWithModel:fileContent
                                                contentData:dummyData
                                              progressBlock:^(NSUInteger progress, NSError *error) {
                                                  XCTAssertNil(error);
                                                  XCTAssert(progress == 20);
                                                  
                                                  [imageUploadExpectation fulfill];
                                              }
                                            completionBlock:^(ASDKModelContent *profilePictureContent, NSError *error) {
                                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProfileImageUpload {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:10];
    
    // expect
    XCTestExpectation *imageUploadExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^successBlock)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject);
        NSUInteger successBlockParameterIdxInMethodSignature = 6;
        [invocation getArgument:&successBlock
                        atIndex:successBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode200OK];
        [invocation setReturnValue:&dataTask];
        
        successBlock(dataTask, [self contentDictionaryFromJSON:@"ProfileContentResponse"]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY constructingBodyWithBlock:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService uploadProfileImageWithModel:fileContent
                                                contentData:dummyData
                                              progressBlock:nil
                                            completionBlock:^(ASDKModelContent *profilePictureContent, NSError *error) {
                                                XCTAssertNil(error);
                                                XCTAssertNotNil(profilePictureContent);
                                                
                                                [imageUploadExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

- (void)testThatItHandlesProfileImageUploadRequestFailure {
    // given
    id requestOperationManager = OCMClassMock([ASDKRequestOperationManager class]);
    id fileContent = OCMClassMock([ASDKModelFileContent class]);
    NSData *dummyData = [self createRandomNSDataOfSize:10];
    
    // expect
    XCTestExpectation *imageUploadExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [[[requestOperationManager expect] andDo:^(NSInvocation *invocation) {
        void (^failureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error);
        NSUInteger failureBlockParameterIdxInMethodSignature = 7;
        [invocation getArgument:&failureBlock
                        atIndex:failureBlockParameterIdxInMethodSignature];
        NSURLSessionDataTask *dataTask = [self dataTaskWithStatusCode:ASDKHTTPCode400BadRequest];
        [invocation setReturnValue:&dataTask];
        
        failureBlock(dataTask, [self requestGenericError]);
    }] POST:OCMOCK_ANY parameters:OCMOCK_ANY constructingBodyWithBlock:OCMOCK_ANY progress:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];
    
    // when
    self.profileNetworkService.requestOperationManager = requestOperationManager;
    [self.profileNetworkService uploadProfileImageWithModel:fileContent
                                                contentData:dummyData
                                              progressBlock:nil
                                            completionBlock:^(ASDKModelContent *profilePictureContent, NSError *error) {
                                                XCTAssertNotNil(error);
                                                XCTAssertNil(profilePictureContent);
                                                
                                                [imageUploadExpectation fulfill];
                                            }];
    
    [self waitForExpectationsWithTimeout:.5f
                                 handler:nil];
}

@end
