////
////  BaseModel.m
////  FMDBDemo
////
////  Created by 周文凡 on 15/6/17.
////  Copyright (c) 2015年 周文凡. All rights reserved.
////
//
#import "BaseModel.h"
#define DB_SECRETKEY @"thisismykey"
@implementation BaseModel

/**
 *  数据库文件路径
 *
 *  @return
 */
-(NSString *)dbPath{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    return [document stringByAppendingPathComponent:@"SDK_USER_USERID.sqlite"];
}

/**
 *  更具demol创建数据库表格
 */
- (void)createTable
{
    
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    NSLog(self.dbPath);
    
    if (![fileManager fileExistsAtPath : self.dbPath]) {
        NSLog(@"还未创建数据库，现在正在创建数据库");
        if (![db open]) {
            db = nil;
            NSLog(@"database open error");
            return;
        }else{
            if (self.Encryption) {
            [self encryptionDB];
        }
            NSString * createTableSql = [NSString stringWithFormat:@"Create table if not exists %@ %@",[self className],[self valueString]];
            NSLog(@"======%@",createTableSql);
            [db executeUpdate:createTableSql];
            
            [db close];
        }
    }
    NSLog(@"FMDatabase:---------%@",db);
}

/**
 *  获取model 属性dic<属性名，属性类型>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)filterPropertyMap
{
    
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        const char* char_f =property_getName(properties[i]);
        
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        const char* char_a =  property_getAttributes(properties[i]);
        NSString *propertyvaName = [NSString stringWithUTF8String:char_a];
        fprintf(stdout, "%s %s\n", property_getName(properties[i]), property_getAttributes(properties[i]));
        [props setObject:[self compareProperty:propertyvaName] forKey:propertyName];
    }
    free(properties);
    return props;
}


/**
 *  查看属性对应数据库数据类型
 *
 *  @param property 属性名称
 *
 *  @return
 */
-(NSString *)compareProperty:(NSString*) property{
    
    if( [property  hasPrefix : @"T@\"NSString\"" ]){
        return @"TEXT";
    }else if([property  hasPrefix : @"Ti," ]){
        return @"INTERGER";
    }
    else if([property  hasPrefix : @"TB," ]){
        return @"INTERGER";
    }
    else if([property  hasPrefix : @"Tf," ]){
        return @"REAL";
    }
    else if([property  hasPrefix : @"T@\"NSDate\"" ]){
        return @"TEXT";
    }
    else if([property  hasPrefix : @"T@\"NSData\"" ]){
        return @"BLOB";
    }else if([property  hasPrefix : @"T@\"NSNumber\"" ]){
        return @"INTERGER";
    }
    return nil;
}


/**
 *  拼接sql
 *
 *  @return
 */
-(NSString*)valueString{
    NSDictionary* propertyMap = [self filterPropertyMap];
    NSMutableString* queryString = [NSMutableString stringWithString:@""];
    int index = 0;
    for(NSString* property in [propertyMap allKeys]){
        if (![property  isEqualToString:@"dbPath"]) {
            
            
            if (index==0) {
                [queryString appendString:[NSString stringWithFormat:@"(%@ %@",property,[propertyMap objectForKey:property]]];
            }else{
                [queryString appendString:[NSString stringWithFormat:@",%@ %@",property,[propertyMap objectForKey:property]]];
            }
            
            index++;
        }
    }
    
    [queryString appendString:@")"];
    return queryString;
}


/**
 *  获取model 属性和属性值的dic<属性名，属性值>
 *
 *  @return
 */
-(NSDictionary*)keyValueMap{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    
    for (i = 0; i<outCount; i++)
    {
        
        const char* char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        SEL selector = NSSelectorFromString([self getSelName:propertyName]);
        id proValue = [self performSelector:selector] ;
        
        if (proValue) {
            [props setObject:proValue forKey:propertyName];
        }
        
    }
    free(properties);
    return props;
}

/**
 *  插入数据
 *
 *  @param propertysDic model属性dic <属性名，属性值>
 */
- (void) insertWithDic:(NSDictionary*)propertysDic{
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if (![db open]) {
        db = nil;
        NSLog(@"database open error");
        return;
    }else{
        if (self.Encryption) {
            [self encryptionDB];
        }
        NSString * className = [self className];
        NSMutableString * keyString = [NSMutableString stringWithString:@"("] ;
        NSMutableString * valueString = [NSMutableString stringWithString:@"VALUES ("];
        NSMutableArray* sqlPropertys = [NSMutableArray array];
        int i = 0;
        for(NSString* propertyName in [propertysDic allKeys]){
            [keyString appendString:(i>0?[NSString stringWithFormat:@",%@",propertyName]:propertyName)];
            [valueString appendString:(i>0?[NSString stringWithFormat:@",%@",@"?"]:@"?")];
            [sqlPropertys addObject:[propertysDic valueForKey:propertyName]];
            i++;
        }
        [keyString appendString: @")"];
        [valueString appendString: @")"];
        NSString* sql = [NSString stringWithFormat:@"insert into %@ %@ %@",className,keyString,valueString];
        BOOL res = [db executeUpdate:sql withArgumentsInArray:sqlPropertys];
        
        if (res == NO) {
            NSLog(@"数据插入失败");
        }else{
            NSLog(@"数据插入成功");
        }
    }
    [db close];
   
}

/**
 *  根据dic 删除model
 *
 *  @param propertysDic model属性dic <属性名，属性值>
 */
- (void)deleteWithDic:(NSDictionary*)propertysDic{
    FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
    //打开数据库
    BOOL res = [db open];
    
    if (!res) {
        db = nil;
        NSLog(@"database open error");
        return;
    }else{
        if (self.Encryption) {
            [self encryptionDB];
        }
       
        NSString * className = [self className];
        NSMutableString * keyString = [NSMutableString stringWithString:@""] ;
        NSMutableArray* sqlPropertys = [NSMutableArray array];
        int i = 0;
        for(NSString* propertyName in [propertysDic allKeys]){
            [keyString appendString:(i>0?[NSString stringWithFormat:@" and %@ = ?",propertyName]:[NSString stringWithFormat:@"%@ = ?",propertyName])];
            [sqlPropertys addObject:[propertysDic valueForKey:propertyName]];
            i++;
        }
        NSString* sql = [NSString stringWithFormat:@"delete from %@ where %@ ",className,keyString];
        res = [db executeUpdate:sql withArgumentsInArray:sqlPropertys];
        
        if (res == NO) {
            NSLog(@"删除失败");
        }else{
            NSLog(@"删除成功");
        }

    }
    [db close];
}

/**
 *  更行model
 *
 *  @param propertysDic model新属性dic <属性名，属性值>
 *  @param conditionDic 条件model属性dic <属性名，属性值>
 */
- (void)updateWithProDic:(NSDictionary*)propertysDic ConditionDic:(NSDictionary*)conditionDic{
    FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
    BOOL res = [db open];
    
    if (!res) {
        db = nil;
        NSLog(@"database open error");
        return;
    }else{
        
        NSString * className = [self className];
        NSMutableString * proString = [NSMutableString stringWithString:@""] ;
        NSMutableString * conditionString = [NSMutableString stringWithString:@" where "] ;
        NSMutableArray* sqlPropertys = [NSMutableArray array];
        int i = 0;
        for(NSString* propertyName in [propertysDic allKeys]){
            [proString appendString:(i>0?[NSString stringWithFormat:@" ,%@ = ?",propertyName]:[NSString stringWithFormat:@"%@ = ?",propertyName])];
            [conditionString appendString:(i>0?[NSString stringWithFormat:@" and %@ = ?",propertyName]:[NSString stringWithFormat:@"%@ = ?",propertyName])];
            [sqlPropertys addObject:[propertysDic valueForKey:propertyName]];
            i++;
        }
        NSString* sql = [NSString stringWithFormat:@"update %@ set %@ %@",className,proString,conditionString];
        res = [db executeUpdate:sql withArgumentsInArray:sqlPropertys];
        
        
        if (res == NO) {
            NSLog(@"修改失败");
        }else{
            NSLog(@"修改成功");
        }
    }
    [db close];
}

/**
 *  根据dic查询model
 *
 *  @param propertysDic model属性dic <属性名，属性值>
 *
 *  @return 查询结果数组
 */
- (NSArray*)selectWithDic:(NSDictionary*)propertysDic{
    
  
    FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    BOOL res = [db open];
    
    if (!res) {
        db = nil;
        NSLog(@"database open error");
        return array;
    }else{
        if (self.Encryption) {
            [self encryptionDB];
        }
        
        
        NSString * className = [self className];
        NSMutableString * keyString = [NSMutableString stringWithString:@""] ;
        NSMutableArray* sqlPropertys = [NSMutableArray array];
        int i = 0;
        for(NSString* propertyName in [propertysDic allKeys]){
            [keyString appendString:(i>0?[NSString stringWithFormat:@" and %@ = ?",propertyName]:[NSString stringWithFormat:@"%@ = ?",propertyName])];
            [sqlPropertys addObject:[propertysDic valueForKey:propertyName]];
            i++;
        }
        NSString* sql = [NSString stringWithFormat:@"select * from %@",className];

        if ([propertysDic count]>0) {
            sql = [NSString stringWithFormat:@"%@ where %@",sql,keyString];
        }
        FMResultSet* set = [[FMResultSet alloc]init];
        if ([sqlPropertys count]>0) {
            set = [db executeQuery:sql withArgumentsInArray:sqlPropertys];//FMResultSet相当于游标集
        }else{
            set = [db executeQuery:sql];
        }
        
        [array addObjectsFromArray:[self packageModel:set]];
        
    }
    [db close];
    return array;
}

/**
 *  封装model
 *
 *  @param set FMResultSet
 *
 *  @return 查询结果封装后的数组
 */
- (NSArray*)packageModel:(FMResultSet*)set{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    NSDictionary* propertyMap = [self filterPropertyMap];
    Class class = NSClassFromString([self className]);
    
    while ([set next]) {//有下一个的话，就取出它的数据，然后关闭数据库
        BaseModel* model = [[class alloc]init];
        
        
        for(NSString* property in [propertyMap allKeys]){
            NSString* type = [propertyMap objectForKey:property];
            SEL selector = NSSelectorFromString([self setSelName:property]);
            if ([type isEqualToString:@"TEXT"]) {
                NSString* proValue = [set stringForColumn:property];
                [model performSelectorInBackground:selector withObject:proValue];
            }else if([type isEqualToString:@"INTERGER"]){
                int proValue = [[set stringForColumn:property] intValue];
                [model performSelectorInBackground:selector withObject:[NSNumber numberWithInt:proValue]];
            }else if([type isEqualToString:@"REAL"]){
                float proValue = [[set stringForColumn:property] floatValue];
                [model performSelectorInBackground:selector withObject: [NSNumber numberWithFloat:proValue]];
            }else if([type isEqualToString:@"BLOB"]){
                NSData* proValue = [set dataForColumn:property];
                [model performSelectorInBackground:selector withObject:proValue];
            }
        }
        [array addObject:model];
        
    }
    return array;
}

/**
 *  获取反射设置属性方法
 *
 *  @param name 属性名称
 *
 *  @return 方法名
 */
- (NSString*) setSelName:(NSString*)name{
    return [NSString stringWithFormat:@"set%@:",[name capitalizedString]];
}


/**
 *  获取反射取得属性方法
 *
 *  @param name 属性名称
 *
 *  @return 方法名
 */
- (NSString*) getSelName:(NSString*)name{
    return name;
}


/**
 *  model类名
 *
 *  @return model类名
 */
-(NSString*)className{
    return [[self class] description];
}

/**
 *  数据库加密
 */
- (void)encryptionDB{
    FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
    [db setKey:DB_SECRETKEY];
}

/**
 *  保存模型
 */
-(void)save{
    NSDictionary* dic = [self keyValueMap];
    [self insertWithDic:dic];
}
/**
 *  删除模型
 */
-(void)deleteModel{
    NSDictionary* dic = [self keyValueMap];
    [self deleteWithDic:dic];
}

/**
 *  跟新模型
 */
-(void)update{
    NSDictionary* dic = [self keyValueMap];
    [self updateWithProDic:dic ConditionDic:dic];
}

@end
