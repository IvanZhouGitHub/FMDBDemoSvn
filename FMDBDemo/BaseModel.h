//
//  BaseModel.h
//  FMDBDemo
//
//  Created by 周文凡 on 15/6/17.
//  Copyright (c) 2015年 周文凡. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import <objc/runtime.h>


@interface BaseModel : NSObject
@property (copy, nonatomic) NSString *dbPath;
@property (assign, nonatomic) BOOL Encryption;
-(NSString *)dbPath;
-(void)initDataBase;
- (void)createTable;
-(NSDictionary *)filterPropertyMap;
-(NSString *)compareProperty:(NSString*) property;
-(NSString*)valueString;
- (void) insertWithDic:(NSDictionary*)propertysDic;
- (void)deleteWithDic:(NSDictionary*)propertysDic;
- (void)updateWithProDic:(NSDictionary*)propertysDic ConditionDic:(NSDictionary*)conditionDic;
- (NSArray*)selectWithDic:(NSDictionary*)propertysDic;
-(NSArray *)filterPropertys;
-(NSString*)className;
- (void)encryptionDB;
-(void)save;
-(void)deleteModel;
-(void)update;
-(NSDictionary*)keyValueMap;
@end

