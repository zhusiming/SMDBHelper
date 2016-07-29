//
//  SMDBHelper.h
//  SMDBHelper
//
//  Created by 朱思明 on 14/1/13.
//  Copyright (c) 2015年 朱思明. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  查询结果的block
 *
 *  @param dataList 结果内容
 *  @param error    错误信息
 */
typedef void(^SelectFinishBlock)(NSArray *dataList,NSString *error);

@interface SMDBHelper : NSObject

// 数据库的位置
#define SQLite_Path [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sqlite.db"]



/**
 *  创建数据库表的方法
 *
 *  @param sql 创建表的sql语句
 *
 *  @return 如果创建成功返回YES，否则NO
 */
+ (BOOL)createTableWithSqlString:(NSString *)sql;

/**
 *  执行 sql语句的方法 此方法可执行:插入、修改和删除
 *
 *  @param sql    执行的sql语句
 *  @param params sql语句中的参数
 *
 *  @return 如果执行成功返回YES，否则NO
 */
+ (BOOL)execTableWithSqlString:(NSString *)sql params:(NSArray *)params;

/**
 *  查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)selectTableWithSqlString:(NSString *)sql
                          params:(NSArray *)params
               selectFinishBlock:(SelectFinishBlock)selectFinishBlock;

/**
 *  异步查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)asyncSelectTableWithSqlString:(NSString *)sql
                               params:(NSArray *)params
                    selectFinishBlock:(SelectFinishBlock)selectFinishBlock;

#pragma mark - 可变参数
/**
 *  执行 sql语句的方法 此方法可执行:插入、修改和删除
 *
 *  @param sql    执行的sql语句
 *  @param params sql语句中的参数
 *
 *  @return 如果执行成功返回YES，否则NO
 */
+ (BOOL)execTableWithSqlString:(NSString *)sql paramsArgs:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)selectTableWithSqlString:(NSString *)sql
               selectFinishBlock:(SelectFinishBlock)selectFinishBlock
                      paramsArgs:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  异步查询数据，结果使用block回调方式返回，内容一字典和数组的形式进行呈现
 *
 *  @param sql               sql    执行的sql语句
 *  @param params            params sql语句中的参数
 *  @param selectFinishBlock block查询结果
 */
+ (void)asyncSelectTableWithSqlString:(NSString *)sql
                    selectFinishBlock:(SelectFinishBlock)selectFinishBlock
                           paramsArgs:(id)arg1, ... NS_REQUIRES_NIL_TERMINATION;


@end
