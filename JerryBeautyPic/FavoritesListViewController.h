//
//  FavoritesListViewController.h
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/24.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *favoriteListTableView;

@property (strong,nonatomic) NSMutableArray *favoriteImageArray;
@property (strong,nonatomic) NSMutableArray *favoriteImagePathArray;

@end
