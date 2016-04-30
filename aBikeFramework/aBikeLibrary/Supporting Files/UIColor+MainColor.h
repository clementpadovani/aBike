//
//  UIColor+MainColor.h
//  Velo'v
//
//  Created by Clément Padovani on 11/20/13.
//  Copyright (c) 2013 Clément Padovani. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (VEMainColor)

+ (void) ve_setupColorsCache;

+ (void) ve_stripColorsCache;

+ (UIColor *) ve_mainColor;

+ (UIColor *) ve_mainBackgroundColor;

+ (UIColor *) ve_gradientStartColor;

+ (UIColor *) ve_gradientEndColor;

+ (UIColor *) ve_shadowColor;

+ (UIColor *) ve_pagerInactiveColor;

+ (UIColor *) ve_stationNumberTextColor;

+ (UIColor *) ve_horizontalSeperatorColor;

+ (UIColor *) ve_blurTintColor;

+ (UIColor *) ve_mapViewControllerBackgroundColor;

+ (UIColor *) ve_mapViewControllerOverlayStrokeColor;

@end

NS_ASSUME_NONNULL_END
