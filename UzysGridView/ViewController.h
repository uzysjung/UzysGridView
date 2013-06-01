//
//  ViewController.h
//  UzysGridView
//
//  Created by Uzys on 11. 11. 7..
//  Copyright (c) 2011 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysGridView.h"
@interface ViewController : UIViewController <UzysGridViewDelegate,UzysGridViewDataSource>
{
    UzysGridView *_gridView;
    NSMutableArray *_test_arr;
}
@end
