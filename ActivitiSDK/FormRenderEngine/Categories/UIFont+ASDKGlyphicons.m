/*******************************************************************************
 * Copyright (C) 2005-2018 Alfresco Software Limited.
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

#import "UIFont+ASDKGlyphicons.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static NSString *const kFontGlyphiconsFamilyName = @"GLYPHICONS-Regular";

@implementation UIFont (ASDKGlyphicons)

+ (UIFont *)glyphiconFontWithSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:kFontGlyphiconsFamilyName
                                   size:size];
    NSAssert(font!=nil, @"Unable to load font: %@.",kFontGlyphiconsFamilyName);
    return font;
}

@end
