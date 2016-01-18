//
//  UIDevice+Additions.m
//  abike—Lyon
//
//  Created by Clément Padovani on 3/31/14.
//  Copyright (c) 2014 Clément Padovani. All rights reserved.
//

#import "UIDevice+Additions.h"

#import <mach/mach_host.h>

@implementation UIDevice (Additions)

+ (BOOL) ve_isAniPad
{
	return [[[UIDevice currentDevice] model] rangeOfString: @"ipad" options: NSCaseInsensitiveSearch].location != NSNotFound;
}

+ (NSString *) ve_freeMemory
{
	@try
	{
		long long totalMemory = 0.00;
		
		vm_statistics_data_t vmStats;
		mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
		kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
		
		if (kernReturn != KERN_SUCCESS)
		{
			return @"Error";
		}
		
		
		// Not in percent
		// Total Memory (formatted)
		totalMemory = (long long) (vm_page_size * vmStats.free_count);
		
		
		// Check to make sure it's valid
		if (totalMemory <= 0)
		{
			// Error, invalid memory value
			return @"Error";
		}
		
		// Completed Successfully
		
		NSString *memoryString = [NSByteCountFormatter stringFromByteCount: totalMemory countStyle: NSByteCountFormatterCountStyleBinary];
		
		return memoryString;
	}
	@catch (NSException *exception)
	{
		// Error
		return @"Error";
	}
}

@end
