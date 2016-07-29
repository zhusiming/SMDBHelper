//
//  SMDBHelper.h
//  SMDBHelper
//
//  Created by 朱思明 on 14/1/13.
//  Copyright (c) 2015年 朱思明. All rights reserved.
//

#import "SMDBHelper.h"
#import <sqlite3.h>

@implementation SMDBHelper

/**
 *  创建数据库表的方法
 *
 *  @param sql 创建表的sql语句
 *
 *  @return 如果创建成功返回YES，否则NO
 */
+ (BOOL)createTableWithSqlString:(NSString *)sql
{
    // 1.打开数据库
    // 01.数据库的路径
    NSLog(@"path:%@",SQLite_Path);
    // 02.打开数据库操作
    sqlite3 *sqlite = NULL;
    int result = sqlite3_open([SQLite_Path UTF8String], &sqlite);
    
    // 03.根据打开操作的返回值可以判断操作结果
    if (result != SQLITE_OK) {
        NSLog(@"打开失败");
        return NO;
    }
    
    // 2.执行sql语句
   
    char *error = NULL;
    result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &error);
    if (result != SQLITE_OK) {
        NSLog(@"执行SQL语句失败");
        // 3.关闭数据库
        sqlite3_close(sqlite);
        return NO;
    }
    
    // 4.执行成功
    NSLog(@"创建表成功");
    // 关闭数据库
    sqlite3_close(sqlite);
    return YES;
}

/**
 *  执行 sql语句的方法 此方法可执行:插入、修改和删除
 *
 *  @param sql    执行的sql语句
 *  @param params sql语句中的参数
 *
 *  @return 如果执行成功返回YES，否则NO
 */
+ (BOOL)execTableWithSqlString:(NSString *)sql params:(NSArray *)params
{
    // 1.打开数据库
    // 01.数据库的路径
    NSLog(@"path:%@",SQLite_Path);
    // 02.打开数据库操作
    sqlite3 *sqlite = nil;
    int result = sqlite3_open([SQLite_Path UTF8String], &sqlite);
    
    // 03.根据打开操作的返回值可以判断操作结果
    if (result != SQLITE_OK) {
        NSLog(@"打开失败");
        return NO;
    }
    
    // 2.编译sql语句
    // 创建sql语句
    // 如果sql语句的参数使用‘？’，就多了一步编译的过程
    // 01.创建数据句柄
    sqlite3_stmt *stmt = NULL;
    
    // 02.编译sql,判断sql语句是否正确，成功后放到数据句柄对象中
    result = sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"编译失败");
        // 关闭数据库
        sqlite3_close(sqlite);
        return NO;
    }
    
    // 03.绑定参数
    for (int i = 0; i < params.count; i++) {
        // 获取参数
        id value = params[i];
        
        // 不同类型的参数绑定的方法也不同
        if ([value isKindOfClass:[NSData class]]) {
            sqlite3_bind_blob(stmt, 2, [value bytes], ((NSData *)value).length, NULL);
        } else if ([value isKindOfClass:[NSString class]]) {
            sqlite3_bind_text(stmt, i + 1, [value UTF8String], -1, NULL);
        } else {
            sqlite3_bind_int(stmt, i + 1, [value intValue]);
        }
        
    }
    
    
    // 3.执行sql语句，也就是执行数据句柄
    result = sqlite3_step(stmt);
    if (result == SQLITE_ERROR || result == SQLITE_MISUSE) {
        NSLog(@"执行失败");
        // 关闭数据句柄
        sqlite3_finalize(stmt);
        
        // 关闭数据库
        sqlite3_close(sqlite);
        return NO;
    }
    
    NSLog(@"插入成功");
    // 关闭数据句柄
    sqlite3_finalize(stmt);
    
    // 关闭数据库
    sqlite3_close(sqlite);
    
    return YES;

}


/**
 *  查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)selectTableWithSqlString:(NSString *)sql
                          params:(NSArray *)params
               selectFinishBlock:(SelectFinishBlock)selectFinishBlock
{

    // 1.打开数据库
    // 01.数据库的路径
    NSLog(@"path:%@",SQLite_Path);
    // 02.打开数据库操作
    sqlite3 *sqlite = nil;
    int result = sqlite3_open([SQLite_Path UTF8String], &sqlite);
    
    // 03.根据打开操作的返回值可以判断操作结果
    if (result != SQLITE_OK) {
        NSLog(@"打开失败");
        // 调用查询结束的block
        selectFinishBlock(nil,@"数据库打开失败！");
        return;
    }
    
    // 2.编译sql语句
    // 创建sql语句

    // 如果sql语句的参数使用‘？’，就多了一步编译的过程
    // 01.创建数据句柄
    sqlite3_stmt *stmt = NULL;
    
    // 02.编译sql,判断sql语句是否正确，成功后放到数据句柄对象中
    result = sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"编译失败");
        // 调用查询结束的block
        selectFinishBlock(nil,@"sql语句编译失败！");
        // 关闭数据库
        sqlite3_close(sqlite);
        return;
    }
    
    // 03.绑定参数
    for (int i = 0; i < params.count; i++) {
        // 获取参数
        id value = params[i];
        
        // 不同类型的参数绑定的方法也不同
        if ([value isKindOfClass:[NSString class]]) {
            sqlite3_bind_text(stmt, i + 1, [value UTF8String], -1, NULL);
        } else {
            sqlite3_bind_int(stmt, i + 1, [value intValue]);
        }
        
    }
    
    /*
        @[
            @{@"id":@"",@"name":@"..",@"num";@100}，
            一条数据
        ]
        想获取上述内容的时候，
        1.字段的个数
        2.字段的名字
        3.字段名字对应的值
     */
    
    // 3.执行数据句柄
    // 01.创建一个可变的数组，数组的个数和查询结果的条数是对应的
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    // 02.执行查询操作
    result = sqlite3_step(stmt);
    // 03.判断当前是否有内容在数据句柄中，如果有内容result = 100;
    while(result == SQLITE_ROW) {
        // 04.创建一个可变字典，定义当前数据
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        // 04.获取字段的个数
        int column_count = sqlite3_column_count(stmt);
        for (int i = 0; i < column_count; i++) {
            // 1.通过字段索引——获取字段的名字
            const char *char_key = sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithUTF8String:char_key];
            
            // 2.通过字段索引——获取字段对应的值
            id value = nil;
            // 判断当前数据的类型
            if (sqlite3_column_type(stmt, i) == SQLITE_TEXT) {
                const char *char_value = (const char *)sqlite3_column_text(stmt, i);
                value = [NSString stringWithUTF8String:char_value];
            } else if (sqlite3_column_type(stmt, i) == SQLITE_BLOB) {
                // 读取二进制数据
                value = [NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)];
                
            } else {
                int int_value = sqlite3_column_int(stmt, i);
                value = @(int_value);
            }
            
            // 把数据添加到字典里面
            [dic setObject:value forKey:key];
            
        }
        
        // 把当前数据添加到数组中
        [mArray addObject:dic];
        
        // 读取下一条内容
        result = sqlite3_step(stmt);
        
    };
    
    // 把数据进行回调
    if (selectFinishBlock != nil) {
        selectFinishBlock(mArray,nil);
    }

    

}

/**
 *  异步查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)asyncSelectTableWithSqlString:(NSString *)sql
                               params:(NSArray *)params
                    selectFinishBlock:(SelectFinishBlock)selectFinishBlock
{
    // 创建多线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SMDBHelper selectTableWithSqlString:sql params:params selectFinishBlock:^(NSArray *dataList, NSString *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selectFinishBlock != nil) {
                    selectFinishBlock(dataList,error);
                }
            });
        }];
    });
}

#pragma mark - 可变参数

/**
 *  执行 sql语句的方法 此方法可执行:插入、修改和删除
 *
 *  @param sql    执行的sql语句
 *  @param params sql语句中的参数
 *
 *  @return 如果执行成功返回YES，否则NO
 */
+ (BOOL)execTableWithSqlString:(NSString *)sql paramsArgs:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION
{
    // 创建一个数据存放所有的参数
    NSMutableArray *params = [[NSMutableArray alloc] init];
    // 定义一个指向可选参数列表的指针
    va_list args;
    // 获取第一个可选参数的地址，此时参数列表指针指向函数参数列表中的第一个可选参数
    va_start(args, arg1);
    if(arg1)
    {
        // 如果第一个指针位置不为空我们就把第一个参数添加到数组中
        [params addObject:arg1];
        // 遍历参数列表中的参数，并使参数列表指针指向参数列表中的下一个参数
        id nextArg = nil;
        while((nextArg = va_arg(args, id)))
        {
            // 当前参数添加到数组中
            [params addObject:nextArg];
        }
    }
    // 结束可变参数的获取(清空参数列表)
    va_end(args);
    
    // 开执行插入、修改和删除
    return [SMDBHelper execTableWithSqlString:sql params:params];
}

/**
 *  查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)selectTableWithSqlString:(NSString *)sql
               selectFinishBlock:(SelectFinishBlock)selectFinishBlock
                      paramsArgs:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION
{
    // 创建一个数据存放所有的参数
    NSMutableArray *params = [[NSMutableArray alloc] init];
    // 定义一个指向可选参数列表的指针
    va_list args;
    // 获取第一个可选参数的地址，此时参数列表指针指向函数参数列表中的第一个可选参数
    va_start(args, arg1);
    if(arg1)
    {
        // 如果第一个指针位置不为空我们就把第一个参数添加到数组中
        [params addObject:arg1];
        // 遍历参数列表中的参数，并使参数列表指针指向参数列表中的下一个参数
        id nextArg = nil;
        while((nextArg = va_arg(args, id)))
        {
            // 当前参数添加到数组中
            [params addObject:nextArg];
        }
    }
    // 结束可变参数的获取(清空参数列表)
    va_end(args);
    
    // 开执行插入、修改和删除
    [SMDBHelper selectTableWithSqlString:sql params:params selectFinishBlock:^(NSArray *dataList, NSString *error) {
        if (selectFinishBlock != nil) {
            selectFinishBlock(dataList,error);
        }
    }];
}

/**
 *  异步查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)asyncSelectTableWithSqlString:(NSString *)sql
                    selectFinishBlock:(SelectFinishBlock)selectFinishBlock
                           paramsArgs:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION
{
    // 创建一个数据存放所有的参数
    NSMutableArray *params = [[NSMutableArray alloc] init];
    // 定义一个指向可选参数列表的指针
    va_list args;
    // 获取第一个可选参数的地址，此时参数列表指针指向函数参数列表中的第一个可选参数
    va_start(args, arg1);
    if(arg1)
    {
        // 如果第一个指针位置不为空我们就把第一个参数添加到数组中
        [params addObject:arg1];
        // 遍历参数列表中的参数，并使参数列表指针指向参数列表中的下一个参数
        id nextArg = nil;
        while((nextArg = va_arg(args, id)))
        {
            // 当前参数添加到数组中
            [params addObject:nextArg];
        }
    }
    // 结束可变参数的获取(清空参数列表)
    va_end(args);
    
    // 开执行插入、修改和删除
    [SMDBHelper asyncSelectTableWithSqlString:sql params:params selectFinishBlock:^(NSArray *dataList, NSString *error) {
        if (selectFinishBlock != nil) {
            selectFinishBlock(dataList,error);
        }
    }];
}

@end
