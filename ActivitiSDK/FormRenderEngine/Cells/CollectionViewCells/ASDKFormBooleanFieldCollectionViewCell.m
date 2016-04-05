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

#import "ASDKFormBooleanFieldCollectionViewCell.h"
#import "ASDKModelFormField.h"
#import "ASDKModelFormFieldValue.h"
#import "UIColor+ASDKFormViewColors.h"
#import "ASDKFormRenderEngineConstants.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface ASDKFormBooleanFieldCollectionViewCell ()

@property (strong, nonatomic) ASDKModelFormField    *formField;
@property (assign, nonatomic) BOOL                  isRequired;

@end

@implementation ASDKFormBooleanFieldCollectionViewCell

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // Adjust the cell sizing parameters by constraining with a high priority on the horizontal axis
    // and a lower priority on the vertical axis
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    attributes.size = CGSizeMake(layoutAttributes.size.width, attributes.size.height);
    return attributes;
}

#pragma mark -
#pragma mark ASDKFormCellProtocol

- (void)setupCellWithFormField:(ASDKModelFormField *)formField {
    self.formField = formField;
    self.descriptionLabel.text = formField.fieldName;
    
    // If dealing with a read-only representation then disable the boolean field
    // and copy the user-filled value
    if (ASDKModelFormFieldRepresentationTypeReadOnly == formField.representationType) {
        self.booleanField.on = [formField.values.firstObject boolValue];
        self.booleanField.enabled = NO;
    } else {
        self.isRequired = formField.isRequired;
        self.booleanField.enabled = !formField.isReadOnly;
        
        // Check for any existing metadata value that might have been attached to the form
        // field object. If present, populate the text field with it
        if (self.formField.metadataValue) {
            self.booleanField.on = [self.formField.metadataValue.attachedValue isEqualToString:kASDKFormFieldTrueStringValue] ? YES : NO;
        } else if (formField.values) {
            self.booleanField.on = [formField.values.firstObject boolValue];
        } else {
            self.booleanField.on = NO;
        }
        
        [self validateCellStateForSwitchState:self.booleanField.on];
    }
}

- (IBAction)switchToggled:(id)sender {
    UISwitch *checkboxSwitch = (UISwitch *)sender;
    
    self.formField.metadataValue = [ASDKModelFormFieldValue new];
    self.formField.metadataValue.attachedValue = [checkboxSwitch isOn] ? kASDKFormFieldTrueStringValue : kASDKFormFieldFalseStringValue;
    
    if ([self.delegate respondsToSelector:@selector(updatedMetadataValueForFormField:inCell:)]) {
        [self.delegate updatedMetadataValueForFormField:self.formField
                                                 inCell:self];
    }
}


#pragma mark -
#pragma mark Cell states & validation

- (void)prepareForReuse {
    self.descriptionLabel.text = nil;
    self.descriptionLabel.textColor = [UIColor formViewValidValueColor];
    self.booleanField.selected = NO;
}

- (void)markCellValueAsInvalid {
    self.descriptionLabel.textColor = [UIColor formViewInvalidValueColor];
}

- (void)markCellValueAsValid {
    self.descriptionLabel.textColor = [UIColor formViewValidValueColor];
}

- (void)validateCellStateForSwitchState:(BOOL)on {
    // Check input in relation to the requirement of the field
    if (self.isRequired) {
        if (!on) {
            [self markCellValueAsInvalid];
        } else {
            [self markCellValueAsValid];
        }
    }
}


@end