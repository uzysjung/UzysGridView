//
//  UzysGridViewCell.h
//  UzysGridView
//
//  Created by Uzys on 11. 11. 7..
//  Copyright (c) 2011 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UzysGridView;
@class UzysGridViewCell;

#pragma -UzysGridViewCellDelegate
@protocol UzysGridViewCellDelegate<NSObject>
-(void) gridViewCell:(UzysGridViewCell *)cell touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) gridViewCell:(UzysGridViewCell *)cell touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) gridViewCell:(UzysGridViewCell *)cell touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) gridViewCell:(UzysGridViewCell *)cell touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) gridViewCell:(UzysGridViewCell *)cell didDelete:(NSUInteger)index;
-(void) gridViewCell:(UzysGridViewCell *)cell handleLongPress:(NSUInteger)index;
@end

@interface UzysGridViewCell : UIView<UIGestureRecognizerDelegate>
{
    NSInteger _index;                                   //Cell index
}

@property (nonatomic, assign) IBOutlet id<UzysGridViewCellDelegate> delegate;
@property (nonatomic, assign) NSInteger page; 
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL deletable;           // deletable flag
@property (retain) UIButton *ButtonDelete;    
@property (nonatomic, assign) CGRect cellInitFrame;

- (void)setEdit:(BOOL)edit;                             // Entering Edit mode
- (void)moveByOffset:(CGPoint)offset;

@end
