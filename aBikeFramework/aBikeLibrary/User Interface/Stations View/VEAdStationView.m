//
//  VEAdStationView.m
//  aBikeLibrary
//
//  Created by Clément Padovani on 9/11/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "VEAdStationView.h"

#import "VEConsul.h"

#import "NSBundle+VELibrary.h"

#import "UIColor+MainColor.h"

#import "VEAlertManager.h"

@import StoreKit;

@import AudioToolbox;

static VEAdStationView *_sharedAdStationView = nil;

@interface VEAdStationView () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, weak) UILabel *adRemoverTitleLabel;

@property (nonatomic, weak) UILabel *adRemoverDescriptionLabel;

@property (nonatomic, weak) UILabel *disabledPurchasesLabel;

@property (nonatomic) BOOL purchasesAreDisabled;

@property (nonatomic, weak) UIButton *adRemoverBuyButton;

@property (nonatomic, weak) UIButton *adRemoverRestoreButton;

@property (nonatomic, weak) UIActivityIndicatorView *buySpinner;

@property (nonatomic, weak) UIActivityIndicatorView *restoreSpinner;

@property (nonatomic, strong) SKProductsRequest *productRequest;

@property (nonatomic, strong) SKProduct *adRemover;

@property (nonatomic, assign) BOOL hasSetupConstraints;

- (void) setupLabels;

- (void) setupButtons;

- (void) setupSpinners;

- (void) loadProducts;

- (void) doBuyAdRemover;

- (void) doRestoreAdRemover;

- (void) handleProductsResponse: (SKProductsResponse *) response;

- (void) showAlertForError: (NSError *) anError;

- (void) appWillReOpen: (NSNotification *) notification;

- (void) contentSizeDidChange: (NSNotification *) notification;

@end

@implementation VEAdStationView

+ (VEAdStationView *) sharedAdStationView
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedAdStationView = [[self alloc] init];
	});
	
	return _sharedAdStationView;
}

+ (void) tearDownAdStationView
{
	CPLog(@"tear down");
	
	_sharedAdStationView = nil;
}

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		[self setBackgroundColor: [UIColor clearColor]];
		
		[self setTranslatesAutoresizingMaskIntoConstraints: NO];
		
		[self setupLabels];
		
		[self setupButtons];
		
		[self setupSpinners];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appWillReOpen:) name: UIApplicationWillEnterForegroundNotification object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(contentSizeDidChange:) name: UIContentSizeCategoryDidChangeNotification object: nil];
		
		[[SKPaymentQueue defaultQueue] addTransactionObserver: self];
	}
	
	return self;
}

- (void) setupLabels
{
	UILabel *adRemoverTitleLabel = [[UILabel alloc] init];
	
	[adRemoverTitleLabel setFont: [self titleFont]];
	
	[adRemoverTitleLabel setText: CPLocalizedString(@"Loading…", @"VEAdStationView_loading_iap")];
	
	[adRemoverTitleLabel setTextColor: [UIColor ve_mainColor]];
	
	[adRemoverTitleLabel setAdjustsFontSizeToFitWidth: YES];
	
	[adRemoverTitleLabel setMinimumScaleFactor: .5];
	
	//[adRemoverTitleLabel setBackgroundColor: [UIColor purpleColor]];
	
//	[adRemoverTitleLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];

	[adRemoverTitleLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UILabel *adRemoverDescriptionLabel = [[UILabel alloc] init];
	
	[adRemoverDescriptionLabel setFont: [self descriptionFont]];
	
	[adRemoverDescriptionLabel setTextColor: [UIColor ve_stationNumberTextColor]];
	
	[adRemoverDescriptionLabel setText: CPLocalizedString(@"Loading…", @"VEAdStationView_loading_iap")];
		
	[adRemoverDescriptionLabel setAdjustsFontSizeToFitWidth: YES];
	
	[adRemoverDescriptionLabel setPreferredMaxLayoutWidth: 190];
	
	[adRemoverDescriptionLabel setMinimumScaleFactor: .3f];
	
	[adRemoverDescriptionLabel setNumberOfLines: 3];
	
	[adRemoverDescriptionLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	//[adRemoverDescriptionLabel setBackgroundColor: [UIColor greenColor]];
	
	UILabel *disabledPurchasesLabel = [[UILabel alloc] init];
	
	[disabledPurchasesLabel setFont: [self disabledFont]];
	
	[disabledPurchasesLabel setTextColor: [UIColor ve_disabledTextColor]];
	
	[disabledPurchasesLabel setText: @""];
	
	[disabledPurchasesLabel setTextAlignment: NSTextAlignmentCenter];
	
	[disabledPurchasesLabel setAdjustsFontSizeToFitWidth: YES];
	
	[disabledPurchasesLabel setMinimumScaleFactor: .7f];
	
	[disabledPurchasesLabel setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisVertical];
	
	[disabledPurchasesLabel setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[self addSubview: adRemoverTitleLabel];
	
	[self addSubview: adRemoverDescriptionLabel];
	
	[self addSubview: disabledPurchasesLabel];

	[self setAdRemoverTitleLabel: adRemoverTitleLabel];
	
	[self setAdRemoverDescriptionLabel: adRemoverDescriptionLabel];
	
	[self setDisabledPurchasesLabel: disabledPurchasesLabel];
}

- (void) setupButtons
{
	UIButton *adRemoverBuyButton = [UIButton buttonWithType: UIButtonTypeSystem];
	
	[adRemoverBuyButton setTitle: @"" forState: UIControlStateNormal];
	
	[adRemoverBuyButton setEnabled: NO];
	
	[adRemoverBuyButton addTarget: self action: @selector(doBuyAdRemover) forControlEvents: UIControlEventTouchUpInside];
	
	[adRemoverBuyButton setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UIButton *adRemoverRestoreButton = [UIButton buttonWithType: UIButtonTypeSystem];
	
//	[adRemoverRestoreButton setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisHorizontal];

	[adRemoverRestoreButton setTitle: @"" forState: UIControlStateNormal];
	
	[adRemoverRestoreButton setEnabled: NO];
	
	[adRemoverRestoreButton addTarget: self action: @selector(doRestoreAdRemover) forControlEvents: UIControlEventTouchUpInside];
	
	[adRemoverRestoreButton setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[self addSubview: adRemoverBuyButton];
	
	[self addSubview: adRemoverRestoreButton];
	
	[self setAdRemoverBuyButton: adRemoverBuyButton];
	
	[self setAdRemoverRestoreButton: adRemoverRestoreButton];
}

- (void) setupSpinners
{
	UIActivityIndicatorView *buySpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];

	[buySpinner setHidesWhenStopped: YES];
	
	//[buySpinner stopAnimating];
	
	[buySpinner startAnimating];
	
	[buySpinner setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	UIActivityIndicatorView *restoreSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
	
	[restoreSpinner setHidesWhenStopped: YES];
	
	//[restoreSpinner stopAnimating];
	
	[restoreSpinner startAnimating];
	
	[restoreSpinner setTranslatesAutoresizingMaskIntoConstraints: NO];
	
	[self addSubview: buySpinner];
	
	[self addSubview: restoreSpinner];
	
	[self setBuySpinner: buySpinner];
	
	[self setRestoreSpinner: restoreSpinner];
}

- (void) setupConstraints
{
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_adRemoverTitleLabel,
													   _adRemoverDescriptionLabel,
													   _adRemoverBuyButton,
													   _adRemoverRestoreButton,
													   _buySpinner,
													   _restoreSpinner);

	NSDictionary *metricsDictionary = nil;

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-15-[_adRemoverTitleLabel]-(>=0)-[_adRemoverBuyButton]-15-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self adRemoverTitleLabel]
											attribute: NSLayoutAttributeCenterY
											relatedBy: NSLayoutRelationEqual
											   toItem: [self adRemoverBuyButton]
											attribute: NSLayoutAttributeCenterY
										    multiplier: 1
											 constant: 0]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-15-[_adRemoverBuyButton]-10-[_adRemoverRestoreButton]-(>=0)-|"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self adRemoverDescriptionLabel]
											attribute: NSLayoutAttributeLeft
											relatedBy: NSLayoutRelationEqual
											   toItem: [self adRemoverTitleLabel]
											attribute: NSLayoutAttributeLeft
										    multiplier: 1
											 constant: 0]];

	[self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:[_adRemoverTitleLabel]-5-[_adRemoverDescriptionLabel]"
													  options: 0
													  metrics: metricsDictionary
													    views: viewsDictionary]];

	[self addConstraint: [NSLayoutConstraint constraintWithItem: [self adRemoverBuyButton]
											attribute: NSLayoutAttributeRight
											relatedBy: NSLayoutRelationEqual
											   toItem: [self adRemoverRestoreButton]
											attribute: NSLayoutAttributeRight
										    multiplier: 1
											 constant: 0]];

	void (^addSpinnerConstraints)(UIActivityIndicatorView *spinnerView, UIButton *button) = ^(UIActivityIndicatorView *spinnerView, UIButton *button){


		for (NSNumber *anAttribute in @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeHeight)])
		{
			NSLayoutAttribute theAttribute = (NSLayoutAttribute) [anAttribute integerValue];

			[self addConstraint: [NSLayoutConstraint constraintWithItem: spinnerView
													attribute: theAttribute
													relatedBy: NSLayoutRelationEqual
													   toItem: button
													attribute: theAttribute
												    multiplier: 1
													 constant: 0]];
		}

	};


	addSpinnerConstraints([self buySpinner], [self adRemoverBuyButton]);

	addSpinnerConstraints([self restoreSpinner], [self adRemoverRestoreButton]);

}

//- (void) setupConstraints
//{
//	NSDictionary *viewsDictionary = @{@"_adRemoverTitleLabel" : [self adRemoverTitleLabel],
//							    @"_adRemoverDescriptionLabel" : [self adRemoverDescriptionLabel],
//							    @"_disabledPurchasesLabel" : [self disabledPurchasesLabel],
//							    @"_adRemoverBuyButton" : [self adRemoverBuyButton],
//							    @"_adRemoverRestoreButton" : [self adRemoverRestoreButton],
//							    @"_buySpinner" : [self buySpinner],
//							    @"_restoreSpinner" : [self restoreSpinner]};
//	
//	NSDictionary *metricsDictionary = @{@"leftPadding" : @(15),
//								 @"rightPadding" : @(15),
//								 @"topPadding" : @(15),
//								 @"bottomPadding" : @(35),
//								 @"titleDescriptionMinimumVerticalPadding" : @(5),
//								 @"titleDescriptionMaximumVerticalPadding" : @(25),
//								 @"labelButtonMinimumPadding" : @(40),
//								 @"labelButtonMaximumPadding" : @(60),
//								 @"descriptionDisabledMinimumVerticalPadding" : @(15)};
//	
//	NSArray *titleLabelBuyButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-(==leftPadding)-[_adRemoverTitleLabel]-(>=labelButtonMinimumPadding)-[_adRemoverBuyButton]-(==rightPadding)-|"
//																			  options: NSLayoutFormatAlignAllCenterY
//																			  metrics: metricsDictionary
//																			    views: viewsDictionary];
//	
//	[self addConstraints: titleLabelBuyButtonHorizontalConstraints];
//	
//	NSArray *descriptionLabelRestoreButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-(==leftPadding)-[_adRemoverDescriptionLabel]-(>=labelButtonMinimumPadding,<=labelButtonMaximumPadding)-[_adRemoverRestoreButton]-(==rightPadding)-|"
//																					  options: NSLayoutFormatAlignAllCenterY
//																					  metrics: metricsDictionary
//																					    views: viewsDictionary];
//	
//	[self addConstraints: descriptionLabelRestoreButtonHorizontalConstraints];
//
//	NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-topPadding-[_adRemoverTitleLabel]-titleDescriptionMinimumVerticalPadding-[_adRemoverDescriptionLabel]-(>=descriptionDisabledMinimumVerticalPadding@1000)-[_disabledPurchasesLabel]-bottomPadding-|"
//															 options: 0
//															 metrics: metricsDictionary
//															   views: viewsDictionary];
//
//	[self addConstraints: verticalConstraints];
//	
//	NSArray *disabledPurchasesLabelHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-leftPadding-[_disabledPurchasesLabel]-rightPadding-|"
//																				options: 0
//																				metrics: metricsDictionary
//																				  views: viewsDictionary];
//	
//	[self addConstraints: disabledPurchasesLabelHorizontalConstraints];
//	
//	NSLayoutConstraint *buySpinnerHorizontalConstraint = [NSLayoutConstraint constraintWithItem: [self buySpinner]
//																	  attribute: NSLayoutAttributeCenterX
//																	  relatedBy: NSLayoutRelationEqual
//																		toItem: [self adRemoverBuyButton]
//																	  attribute: NSLayoutAttributeCenterX
//																	 multiplier: 1
//																	   constant: 0];
//	
//	[self addConstraint: buySpinnerHorizontalConstraint];
//	
//	NSLayoutConstraint *buySpinnerVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self buySpinner]
//																	attribute: NSLayoutAttributeCenterY
//																	relatedBy: NSLayoutRelationEqual
//																	   toItem: [self adRemoverBuyButton]
//																	attribute: NSLayoutAttributeCenterY
//																    multiplier: 1
//																	 constant: 0];
//	
//	[self addConstraint: buySpinnerVerticalConstraint];
//	
////	NSLayoutConstraint *buySpinnerHeightConstraint = [NSLayoutConstraint constraintWithItem: [self buySpinner]
////																   attribute: NSLayoutAttributeHeight
////																   relatedBy: NSLayoutRelationEqual
////																	 toItem: [self adRemoverBuyButton]
////																   attribute: NSLayoutAttributeHeight
////																  multiplier: 1
////																    constant: 0];
////	
////	[self addConstraint: buySpinnerHeightConstraint];
//	
//	NSLayoutConstraint *restoreSpinnerHorizontalConstraint = [NSLayoutConstraint constraintWithItem: [self restoreSpinner]
//																		 attribute: NSLayoutAttributeCenterX
//																		 relatedBy: NSLayoutRelationEqual
//																		    toItem: [self adRemoverRestoreButton]
//																		 attribute: NSLayoutAttributeCenterX
//																		multiplier: 1
//																		  constant: 0];
//	
//	[self addConstraint: restoreSpinnerHorizontalConstraint];
//	
//	NSLayoutConstraint *restoreSpinnerVerticalConstraint = [NSLayoutConstraint constraintWithItem: [self restoreSpinner]
//																	    attribute: NSLayoutAttributeCenterY
//																	    relatedBy: NSLayoutRelationEqual
//																		  toItem: [self adRemoverRestoreButton]
//																	    attribute: NSLayoutAttributeCenterY
//																	   multiplier: 1
//																		constant: 0];
//	
//	[self addConstraint: restoreSpinnerVerticalConstraint];
//	
////	NSLayoutConstraint *restoreSpinnerHeightConstraint = [NSLayoutConstraint constraintWithItem: [self restoreSpinner]
////																	  attribute: NSLayoutAttributeHeight
////																	  relatedBy: NSLayoutRelationEqual
////																		toItem: [self adRemoverRestoreButton]
////																	  attribute: NSLayoutAttributeHeight
////																	 multiplier: 1
////																	   constant: 0];
////	
////	[self addConstraint: restoreSpinnerHeightConstraint];
//
//}

- (void) loadProducts
{
	[[VEConsul sharedConsul] startLoadingSpinner];
	
	//CPLog(@"indentifier: %@", [NSBundle adRemoverProductIdentifier]);
	
	NSSet *productIdentifier = [NSSet setWithObject: [NSBundle ve_adRemoverProductIdentifier]];
	
	SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifier];
	
	[productsRequest setDelegate: self];
	
	[productsRequest start];
	
	[self setProductRequest: productsRequest];
}

- (void) canLoad
{
	//CPLog(@"can load");
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		[self loadProducts];
		
	});
}

- (void) doBuyAdRemover
{
	CPLog(@"do buy");
	
	CPLog(@"buying: %@", [[self adRemover] productIdentifier]);
	
	[[self adRemoverBuyButton] setEnabled: NO];
	
	[[self adRemoverRestoreButton] setEnabled: NO];
	
	[[self adRemoverBuyButton] setHidden: YES];
	
	[[self buySpinner] startAnimating];

	[[VEConsul sharedConsul] startLoadingSpinner];
	
	SKPayment *productPayment = [SKPayment paymentWithProduct: [self adRemover]];
	
#if kEnableCrashlytics
	[Answers logAddToCartWithPrice: [[self adRemover] price]
					  currency: [[[self adRemover] priceLocale] objectForKey: NSLocaleCurrencyCode]
					  itemName: @"Ad Remover"
					  itemType: nil
					    itemId: [[self adRemover] productIdentifier]
			    customAttributes: nil];
#endif
	
	[[SKPaymentQueue defaultQueue] addPayment: productPayment];
}

- (void) doRestoreAdRemover
{
	CPLog(@"do restore");

#if kEnableCrashlytics
	
	[Answers logCustomEventWithName: @"Do Restore Ad Remover"
				customAttributes: nil];
	
#endif

	
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	
	[[self adRemoverBuyButton] setEnabled: NO];
	
	[[self adRemoverRestoreButton] setEnabled: NO];
	
	[[self adRemoverRestoreButton] setHidden: YES];
	
	[[self restoreSpinner] startAnimating];
}

- (void) handleProductsResponse: (SKProductsResponse *) response
{
	NSArray *failed = [response invalidProductIdentifiers];
	
	if ([failed count])
	{
		CPLog(@"failed products: %@", failed);
	}
	
	NSArray *products = [response products];
	
	if (![products count])
	{
		CPLog(@"nil products");
	
		[self handleNoProductWithFailed: failed];
		
		return;
	}
	
	//CPLog(@"products: %@", products);
	
	//CPLog(@"populate");
	
	SKProduct *adRemover = [products firstObject];
	
	[self setAdRemover: adRemover];
	
	[self populateData];
}

- (void) handleNoProductWithFailed: (NSArray *) failedProducts
{
	
	#if kEnableCrashlytics
	
		if (failedProducts)
		{
			NSDictionary *failedProductsDictionary = @{@"Failed Products" : [failedProducts description]};
	
			[Answers logCustomEventWithName: @"Failed products"
						customAttributes: failedProductsDictionary];
		}
	
	#endif
	
	[[self buySpinner] stopAnimating];
	
	[[self restoreSpinner] stopAnimating];
	
	[[self adRemoverTitleLabel] setText: CPLocalizedString(@"Failed to load product", @"VEAdStationView_load_failed_title")];
	
	[[self adRemoverDescriptionLabel] setText: CPLocalizedString(@"An error occured while loading the ad remover.", @"VEAdStationView_load_failed_description")];
}

- (void) populateData
{
	[[self buySpinner] stopAnimating];
	
	[[self restoreSpinner] stopAnimating];
	
	[[self adRemoverTitleLabel] setText: [[self adRemover] localizedTitle]];
	
	[[self adRemoverDescriptionLabel] setText: [[self adRemover] localizedDescription]];
	
	NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
	
	[currencyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	
	[currencyFormatter setLocale: [[self adRemover] priceLocale]];
	
	NSString *priceString = [currencyFormatter stringFromNumber: [[self adRemover] price]];
	
	[[self adRemoverBuyButton] setTitle: priceString forState: UIControlStateNormal];
	
	[[self adRemoverRestoreButton] setTitle: CPLocalizedString(@"Restore", @"VEAdStationView_restore_button") forState: UIControlStateNormal];
	
	[[self adRemoverBuyButton] setEnabled: YES];
	
	[[self adRemoverRestoreButton] setEnabled: YES];
	
	[[self adRemoverBuyButton] setSelected: YES];
	
	if (![SKPaymentQueue canMakePayments])
	{
		[self setPurchasesAreDisabled: YES];
	}
}

- (void) setPurchasesAreDisabled: (BOOL) purchasesAreDisabled
{
	//CPLog(@"are disabled: %@", purchasesAreDisabled ? @"YES" : @"NO");
	
	_purchasesAreDisabled = purchasesAreDisabled;
	
	if (_purchasesAreDisabled)
	{
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		
		[NSThread sleepForTimeInterval: .5];
		
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		
		[[self adRemoverBuyButton] setEnabled: NO];
		
		[[self adRemoverRestoreButton] setEnabled: NO];
		
		[[self disabledPurchasesLabel] setText: CPLocalizedString(@"Purchases are disabled on this device due to restrictions.", @"VEAdStationView_disabled_purchases_title")];
	}
	else
	{
		[[self adRemoverBuyButton] setEnabled: YES];
		
		[[self adRemoverRestoreButton] setEnabled: YES];
		
		[[self disabledPurchasesLabel] setText: @""];
	}
}

#pragma mark Products Request Methods

- (void) request: (SKRequest *) request didFailWithError: (NSError *) error
{
	if (![request isEqual: [self productRequest]])
		CPLog(@"DIF REQUEST");
	
	[self setProductRequest: nil];
	
	[[VEConsul sharedConsul] stopLoadingSpinner];
	
	CPLog(@"failed with error: %@", error);
	
	#if kEnableCrashlytics

		if (error)
			[[Crashlytics sharedInstance] recordError: error];
	
	#endif
	
	[self showAlertForError: error];
	
	[self handleNoProductWithFailed: nil];
}

- (void) productsRequest: (SKProductsRequest *) request didReceiveResponse: (SKProductsResponse *) response
{
	//CPLog(@"did receive response: %@", response);

	if (![request isEqual: [self productRequest]])
		CPLog(@"DIF REQUEST");
	
	[self setProductRequest: nil];
	
	[[VEConsul sharedConsul] stopLoadingSpinner];
	
	[self handleProductsResponse: response];
}

#pragma mark Payment Queue Methods

- (void) paymentQueue: (SKPaymentQueue *) queue updatedTransactions: (NSArray *) transactions
{
	for (SKPaymentTransaction *aTransaction in transactions)
	{
		if (![[[aTransaction payment] productIdentifier] isEqualToString: [NSBundle ve_adRemoverProductIdentifier]])
		{
			[self handleFailed: aTransaction];
			
			continue;
		}
		
		switch ([aTransaction transactionState])
		{
			case SKPaymentTransactionStatePurchasing:
				//CPLog(@"is purchasing");
				break;
			case SKPaymentTransactionStatePurchased:
				//CPLog(@"purchased");
				[self handlePurchased: aTransaction];
				break;
			case SKPaymentTransactionStateFailed:
				//CPLog(@"failed");
				[self handleFailed: aTransaction];
				
				//[self handlePurchased: aTransaction];
				break;
			case SKPaymentTransactionStateRestored:
				//CPLog(@"restored");
				[self handlePurchased: aTransaction];
				break;
			case SKPaymentTransactionStateDeferred:
				//CPLog(@"deferred");
				[self handleDeferred: aTransaction];
				break;
				
			default:
				break;
		}
	}
}

- (void) paymentQueue: (SKPaymentQueue *) queue removedTransactions: (NSArray *) transactions
{
	//CPLog(@"removed: %@", transactions);
	
	[[VEConsul sharedConsul] stopLoadingSpinner];
	
	[[self adRemoverBuyButton] setEnabled: YES];
	
	[[self adRemoverRestoreButton] setEnabled: YES];

	
	if ([[self buySpinner] isAnimating])
	{
		//CPLog(@"buy animating");
		
		[[self buySpinner] stopAnimating];
		
		[[self adRemoverBuyButton] setHidden: NO];
	}
	
	if ([[self restoreSpinner] isAnimating])
	{
		//CPLog(@"restore animating");
		
		[[self restoreSpinner] stopAnimating];
		
		[[self adRemoverRestoreButton] setHidden: NO];
	}
}

- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	CPLog(@"restore failed: %@", error);
	
	[[VEConsul sharedConsul] stopLoadingSpinner];
	
	[[self adRemoverBuyButton] setEnabled: YES];
	
	[[self adRemoverRestoreButton] setEnabled: YES];
	
	if ([[self restoreSpinner] isAnimating])
	{
		//CPLog(@"restore animating");
		
		[[self restoreSpinner] stopAnimating];
		
		[[self adRemoverRestoreButton] setHidden: NO];
	}
	else
	{
		NSAssert(NO, @"WTF? Restored failed w/ out spinner");
	}

	#if kEnableCrashlytics

	BOOL isCancelledError = ([[error domain] isEqualToString: SKErrorDomain] &&
						[error code] == SKErrorPaymentCancelled);

	if (error && !isCancelledError)
		[[Crashlytics sharedInstance] recordError: error];

	#endif
	
	[self showAlertForError: error];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	CPLog(@"restore finished");
	
	[[VEConsul sharedConsul] stopLoadingSpinner];
	
	[[self adRemoverBuyButton] setEnabled: YES];
	
	[[self adRemoverRestoreButton] setEnabled: YES];
	
	if ([[self restoreSpinner] isAnimating])
	{
		//CPLog(@"restore animating");
		
		[[self restoreSpinner] stopAnimating];
		
		[[self adRemoverRestoreButton] setHidden: NO];
	}
	else
	{
		NSAssert(NO, @"WTF? Restored failed w/ out spinner");
	}
}

#pragma mark -

- (void) handlePurchased: (SKPaymentTransaction *) aTransaction
{
	CPLog(@"has purchased");
	
	[self showAlertForPurchase];
	
	#if kEnableCrashlytics
		
		BOOL isRestore = ([aTransaction transactionState] == SKPaymentTransactionStateRestored);
		
		if (isRestore)
		{
			[Answers logCustomEventWithName: @"Ad Remover Restored"
						customAttributes: nil];
		}
		else
		{
			[Answers logPurchaseWithPrice: [[self adRemover] price]
							 currency: [[[self adRemover] priceLocale] objectForKey: NSLocaleCurrencyCode]
							  success: @(YES)
							 itemName: @"Ad Remover"
							 itemType: nil
							   itemId: [[self adRemover] productIdentifier]
					   customAttributes: nil];
		}
		
		
	#endif
	
	[[SKPaymentQueue defaultQueue] finishTransaction: aTransaction];
}

- (void) handleFailed: (SKPaymentTransaction *) aTransaction
{
	CPLog(@"has failed");
	
	NSError *transactionError = [aTransaction error];
	
	CPLog(@"error: %@", transactionError);
	
	#if kEnableCrashlytics

	[[Crashlytics sharedInstance] recordError: transactionError];

		NSDictionary *errorDictionary = @{@"Error" : [[aTransaction error] description]};
	
		[Answers logPurchaseWithPrice: [[self adRemover] price]
						 currency: [[[self adRemover] priceLocale] objectForKey: NSLocaleCurrencyCode]
						  success: @(NO)
						 itemName: @"Ad Remover"
						 itemType: nil
						   itemId: [[self adRemover] productIdentifier]
				   customAttributes: errorDictionary];
	
	#endif
	
	[[SKPaymentQueue defaultQueue] finishTransaction: aTransaction];
	
	[self showAlertForError: transactionError];
}

- (void) handleDeferred: (SKPaymentTransaction *) aTransaction
{
	CPLog(@"deferred");
	
	//[[SKPaymentQueue defaultQueue] finishTransaction: aTransaction];
	
	#if kEnableCrashlytics
	
		[Answers logCustomEventWithName: @"Ad Remover Deferred"
					customAttributes: nil];
	
	#endif
}

- (void) showAlertForPurchase
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		
		VEAlertManagerConfigurationBlock configurationBlock = ^NSString *(VEAlertStringType alertStringType) {
			
			switch (alertStringType) {
				case VEAlertStringTypeTitle:
					return CPLocalizedString(@"Thanks!", @"VEAdStationView_alert_title_thanks");
				case VEAlertStringTypeMessage:
					return CPLocalizedString(@"Ads are now disabled, thanks for your support! :-)", @"VEAdStationView_alert_message_thanks");
				case VEAlertStringTypeCancelButtonTitle:
				case VEAlertStringTypeActionButtonTitle:
				default:
					return nil;
			}
			
		};
		
		VEAlertManagerCompletionBlock completionBlock = ^(VEAlertButtonType buttonType) {
			
			[[[CPCoreDataManager sharedCoreDataManager] userContext] performBlock: ^{
				
				[[UserSettings sharedSettings] userIsANiceOne];
				
			}];
			
		};
		
		VEAlertManagerHasSetupBlock setupBlock = ^(id alertView) {
		
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
		};
		
		[VEAlertManager showAlertOfType: VEAlertTypeWithAction
			    withConfigurationBlock: configurationBlock
				    withHasSetupBlock: setupBlock
				  withCompletionBlock: completionBlock];
		
	});
}

- (void) showAlertForError: (NSError *) anError
{
	VEAlertManagerConfigurationBlock configurationBlock = ^NSString *(VEAlertStringType alertStringType) {
		
		switch (alertStringType) {
			case VEAlertStringTypeTitle:
				return [anError localizedDescription];
			case VEAlertStringTypeMessage:
				return [anError localizedFailureReason];
			case VEAlertStringTypeCancelButtonTitle:
			case VEAlertStringTypeActionButtonTitle:
			default:
				return nil;
		}
		
	};
	
	[VEAlertManager showAlertOfType: VEAlertTypeWithAction
		    withConfigurationBlock: configurationBlock
			    withHasSetupBlock: NULL
			  withCompletionBlock: NULL];
}

- (void) updateConstraints
{
	if (![self hasSetupConstraints])
	{
		[self setupConstraints];

		[self setHasSetupConstraints: YES];
	}

	[super updateConstraints];
}

- (void) appWillReOpen: (NSNotification *) notification
{
	BOOL canPurchase = [SKPaymentQueue canMakePayments];
	
	if (canPurchase == ![self purchasesAreDisabled])
	{
		return;
	}
	
	if (canPurchase)
	{
		[self setPurchasesAreDisabled: NO];
	}
	else
	{
		[self setPurchasesAreDisabled: YES];
	}
}

- (void) contentSizeDidChange: (NSNotification *) notification
{
	[[self adRemoverTitleLabel] setFont: [self titleFont]];
	
	[[self adRemoverDescriptionLabel] setFont: [self descriptionFont]];
	
	[[self disabledPurchasesLabel] setFont: [self disabledFont]];
}

- (UIFont *) titleFont
{
	UIFont *titleFont;
	
	titleFont = [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline];
	
	return titleFont;
}

- (UIFont *) descriptionFont
{
	UIFont *descriptionFont;
	
	descriptionFont = [UIFont preferredFontForTextStyle: UIFontTextStyleBody];
	
	return descriptionFont;
}

- (UIFont *) disabledFont
{
	UIFont *disabledFont;
	
	UIFontDescriptor *disabledFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle: UIFontTextStyleFootnote];
	
	disabledFontDescriptor = [disabledFontDescriptor fontDescriptorWithSymbolicTraits: UIFontDescriptorTraitBold];
	
	disabledFont = [UIFont fontWithDescriptor: disabledFontDescriptor size: 0];
	
	return disabledFont;
}

//- (void) didMoveToSuperview
//{
//	//CPLog(@"did move to superview: %@", [self superview]);
//	
//	[super didMoveToSuperview];
//	
//	if (![self superview])
//		[[self class] tearDownAdStationView];
//}

- (void) dealloc
{
	if (_productRequest)
	{
		[_productRequest cancel];

		_productRequest = nil;
	}

	[[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self
										   name: UIApplicationWillEnterForegroundNotification
										 object: nil];

	[[NSNotificationCenter defaultCenter] removeObserver: self
										   name: UIContentSizeCategoryDidChangeNotification
										 object: nil];
	
	//CPLog(@"ad station view dealloc");
}

+ (BOOL) requiresConstraintBasedLayout
{
	return YES;
}

@end
