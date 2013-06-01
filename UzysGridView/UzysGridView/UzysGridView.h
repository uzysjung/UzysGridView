//
//  UzysGridView.h
//  UzysGridView
//
//  Created by Uzys on 11. 11. 7..
//  Copyright (c) 2011 Uzys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysGridViewCell.h"

@class UzysGridView;

#pragma mark - UzysGridViewDataSource
@protocol UzysGridViewDataSource<NSObject>
-(NSInteger) numberOfCellsInGridView:(UzysGridView *)gridview;
-(UzysGridViewCell *)gridView:(UzysGridView *)gridview cellAtIndex:(NSUInteger)index;

@optional                                                                                                   //edit mode
-(void) gridView:(UzysGridView *)gridview moveAtIndex:(NSUInteger)fromindex toIndex:(NSUInteger)toIndex;    //Cell Position Reorder
-(void) gridView:(UzysGridView *)gridview deleteAtIndex:(NSUInteger)index;                      
-(void) gridView:(UzysGridView *)gridview InsertAtIndex:(NSUInteger)index;
@end

#pragma mark - UzysGridViewDelegate
@protocol UzysGridViewDelegate<NSObject>
@optional
-(void) gridView:(UzysGridView *)gridView didSelectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index;
//-(void) gridView:(UzysGridView *)gridView didDeselectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index;
//-(void) gridView:(UzysGridView *)gridView didEndEditingCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index;
-(void) gridView:(UzysGridView *)gridView changedPageIndex:(NSUInteger)index;
-(void) gridView:(UzysGridView *)gridView endMovePage:(NSUInteger)index;

-(void) gridView:(UzysGridView *)gridView TouchUpInside:(UzysGridViewCell *)cell;
-(void) gridView:(UzysGridView *)gridView TouchUpOoutside:(UzysGridViewCell *)cell;
-(void) gridView:(UzysGridView *)gridView TouchCanceled:(UzysGridViewCell *)cell;
@end

#pragma mark - UzysGridViewScrollViewDelegate
@protocol UzysGridViewScrollViewDelegate<NSObject>
@optional
-(void) gridView:(UzysGridView *)gridView scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
-(void) gridView:(UzysGridView *)gridView scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void) gridView:(UzysGridView *)gridView scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
-(void) gridView:(UzysGridView *)gridView scrollViewDidScroll:(UIScrollView *)scrollView;
-(void) gridView:(UzysGridView *)gridView scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
@end

#pragma mark - UzysGridView
@interface UzysGridView : UIView <UIScrollViewDelegate,UzysGridViewCellDelegate,UIAlertViewDelegate>
{
    UIScrollView *_scrollView;
    NSUInteger _currentPageIndex;
    NSUInteger _numberOfPages;
    NSMutableArray *_cellInfo;
    
    CGPoint _touchLocation;                             //Last location
    NSTimer *_movePagesTimer;                           //GridView Page move Timer  
    UzysGridViewCell *_curcell;

}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet id<UzysGridViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<UzysGridViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<UzysGridViewScrollViewDelegate> delegateScrollView;
@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) NSUInteger cellMargin;
@property (nonatomic, retain) NSArray *colPosX;
@property (nonatomic, retain) NSArray *rowPosY;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) BOOL editable;

- (void) reloadData;
- (id) initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns cellMargin:(NSUInteger)cellMargins;
@end
