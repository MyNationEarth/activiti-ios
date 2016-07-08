/*******************************************************************************
 * Copyright (C) 2005-2016 Alfresco Software Limited.
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

@import Foundation;
@import UIKit;
#import "ASDKFormControllerNavigationProtocol.h"

@class ASDKModelFormDescription,
ASDKModelTask,
ASDKModelProcessDefinition,
ASDKModelProcessInstance,
ASDKFormEngineActionHandler;

typedef void  (^AFAFormServicesEngineSetupCompletionBlock) (UICollectionViewController<ASDKFormControllerNavigationProtocol> *formController, NSError *error);
typedef void  (^AFAFormServicesEngineCompletionBlock)      (BOOL isFormCompleted, NSError *error);
typedef void  (^AFAFormServicesEngineSaveBlock)            (BOOL isFormSaved, NSError *error);
typedef void  (^AFAStartFormServicesEngineCompletionBlock) (ASDKModelProcessInstance *processInstance, NSError *error);

@interface AFAFormServices : NSObject

/**
 *  Performs a request to the form render engine to handle the creation of the form view
 *  given a task object, including all necessary network calls for setup and
 *  completion of the form.
 *
 *  @param task                     Task object containing the mandatory task ID property
 *  @param renderCompletionBlock    Completion block providing a form controller containing
 *                                  the visual representation of the form view and additional
 *                                  error reasons
 *  @param formCompletionBlock      Completion block providing information on
 *                                  whether the form has been successfully
 *                                  completed  or not and an additional error reason
 *  @param formSaveBlock            Save completion block providing information on
 *                                  whether the form has been successfully saved or
 *                                  not and an additional error reason
 */
- (void)requestSetupWithTaskModel:(ASDKModelTask *)task
            renderCompletionBlock:(AFAFormServicesEngineSetupCompletionBlock)renderCompletionBlock
              formCompletionBlock:(AFAFormServicesEngineCompletionBlock)formCompletionBlock
                    formSaveBlock:(AFAFormServicesEngineSaveBlock)formSaveBlock;

/**
 *  Performs a request to the form render engine to handle the creation of the form view
 *  given a process definition object, including all the necessary network calls for setup
 *  and completion of the form.
 *
 *  @param processDefinition     Process definition object containing the mandatory process definition
 *                               ID property
 *  @param renderCompletionBlock Completion block providing a form controller containing
 *                               the visual representation of the form view and additional
 *                               error reasons
 *  @param formCompletionBlock   Completion block providing information on
 *                               whether the form has been successfully
 *                               completed  or not and an additional error reason
 */
- (void)requestSetupWithProcessDefinition:(ASDKModelProcessDefinition *)processDefinition
                    renderCompletionBlock:(AFAFormServicesEngineSetupCompletionBlock)renderCompletionBlock
                      formCompletionBlock:(AFAStartFormServicesEngineCompletionBlock)formCompletionBlock;

/**
 *  Requests the form engine action handler object. See the SDK description for more details.
 *
 *  @return Form engine action handler object
 */
- (ASDKFormEngineActionHandler *)formEngineActionHandler;

/**
 *  Performs a request to the form render engine to cleanup itself and prepare for reuse
 */
- (void)requestEngineCleanup;

@end
