//
//  User.h
//  Peek-a-Boo
//
//  Created by Thomas Orten on 6/5/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * email;

@end
