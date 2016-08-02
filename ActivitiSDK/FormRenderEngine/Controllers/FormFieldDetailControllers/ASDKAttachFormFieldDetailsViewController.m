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

#import "ASDKAttachFormFieldDetailsViewController.h"

// Constants
#import "ASDKFormRenderEngineConstants.h"
#import "ASDKNetworkServiceConstants.h"
#import "ASDKLocalizationConstants.h"

// Categories
#import "UIColor+ASDKFormViewColors.h"
#import "UIViewController+AFAAlertAddition.h"

// Models
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldOption.h"
#import "ASDKModelFormFieldValue.h"
#import "ASDKModelContent.h"
#import "ASDKModelFormFieldAttachParameter.h"
#import "ASDKModelIntegrationAccount.h"
#import "ASDKIntegrationNetworksDataSource.h"
#import "ASDKIntegrationNodeContentRequestRepresentation.h"

// Controllers
#import "ASDKAttachFormFieldContentPickerViewController.h"
#import "ASDKIntegrationBrowsingViewController.h"

// Views
#import "ASDKNoContentView.h"

// Cells
#import "ASDKContentFileTableViewCell.h"

@interface ASDKAttachFormFieldDetailsViewController () <ASDKAttachFormFieldContentPickerViewControllerDelegate,
                                                        ASDKIntegrationBrowsingDelegate>

@property (strong, nonatomic) ASDKAttachFormFieldContentPickerViewController        *contentPickerViewController;
@property (weak, nonatomic)   IBOutlet UITableView                                  *attachedContentTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem                              *addBarButtonItem;
@property (weak, nonatomic)   IBOutlet UIView                                       *contentPickerContainer;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                           *contentPickerContainerBottomConstraint;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint                           *contentPickerContainerHeightConstraint;
@property (weak, nonatomic)   IBOutlet UIView                                       *fullScreenOverlayView;
@property (weak, nonatomic)   IBOutlet ASDKNoContentView                            *noContentView;

// Internal state properties
@property (strong, nonatomic) NSMutableSet                                          *uploadedContentIDs;
@property (strong, nonatomic) ASDKModelFormField                                    *currentFormField;
@property (strong, nonatomic) ASDKIntegrationBrowsingViewController                 *integrationBrowsingController;

@end

@implementation ASDKAttachFormFieldDetailsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.uploadedContentIDs = [NSMutableSet set];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update the navigation bar title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.currentFormField.fieldName;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Book"
                                      size:17];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    // Set up the content list table view to adjust it's size automatically
    self.attachedContentTableView.estimatedRowHeight = 61.0f;
    self.attachedContentTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self setRightBarButton];
    [self refreshContent];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.attachedContentTableView deselectRowAtIndexPath:self.attachedContentTableView.indexPathForSelectedRow
                                                 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshContent {
    // Display the no content view if appropiate
    self.noContentView.hidden = (self.currentFormField.values.count > 0) ? YES : NO;
    self.noContentView.iconImageView.image = [UIImage imageNamed:@"documents-large-icon"
                                                        inBundle:[NSBundle bundleForClass:self.class]
                                   compatibleWithTraitCollection:nil];
    
    [self setRightBarButton];
    [self.attachedContentTableView reloadData];
}

- (void)setRightBarButton {
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        [self.addBarButtonItem setEnabled:NO];
        [self.addBarButtonItem setTitle:nil];
    } else {
        UIBarButtonItem *rightBarButtonItem = nil;
        ASDKModelFormFieldAttachParameter *formFieldParameters = (ASDKModelFormFieldAttachParameter *) self.currentFormField.formFieldParams;
        if (self.currentFormField.values.count > 0 && !formFieldParameters.allowMultipleFiles) {
            rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onAdd:)];
        } else {
            rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAdd:)];
        }
        rightBarButtonItem.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
}

- (void)toggleContentPickerComponent {
    NSInteger contentPickerConstant = 0;
    if (!self.contentPickerContainerBottomConstraint.constant) {
        contentPickerConstant = -(CGRectGetHeight(self.contentPickerContainer.frame));
    }
    
    // Show the content picker container
    if (!contentPickerConstant) {
        self.contentPickerContainer.hidden = NO;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:kASDKDefaultAnimationTime
                          delay:0
         usingSpringWithDamping:.95f
          initialSpringVelocity:20.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.contentPickerContainerBottomConstraint.constant = contentPickerConstant;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (contentPickerConstant) {
                             self.contentPickerContainer.hidden = YES;
                         }
                     }];
}

- (void)toggleFullscreenOverlayView {
    CGFloat alphaValue = !self.fullScreenOverlayView.alpha ? .4f : .0f;
    if (alphaValue) {
        self.fullScreenOverlayView.hidden = NO;
    }
    
    [UIView animateWithDuration:kASDKDefaultAnimationTime animations:^{
        self.fullScreenOverlayView.alpha = alphaValue;
    } completion:^(BOOL finished) {
        if (!alphaValue) {
            self.fullScreenOverlayView.hidden = YES;
        }
    }];
}

- (IBAction)onFullscreenOverlayTap:(id)sender {
    [self toggleFullscreenOverlayView];
    [self toggleContentPickerComponent];
}

- (IBAction)onAdd:(UIBarButtonItem *)sender {
    [self toggleFullscreenOverlayView];
    [self toggleContentPickerComponent];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([kASDKSegueIDFormContentPicker isEqualToString:segue.identifier]) {
        self.contentPickerViewController = (ASDKAttachFormFieldContentPickerViewController *)segue.destinationViewController;
        self.contentPickerViewController.delegate = self;
        self.contentPickerViewController.currentFormField = self.currentFormField;
        self.contentPickerViewController.uploadedContentIDs = self.uploadedContentIDs;
    }
}

#pragma mark -
#pragma mark ASDKFormFieldDetailsControllerProtocol

- (void)setupWithFormFieldModel:(ASDKModelFormField *)formFieldModel {
    self.currentFormField = formFieldModel;
}


#pragma mark -
#pragma mark UITableView Delegate & Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.currentFormField.values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKContentFileTableViewCell *contentFileCell = [tableView dequeueReusableCellWithIdentifier:kASDKCellIDFormFieldAttachFileRepresentation];
    ASDKModelContent *currentContent = (ASDKModelContent *)self.currentFormField.values[indexPath.row];
    contentFileCell.fileTypeLabel.text = currentContent.contentName.pathExtension;
    contentFileCell.fileNameLabel.text = [currentContent.contentName stringByDeletingPathExtension];
    
    if (ASDKModelFormFieldRepresentationTypeReadOnly == self.currentFormField.representationType) {
        contentFileCell.fileNameLabel.textColor = [UIColor formViewCompletedValueColor];
    }
    
    return contentFileCell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ASDKModelContent *selectedContent = (ASDKModelContent *)self.currentFormField.values[indexPath.row];
    
    if (selectedContent.isModelContentAvailable) {
        [self.contentPickerViewController dowloadContent:selectedContent
                                      allowCachedContent:YES];
    }
    
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow
                             animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (ASDKModelFormFieldRepresentationTypeReadOnly != self.currentFormField.representationType);
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *deleteButton =
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                       title:[@"" stringByPaddingToLength:2
                                                               withString:@"\u3000"
                                                          startingAtIndex:0]
                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                         __strong typeof(self) strongSelf = weakSelf;
                                         
                                         NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.currentFormField.values];
                                         [tmpArray removeObjectAtIndex:indexPath.row];
                                         strongSelf.currentFormField.values = [tmpArray copy];
                                         
                                         // Notify the value transaction delegate there has been a change with the provided form field model
                                         if ([strongSelf.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
                                             [strongSelf.valueTransactionDelegate updatedMetadataValueForFormField:strongSelf.currentFormField
                                                                                                            inCell:nil];
                                         }
                                         
                                         [tableView reloadData];
                                         [strongSelf refreshContent];
                                     }];
    
    // Tint the image with white
    UIImage *trashIcon = [UIImage imageNamed:@"trash-icon"
                                    inBundle:[NSBundle bundleForClass:self.class]
               compatibleWithTraitCollection:nil];
    UIGraphicsBeginImageContextWithOptions(trashIcon.size, NO, trashIcon.scale);
    [[UIColor whiteColor] set];
    [trashIcon drawInRect:CGRectMake(0, 0, trashIcon.size.width, trashIcon.size.height)];
    trashIcon = UIGraphicsGetImageFromCurrentImageContext();
    
    // Draw the image and background
    CGSize rowActionSize = CGSizeMake([tableView rectForRowAtIndexPath:indexPath].size.width, [tableView rectForRowAtIndexPath:indexPath].size.height);
    UIGraphicsBeginImageContextWithOptions(rowActionSize, YES, [[UIScreen mainScreen] scale]);
    CGContextRef context=UIGraphicsGetCurrentContext();
    [[UIColor distructiveOperationBackgroundColor] set];
    CGContextFillRect(context, CGRectMake(0, 0, rowActionSize.width, rowActionSize.height));
    
    [trashIcon drawAtPoint:CGPointMake(trashIcon.size.width + trashIcon.size.width / 4.0f, rowActionSize.height / 2.0f - trashIcon.size.height / 2.0f)];
    [deleteButton setBackgroundColor:[UIColor colorWithPatternImage:UIGraphicsGetImageFromCurrentImageContext()]];
    UIGraphicsEndImageContext();
    
    return @[deleteButton];
}

#pragma mark -
#pragma mark AFAContentPickerViewController Delegate

- (void)userPickedImageAtURL:(NSURL *)imageURL {
    [self onFullscreenOverlayTap:nil];
    [self refreshContent];
}

- (void)userDidCancelImagePick {
    [self onFullscreenOverlayTap:nil];
}

- (void)pickedContentHasFinishedUploading {
    [self refreshContent];
    
    // Notify the value transaction delegate there has been a change with the provided form field model
    if ([self.valueTransactionDelegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.valueTransactionDelegate updatedMetadataValueForFormField:self.currentFormField
                                                                 inCell:nil];
    }
}

- (void)userPickedImageFromCamera {
    [self onFullscreenOverlayTap:nil];
    [self.attachedContentTableView reloadData];
    [self refreshContent];
}

- (void)pickedContentHasFinishedDownloadingAtURL:(NSURL *)downloadedFileURL {
    [self.attachedContentTableView reloadData];
    [self refreshContent];
}

- (void)contentPickerHasBeenPresentedWithNumberOfOptions:(NSUInteger)contentOptionCount
                                              cellHeight:(CGFloat)cellHeight {
    self.contentPickerContainerHeightConstraint.constant = contentOptionCount * cellHeight;
}

- (void)userPickerIntegrationAccount:(ASDKModelIntegrationAccount *)integrationAccount {
    [self onFullscreenOverlayTap:nil];
    
    // Initialize the browsing controller at a top network level based on the selected integration account
    if ([kASDKAPIServiceIDAlfrescoCloud isEqualToString:integrationAccount.integrationServiceID]) {
        ASDKIntegrationNetworksDataSource *dataSource = [[ASDKIntegrationNetworksDataSource alloc] initWithIntegrationAccount:integrationAccount];
        self.integrationBrowsingController = [[ASDKIntegrationBrowsingViewController alloc] initBrowserWithDataSource:dataSource];
        self.integrationBrowsingController.delegate = self;
    } else {
        self.integrationBrowsingController = nil;
    }
    
    // If the controller has been successfully initiated present it
    if (self.integrationBrowsingController) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.integrationBrowsingController];
        
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
}


#pragma mark -
#pragma mark ASDKIntegrationBrowsingDelegate

- (void)didPickContentNodeWithRepresentation:(ASDKIntegrationNodeContentRequestRepresentation *)nodeContentRepresentation {
    // Attach the isLink property to the content node request representation
    nodeContentRepresentation.isLink = ((ASDKModelFormFieldAttachParameter *)self.currentFormField.formFieldParams).isLinkReference;
    
    ASDKBootstrap *sdkBootstrap = [ASDKBootstrap sharedInstance];
    ASDKIntegrationNetworkServices *integrationNetworkService = [sdkBootstrap.serviceLocator serviceConformingToProtocol:@protocol(ASDKIntegrationNetworkServiceProtocol)];
    __weak typeof(self) weakSelf = self;
    [integrationNetworkService uploadIntegrationContentWithRepresentation:nodeContentRepresentation
                                                          completionBlock:^(ASDKModelContent *contentModel, NSError *error) {
                                                              __strong typeof(self) strongSelf = weakSelf;
                                                              
                                                              if (!error) {
                                                                  ASDKModelFormFieldAttachParameter *formFieldParameters = (ASDKModelFormFieldAttachParameter *)strongSelf.currentFormField.formFieldParams;
                                                                  NSMutableArray *currentValuesArray = [NSMutableArray arrayWithArray:strongSelf.currentFormField.values];
                                                                  
                                                                  if (formFieldParameters.allowMultipleFiles) {
                                                                      currentValuesArray = [NSMutableArray arrayWithArray:strongSelf.currentFormField.values];
                                                                  } else {
                                                                      currentValuesArray = [NSMutableArray new];
                                                                  }
                                                                  
                                                                  [currentValuesArray addObject:contentModel];
                                                                  strongSelf.currentFormField.values = [currentValuesArray copy];
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [weakSelf pickedContentHasFinishedUploading];
                                                                  });
                                                              } else {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      [weakSelf showGenericNetworkErrorAlertControllerWithMessage:ASDKLocalizedStringFromTable(kLocalizationFormContentPickerComponentFailedText, ASDKLocalizationTable, @"Failed title")];
                                                                  });
                                                              }
    }];
}

@end