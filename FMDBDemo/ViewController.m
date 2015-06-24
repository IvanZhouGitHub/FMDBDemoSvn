//
//  ViewController.m
//  FMDBDemo
//
//  Created by 周文凡 on 15/6/17.
//  Copyright (c) 2015年 周文凡. All rights reserved.
//

#import "ViewController.h"
#import "fmdbModel.h"

@interface ViewController ()
@property(nonatomic,strong)fmdbModel* model;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UITextField *nNameTextField;
@property (strong,nonatomic)NSArray* results;

@end

@implementation ViewController
- (IBAction)add:(UIButton *)sender {
    NSString* name = self.nameTextField.text;
    int age = [self.ageTextField.text intValue];
    //[self.model insertWithDic:@{@"name":name,@"age":[NSNumber numberWithInt:age]}];
    [self.model setName: name];
    [self.model setAge:[NSNumber numberWithInt:age]];
    [self.model save];
    self.results = [self.model selectWithDic:nil];
    [self refreshView];
}
- (IBAction)delete:(UIButton *)sender {
    NSString* name = self.nameTextField.text;
    [self.model deleteWithDic:@{@"name":name}];
    self.results = [self.model selectWithDic:nil];
    [self refreshView];
}
- (IBAction)select:(UIButton *)sender {
    NSString* name = self.nameTextField.text;
    self.results = [self.model selectWithDic:[name length]>0?@{@"name":name}:nil];
    NSMutableString* resString = [NSMutableString stringWithString:@""];
    if ([self.results count]>0) {
        for(fmdbModel* model in self.results){
            [resString appendString:[NSString stringWithFormat:@"name:%@ age:%d \n",model.name,[model.age intValue]]];
        }
        self.resultTextView.text = resString;
    }else{
        self.resultTextView.text = @"未搜索到结果";
    }
}
- (IBAction)update:(id)sender {
    NSString* name = self.nameTextField.text;
    NSString* newName = self.nNameTextField.text;
    int age = [self.ageTextField.text intValue];
    [self.model updateWithProDic:@{@"name":newName} ConditionDic:@{@"name":name,@"age":[NSNumber numberWithInt:age]}];
    self.results = [self.model selectWithDic:nil];
    [self refreshView];
}

-(void)refreshView{
    NSArray* res = [self.model selectWithDic:nil];
    NSMutableString* resString = [NSMutableString stringWithString:@""];
    if ([self.results count]>0) {
        for(fmdbModel* model in res){
            [resString appendString:[NSString stringWithFormat:@"name:%@ age:%d \n",model.name,[model.age intValue]]];
        }
        self.resultTextView.text = resString;
    }else{
        self.resultTextView.text = @"未搜索到结果";
    }
    
    
}
-(fmdbModel *)model{
    
    if (_model==nil){
        _model =[[fmdbModel alloc]init];
        
    }
    return _model;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.model.name = @"1111";
    self.model.age = [NSNumber numberWithInt:111];
    
    [self.model createTable];
//    [self.model insertWithDic:@{@"name":@"auto",@"age":[NSNumber numberWithInt:22]}];
//    [self.model deleteWithDic:@{@"name":@"auto",@"age":[NSNumber numberWithInt:22]}];
//    
//    [model createTable];
//    [model insertWithName:@"zTest" Age:20];
//    //[model deleteWithName:@"zTest"];
//    [model updateName:@"zTest" NewName:@"zTestNew" NewAge:25];
  //  NSArray* result = [model fetchWithName:@"zTestNew"];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
