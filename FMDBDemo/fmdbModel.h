//
//  fmdbModel.h
//  FMDBDemo
//
//  Created by 周文凡 on 15/6/17.
//  Copyright (c) 2015年 周文凡. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import <objc/runtime.h>
#import "BaseModel.h"

@interface fmdbModel : BaseModel
@property(nonatomic,copy) NSString *name;
@property(nonatomic,assign) NSNumber* age;
//@property(nonatomic,assign) BOOL ison;
//@property(nonatomic,assign) float ss;
//@property(nonatomic,strong) NSDate* da;
//@property(nonatomic,strong) NSData* isonss;
//@property (strong, nonatomic) NSString *dbPath;

@end
