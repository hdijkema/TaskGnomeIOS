/**********************************************************
 ServerCommunication.m
 
 This file is part of TaskGnome IOS.
 
 TaskGnome is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with TaskGnome IOS.  If not, see <http://www.gnu.org/licenses/>.
 
 Copyright (c) 2013 Hans Oesterholt. All rights reserved.
 **********************************************************/

#import "ServerCommunication.h"
#import "AFNetworking.h"
#import "CdDelegate.h"
#import "UserPrefs.h"

@interface ServerCommunication ()

@property (nonatomic, strong) NSString * user;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) CdDelegate * cd_delegate;

@property (nonatomic, strong) NSString * url_base;
@property (nonatomic, strong) AFHTTPClient * client;
@property (nonatomic, strong) NSString * error_message;

@property (nonatomic, weak) NSObject<IServerCommunication> * cb_context;
@property BOOL is_busy;

typedef void (^cbResultLineInterpreter)(NSString *message);

@property (nonatomic, strong) NSOperationQueue * opQueue;

@end


@implementation ServerCommunication

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constructors
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (ServerCommunication *) initWithUserAndCdDelegate:(NSString *)user password:(NSString *)pass delegate:(CdDelegate *)delegate
{
    self = [super init];
    self.user = user;
    self.password = pass;
    self.url_base = @"http://taskgnome.oesterholt.net/taskgnome.php";
    self.client =  [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:self.url_base]];
    self.is_busy = FALSE;
    self.cd_delegate = delegate;
    self.opQueue = [[NSOperationQueue alloc] init];
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Operations
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void) fetchIds
{
    NSURLRequest *req = [self constructUrl:@"getids" data:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    NSMutableDictionary * ids = [[NSMutableDictionary alloc] init];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL ok = [self interpretResponse:responseObject closure:^(NSString *line){
            NSArray *strings = [line componentsSeparatedByString:@","];
            int i;
            NSMutableDictionary *kv = [[NSMutableDictionary alloc] init];
            for(i=0; i < [strings count]; ++i) {
                [self get_key_value:[strings objectAtIndex:i] dict:kv];
            }
            NSLog(@"%@",line);
            
            NSString * task_id = [kv objectForKey:@"id"];
            NSString * md5 = [kv objectForKey:@"md5"];
            NSString * deleted = [kv objectForKey:@"deleted"];
            
            if (task_id != nil) {
                NSArray *a = [[NSArray alloc] initWithObjects:md5, deleted, @"remote", nil];
                [ids setObject:a forKey:task_id];
            }
            
        }];
        
        NSDictionary *localids = [self.cd_delegate getTaskIds];
        [localids enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *task_id = (NSString *) key;
            if ([ids objectForKey:task_id] == nil) {
                NSString *md5 = (NSString *) obj;
                NSArray *a = [[NSArray alloc] initWithObjects:md5, @"F", @"local", nil];
                [ids setObject:a forKey:task_id];
            }
        } ];
        
        NSDictionary *deletedlocalids = [self.cd_delegate getDeletedTaskIds];
        [localids enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *task_id = (NSString *) key;
            if ([ids objectForKey:task_id] == nil) {
                NSString *md5 = (NSString *) obj;
                NSArray *a = [[NSArray alloc] initWithObjects:md5, @"T", @"local", nil];
                [ids setObject:a forKey:task_id];
            }
        } ];
        
        [self processIds:ids];
        self.is_busy = FALSE;
        // [self.cb_context serverCommunicationOk]; -- Is not executed in the UI thread
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setError:error];
        self.is_busy = FALSE;
        // [self.cb_context serverCommunicationError:self.error_message]; -- is not executed in the UI thread
        // We're using a polling timer instead.
    }];
    
    [operation start];
}

- (void)processIds:(NSDictionary *)ids
{
    // Precondition: called with al ids: local and on server
    // 
    // For each id, check if:
    //    if id is deleted
    //      if id is locally deleted
    //        do nothing
    //      else
    //        delete locally (also if it doesn't exist anywhere)
    //    else if id does not exist
    //      if id exists in deleted table
    //         delete on server
    //      else
    //         fetch and add
    //    else if md5 unequal
    //      if locally changed
    //         update to server (// preferred to fetching from server)
    //      else
    //         fetch and update from server
    //    else
    //      do nothing
    
    [ids enumerateKeysAndObjectsUsingBlock:^(id _key, id _obj, BOOL *stop) {
        NSString *task_id = (NSString *) _key;
        NSArray *val = (NSArray *) _obj;
        NSString *md5 = (NSString *) [val objectAtIndex:0];
        NSString *_deleted = (NSString *) [val objectAtIndex:1];
        BOOL deleted = ( [_deleted isEqualToString:@"T"] ) ? TRUE : FALSE;
        BOOL local = [(NSString *) [val objectAtIndex:2] isEqualToString:@"local"];
        
        if (local) {
            // algorithm for pure local ids
            if (deleted) {
                [self deleteTaskOnServer:task_id];
            } else {
                [self updateTaskToServer:task_id];
            }
        } else {
            // algorithm for remote and local ids
            if (deleted) {
                if ([self.cd_delegate taskIsDeleted:task_id]) {
                    // ok, do nothing
                } else {
                    [self.cd_delegate deleteTask:task_id];
                }
            } else {
                if ([self.cd_delegate taskExists:task_id]) {
                    if ([[self.cd_delegate taskMd5:task_id] isEqualToString:md5]) {
                        // do nothing
                    } else {
                        if ([self.cd_delegate taskIsUpdated:task_id]) {
                            [self updateTaskToServer:task_id];
                        } else {
                            [self updateTaskFromServer:task_id];
                        }
                    }
                } else {
                    if ([self.cd_delegate taskIsDeleted:task_id]) {
                        [self deleteTaskOnServer:task_id];
                    } else {
                        [self insertTaskFromServer:task_id];
                    }
                }
            }
        }
    }];
}

- (void)updateTaskToServer:(NSString *)task_id
{
    CdTask *task = [self.cd_delegate fetchTask:task_id];
    if (task != nil) {
        NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
        [data setObject:[task name] forKey:@"name"];
        [data setObject:[task task_id] forKey:@"task_id"];
        [data setObject:[task md5] forKey:@"md5"];
        [data setObject:[task priority] forKey:@"priority"];
        CdCategory *cat = [task cat_relation];
        if (cat != nil) {
            [data setObject:[cat cat_id] forKey:@"category_id"];
        }
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"yyyy-MM-dd"];
        [data setObject:[form stringFromDate:[task due]] forKey:@"due"];
        NSString *mi = [task more_info];
        if (mi == nil) { mi = @""; }
        [data setObject:mi forKey:@"more_info"];
        
        NSString *kind = ([task getTaskKind]==Active) ? @"A" : @"F";
        [data setObject:kind forKey:@"kind"];
        
        NSURLRequest *req = [self constructUrl:@"addtask" data:data];
        // addtask does the same as updatetask (because it's an insertOrUpdate at the backend
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            BOOL ok = [self interpretResponse:responseObject closure:^(NSString *line) {
                NSLog(@"%@", line);
            }];
            if (ok) {
                NSLog(@"updateTaskToServer: success");
                [self.cd_delegate setTaskIsUpdatedOnServer:task];
            } else {
                NSLog(@"updateTaskToServer: bad luck");
            }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", error);
            [self setError:error];
         }];
        
        [self.opQueue addOperation:operation];
        //[operation start];
        //[operation waitUntilFinished];
    } else {
        // The user possibly deleted this task while we were syncing
    }
}

- (void)deleteTaskOnServer:(NSString *)task_id
{
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:task_id forKey:@"task_id"];
    NSURLRequest *req = [self constructUrl:@"deletetask" data:data];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL ok = [self interpretResponse:responseObject closure:^(NSString *line) {
            NSLog(@"%@", line);
        }];
        if (ok) {
            NSLog(@"deleteTaskOnServer: success");
        } else {
            NSLog(@"updateTaskOnServer: bad luck");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        [self setError:error];
    }];
    
    [self.opQueue addOperation:operation];
    //[operation start];
    //[operation waitUntilFinished];
}

- (BOOL)fetchTaskFromServer:(NSString *)task_id;
{
    __block BOOL success = TRUE;
    NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
    [data setObject:task_id forKey:@"task_id"];
    NSURLRequest *req = [self constructUrl:@"gettask" data:data];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *taskData = [[NSMutableDictionary alloc] init];
        BOOL ok = [self interpretResponse:responseObject closure:^(NSString *line) {
            // expect key = value
            [self get_key_value:line dict:taskData];
        }];
        
        if (ok) {
            NSLog(@"task name: %@", [taskData objectForKey:@"name"]);
            //CdDelegate *dg = [[CdDelegate alloc] init];
            CdDelegate *dg = self.cd_delegate;
	
            NSLog(@"fetchTaskFromServer: success");
            CdTask *task = [dg fetchTask:task_id];
            
            [task setName:(NSString *) [taskData objectForKey:@"name"]];
            [task setMore_info:(NSString *) [taskData objectForKey:@"more_info"]];
            
            NSNumber *prio = [NSNumber numberWithInteger:[(NSString *) [taskData objectForKey:@"priority"] integerValue]];
            [task setPriority:prio];
            
            NSDateFormatter *form = [[NSDateFormatter alloc] init];
            [form setDateFormat:@"yyyy-MM-dd"];
            NSString *tdue = (NSString *) [taskData objectForKey:@"due"];
            NSDate *due = [form dateFromString:tdue];
            [task setDue:due];
            
            NSString *category_id = (NSString *) [taskData objectForKey:@"category_id"];
            CdCategory * cat = [self.cd_delegate fetchCategory:category_id];
            [task setCat_relation:cat];
            
            CdTaskKind k = ([(NSString *) [taskData objectForKey:@"kind"] isEqualToString:@"A"]) ? Active : Finished;
            [task setTaskKind:k];
            
            [dg saveTaskFromServer:task];
        } else {
            NSLog(@"fetchTaskFromServer: bad luck");
            success = FALSE;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        [self setError:error];
        success = FALSE;
    }];
    
    [self.opQueue addOperation:operation];
    //[operation start];
    //[operation waitUntilFinished];
    
    return success;
}

- (void)insertTaskFromServer:(NSString *)task_id
{
    CdTask *task = [self.cd_delegate newTask];
    [task setTask_id:task_id];
    [self.cd_delegate saveTaskFromServer:task];
    [self fetchTaskFromServer:task_id];
}

- (void)updateTaskFromServer:(NSString *)task_id
{
    [self fetchTaskFromServer:task_id];
}

- (void)synchronizeTasks:(NSObject<IServerCommunication> *)cb_context;
{
    if (self.is_busy) {
        return; // already synchronizing
    }
    
    self.is_busy = TRUE;
    self.error_message = nil;
    self.cb_context = cb_context;
    [self fetchIds];
    //NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
    //    [self fetchIds];
    //}];
    //[op start];
    NSTimer * watchSync = [NSTimer scheduledTimerWithTimeInterval:0.5
                                   target:self
                                   selector:@selector(guardFinish:)
                                   userInfo:nil
                                   repeats:TRUE
                           ];
}

- (void) guardFinish:(NSTimer *)watchSync
{
    NSLog(@"Waiting for sync to finish");
    if (!self.is_busy) {
        [watchSync invalidate];
        if (self.error_message) {
            NSLog(@"Finished with error %@", self.error_message);
            [self.cb_context serverCommunicationError:self.error_message];
        } else {
            NSLog(@"Finished with success");
            [self.cb_context serverCommunicationOk];
        }
    }
}

- (void) checkUserPass:(cbCheckResult)cb;
{
    NSURLRequest *req = [self constructUrl:@"noop" data:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];

    __block NSString *message = nil;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL ok = [self interpretResponse:responseObject closure:^(NSString *line) {
            NSLog(@"%@", line);
            message = line;
        }];
        if (ok) {
            message = @"User/Password check - Success";
            cb(message, ceSUCCESS, -1);
            NSLog(@"checkUserPass: success");
        } else {
            NSString *e = self.error_message;
            int code = 0;
            if (e) {
                code = atoi([self.error_message cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            if (code == 701) {
                message = @"Wrong password";
                cb(message, ceERROR, code);
            } else if (code == 702){
                message = @"User email open for registration";
                cb(message, ceOPEN_FOR_REGISTRATION, code);
            } else if (code == 750) {
                message = @"User registration expired - renew";
                cb(message, ceERROR, code);
            } else {
                if (message == nil) {
                    message = @"Unknown error";
                } else if (e) {
                    message = self.error_message;
                }
                cb(message, ceERROR, code);
            }
            
            NSLog(@"checkUserPass: bad luck");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        [self setError:error];
        message = @"Error connecting to TaskGnome server";
        cb(message, ceERROR, 0);
    }];
    
    [self.opQueue addOperation:operation];
}

- (void) registerUserPass:(cbCheckResult)cb;
{
    NSURLRequest *req = [self constructUrl:@"newuser" data:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    __block NSString *message = nil;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL ok = [self interpretResponse:responseObject closure:^(NSString *line) {
            NSLog(@"%@", line);
            message = line;
        }];
        if (ok) {
            message = @"Email/Password registration - Success";
            cb(message, ceSUCCESS, -1);
            NSLog(@"registerUserPass: success");
        } else {
            NSString *e = self.error_message;
            int code = 0;
            if (e) {
                code = atoi([self.error_message cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            if (code == 701) {
                message = @"Wrong password";
                cb(message, ceERROR, code);
            } else if (code == 700) {
                message = @"This email address is already in use";
                cb(message, ceERROR, code);
            } else {
                if (e) {
                    message = e;
                }
                cb(message, ceERROR, code);
            }
            
            NSLog(@"checkUserPass: bad luck");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        [self setError:error];
        message = @"Error connecting to TaskGnome server";
        cb(message, ceERROR, 0);
    }];
    
    [self.opQueue addOperation:operation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Utility functions
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL) interpretResponse:(id)responseObject closure:(cbResultLineInterpreter)cb
{
    NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    NSArray *strings = [response componentsSeparatedByString:@"\n"];
    int i;
    BOOL gotOk = FALSE;
    for(i = 0; i < [strings count]; ++i) {
        NSString * line = [strings objectAtIndex:i];
        line = [self trim:line];
        if ([line isEqualToString:@""]) {
            // do nothing
        } else if ([[line substringToIndex:1] isEqualToString:@"#"]) {
            NSLog(@"%@",line);
        } else if ([line isEqualToString:@"OK"]) {
            NSLog(@"Ok");
            gotOk = TRUE;
        } else if ([line isEqualToString:@"NOK"]) {
            NSLog(@"NOK");
            NSString *errormsg = [strings objectAtIndex:(i+1)];
            NSLog(@"%@",errormsg);
            [self setErrorMsg:errormsg];
            return FALSE;
        } else {
            cb(line);
        }
    }
    if (!gotOk) {
        [self setErrorMsg:@"Active network proxy - cannot reach cloud"];
    }
    return gotOk;
}

- (BOOL) get_key_value:(NSString *)str dict:(NSMutableDictionary *)dict
{
    str = [self trim:str];
    NSRange r = [str rangeOfString:@"="];
    if (r.location == NSNotFound) {
        NSLog(@"No key value pair: %@", str);
        return FALSE;
    } else {
        NSString * key = [str substringToIndex:r.location];
        NSString * val = [str substringFromIndex:r.location+1];
        NSString * dval = [self urlDecodeValue:val];
        //NSLog(@"getkv: %@ = %@ (%@)", key, dval, val);
        [dict setObject:dval forKey:key];
        return TRUE;
    }
}

- (NSString *)trim:(NSString *)s
{
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
    

- (void) setError:(NSError *)error
{
    self.error_message = [error localizedDescription];
}

- (void) setErrorMsg:(NSString *)msg
{
    self.error_message = msg;
}

- (NSURLRequest *)constructUrl:(NSString *)operation data:(NSDictionary *)data
{
    AFHTTPClient *httpClient = self.client;
    
    NSMutableDictionary * dict;
    if (data != nil) {
        dict = [[NSMutableDictionary alloc] init];
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *str = (NSString *) obj;
                str = [self urlEncodeValue:str];
                [dict setObject:str forKey:key];
            } else {
                [dict setObject:obj forKey:key];
            }
        }];
        //dict = [[NSMutableDictionary alloc] initWithDictionary:data];
    } else {
        dict = [[NSMutableDictionary alloc] init];
    }
    [dict setObject:self.user forKey:@"user"];
    [dict setObject:self.password forKey:@"password"];
    [dict setObject:operation forKey:@"command"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:self.url_base
                                                      parameters:dict];
    return request;
}

/*
    NSString *url = [NSString stringWithFormat:@"%@?%@&user=%@", self.url_base, operation, self.user];
    NSArray * keys = [data allKeys];
    int i;
    for(i = 0; i < [keys count]; ++i) {
        NSString * key = (NSString *) [keys objectAtIndex:i];
        NSString * value = (NSString *) [data objectForKey:key];
        NSString * encodedValue = [self urlEncodeValue:value];
        url = [NSString stringWithFormat:@"%@&%@=%@", url, key, encodedValue];
    }
    
    NSURL *the_url = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:the_url];
    return request;
}
 */

- (NSString *)urlEncodeValue:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"[BR]"];
    CFStringRef original = (__bridge CFStringRef) str;
    CFStringRef s = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, original, NULL, NULL, kCFStringEncodingUTF8);
    NSString *result = (__bridge NSString *) s;
    return result;
}

- (NSString *)urlDecodeValue:(NSString *)str
{
    CFStringRef original = (__bridge CFStringRef) str;
    CFStringRef s = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, original, CFSTR(""),kCFStringEncodingUTF8);
    NSString *result = (__bridge NSString *) s;
    result = [result stringByReplacingOccurrencesOfString:@"[BR]" withString:@"\n"];
    result = [result stringByReplacingOccurrencesOfString:@"\\[" withString:@"["];
    result = [result stringByReplacingOccurrencesOfString:@"\\]" withString:@"]"];
    return result;
}


    
    
@end
