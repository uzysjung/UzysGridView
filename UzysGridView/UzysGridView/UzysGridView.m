//
//  UzysGridView.m
//  UzysGridView
//
//  Created by Uzys on 11. 11. 7..
//  Copyright (c) 2011 Uzys. All rights reserved.
//
#define COLLISIONWIDTH 80 //distance between moving cell and collision cell
#define PAGEMOVEMARGIN 70
#import "UzysGridView.h"

@interface UzysGridView (private)
- (void) InitVariable;
- (void) CellRearrange:(NSInteger) moveIndex with:(NSInteger)targetIndex;
- (void) DeleteCell:(NSInteger)index;
- (void) createLayout:(BOOL)isVariable;
- (void) LoadTotalView ;

//Cell Method;
- (void) setCurrentPageIndex:(NSUInteger)currentPageIndex;
- (void) MovePage:(NSInteger)index animated:(BOOL) animate;
- (void) cellWasSelected:(UzysGridViewCell *)cell;
- (void) cellWasDelete:(UzysGridViewCell *)cell;
- (void) CellSetPosition:(UzysGridViewCell *) cell;
- (void) editableAnimation;
- (NSInteger) CellCollisionDetection:(UzysGridViewCell *) cell;
@end

@implementation UzysGridView

@synthesize editable;
@synthesize dataSource;
@synthesize delegate,delegateScrollView;
@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize cellMargin;
@synthesize colPosX,rowPosY;
//Readonly
@synthesize scrollView= _scrollView;
@synthesize currentPageIndex=_currentPageIndex;
@synthesize numberOfPages=_numberOfPages;


-(void) InitVariable 
{
    _cellInfo = [[NSMutableArray alloc] init ];
    
}

//-(void)editableAnimation 
//{
//	static BOOL animatesLeft = NO;
//	if (self.editable) 
//	{
////        CGAffineTransform animateUp = CGAffineTransformMakeRotation(2*M_PI/180);
////		CGAffineTransform animateDown = CGAffineTransformMakeRotation(-2*M_PI/180);
//        CGAffineTransform animateUp = CGAffineTransformMakeScale(1.03, 1.03);
//		CGAffineTransform animateDown = CGAffineTransformMakeScale(1.0, 1.0);;
//		[UIControl beginAnimations:nil context:nil];		
//		NSInteger animatingItems = [_cellInfo count];
//
//        for(UzysGridViewCell *cell in _cellInfo) 
//        {
//            cell.ButtonDelete.transform = animatesLeft ? animateDown : animateUp;
//        }
//
//		if (animatingItems > 0) 
//		{
//			[UIControl setAnimationDuration:0.5];
//			[UIControl setAnimationDelegate:self];
//            [UIControl setAnimationDidStopSelector:@selector(editableAnimation)];
//			animatesLeft = !animatesLeft;            
//		} 
//		else 
//		{
//			[NSObject cancelPreviousPerformRequestsWithTarget:self];
//			[self performSelector:@selector(editableAnimation) withObject:nil afterDelay:0.5];
//		}
//		[UIControl commitAnimations];
//	}
//    else
//    {
//        for(UzysGridViewCell *cell in _cellInfo) 
//        {
//            cell.transform = CGAffineTransformIdentity;
//        }
//    }
//}

- (void)editableAnimation
{

    if(self.editable ==YES)
    {
        if([_cellInfo count] > 0)
        {
            [UIControl animateWithDuration:0.6
                                     delay: 0.0
                                   options: (UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAutoreverse |UIViewAnimationOptionRepeat)
                                animations:^(void){
                                    NSLog(@"editAniworking");
                                    
                                    for(int i=0;i<[_cellInfo count];i++)
                                    {
                                        UzysGridViewCell *cell  =[_cellInfo objectAtIndex:i];
                                        cell.ButtonDelete.transform = CGAffineTransformMakeScale(1.1,1.1);
                                    }
                                    
                                } completion:^(BOOL finished){
//                                    [self editableAnimation];
                                }];
        }
    }
    else
    {
        NSLog(@"editAniworking clear");

        for(UzysGridViewCell *cell in _cellInfo)
        {            
            cell.ButtonDelete.transform = CGAffineTransformIdentity;

        }
    }
    
    
}

-(void) CellRearrange:(NSInteger) moveIndex with:(NSInteger)targetIndex
{
    
    if(moveIndex==targetIndex || targetIndex ==-1)
        return;
    
    
    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape)
    {
        numCols = self.numberOfRows;
        numRows = self.numberOfColumns;
        
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);    
    CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
    
    [_scrollView setContentSize:contentSize];
    
    //Data Position Rearrange
    UzysGridViewCell *movingcell = [_cellInfo objectAtIndex:moveIndex];
    [_cellInfo removeObjectAtIndex:moveIndex];
    if(targetIndex == [_cellInfo count]+1)
    {
        [_cellInfo addObject:movingcell];
    }
    else
    {
        [_cellInfo insertObject:movingcell atIndex:targetIndex];
    }
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(gridView:moveAtIndex:toIndex:)])
    {
        [self.dataSource gridView:self moveAtIndex:moveIndex toIndex:targetIndex];        
    }
    
    //Cell Rearrange
    for(NSUInteger i=0;i<[_cellInfo count];i++)
    {
        
        UzysGridViewCell *cell = [_cellInfo objectAtIndex:i];
        
        NSUInteger setIndex = i;
        [cell performSelector:@selector(setCellIndex:) withObject:[NSNumber numberWithInt:setIndex]];
        if(movingcell != cell)
        {
            NSUInteger page = (NSUInteger)((float)(setIndex)/ cellsPerPage);
            NSUInteger row = (NSUInteger)((float)(setIndex)/numCols) - (page * numRows);
            CGPoint origin;
            CGRect contractFrame;
            if([colPosX count] == numCols &&[rowPosY count] == numRows)
            {
                NSNumber *rowPos = [rowPosY objectAtIndex:row];
                NSNumber *col= [colPosX objectAtIndex:(i % numCols)];
                origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), 
                                     [rowPos intValue]);
                contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
                [UIView beginAnimations:@"Move" context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                cell.frame = contractFrame;
                [UIView commitAnimations]; 
            }
            else
            {
                
                origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                     (row * cellBounds.size.height));
                contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
                [UIView beginAnimations:@"Move" context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
                cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
                [UIView commitAnimations]; 
            }
 
        }
    }
    
    
    
    
}


-(void) CellSetPosition:(UzysGridViewCell *) cell
{
    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape)
    {
        numCols = self.numberOfRows;
        numRows = self.numberOfColumns;
        
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
    

    NSUInteger setIndex = cell.index;
    NSUInteger page = (NSUInteger)((float)(setIndex)/ cellsPerPage);
    NSUInteger row = (NSUInteger)((float)(setIndex)/numCols) - (page * numRows);
    
    CGPoint origin;
    CGRect contractFrame;
    if([colPosX count] == numCols && [rowPosY count] == numRows)
    {
        NSNumber *rowPos = [rowPosY objectAtIndex:row];
        NSNumber *col= [colPosX objectAtIndex:(setIndex % numCols)];
        origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), 
                             [rowPos intValue]);
        contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
        [UIView beginAnimations:@"Move" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        cell.frame = contractFrame;
        [UIView commitAnimations];  
    }
    else
    {
        origin = CGPointMake((page * gridBounds.size.width) + (((setIndex) % numCols) * cellBounds.size.width), 
                             (row * cellBounds.size.height));
        contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
        [UIView beginAnimations:@"Move" context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
        [UIView commitAnimations];  
    }

    
    


    
    
    
}
-(NSInteger) CellCollisionDetection:(UzysGridViewCell *) cell
{
    
    NSMutableArray *collisionCells = [[NSMutableArray alloc] init];
    UzysGridViewCell *coll;
    NSInteger retInd =-1;
    
    NSUInteger numOfCell = [dataSource numberOfCellsInGridView:self];
    for(int i=0;i<[_cellInfo count];i++)
    {
        coll=[_cellInfo objectAtIndex:i];
        
        if(![cell isEqual:coll])
        {
          //  if(CGRectIntersectsRect(coll.frame, cell.frame))  //collision detection
          //  {
                CGFloat xDist = (coll.center.x - cell.center.x); //[2]
                CGFloat yDist = (coll.center.y - cell.center.y); //[3]
                CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist)); //[4]
                
                //                if(distance < cell.frame.size.width/2)
                //                    [collisionCells addObject:coll];
                if(distance < COLLISIONWIDTH)
                    [collisionCells addObject:coll];
          //  }
        }
    }
    
    if([collisionCells count]==1)
    {
        
        
        coll = [collisionCells objectAtIndex:0];
        
        if(coll.center.x < cell.center.x)
        {
            if(coll.index +1 == numOfCell )
            {
                retInd = coll.index;
            }
            else
            {
                retInd = coll.index +1;                
            }
            NSLog(@"Collide index:%d right",retInd);
        }
        else
        {
            retInd = coll.index;
            NSLog(@"Collide index:%d left",retInd);
            
        }
        
        
        
    }


    [collisionCells release];
    
    [self CellRearrange:cell.index with:retInd];
    return retInd;
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createLayout:NO];        
        [self InitVariable];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame numOfRow:(NSUInteger)rows numOfColumns:(NSUInteger)columns cellMargin:(NSUInteger)cellMargins
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.numberOfRows = rows;
        self.numberOfColumns= columns;
        self.cellMargin =cellMargins;
        [self createLayout:YES];
        [self InitVariable];

    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc uzysgridview");


    [_scrollView release];
    [_cellInfo release];
    [colPosX release];
    [rowPosY release];
    [super dealloc];
}


// ----------------------------------------------------------------------------------
#pragma - Layout/Draw

- (void) createLayout:(BOOL)isVariable
{
    if(isVariable ==NO)
    {
        self.numberOfRows = 3;
        self.numberOfColumns = 2;
        
    }
    //self.cellMargin =40;
    _currentPageIndex = 0;
    
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    NSLog(@"uzysView bound:%@",NSStringFromCGRect(self.bounds));
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds] ;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delaysContentTouches =YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.multipleTouchEnabled = NO;
    [self addSubview:_scrollView];
    
  //  [self reloadData];


    
}
- (void)layoutSubviews 
{
    [super layoutSubviews];
//    NSLog(@"Call GridView LayoutSubview");
    
    //iOS4는 scrollview가 움직일때 CALayer에서 미친듯 불러댐.
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self LoadTotalView];
    [self editableAnimation];
    NSLog(@"Call drawRect");
}

- (void)reloadData
{
    [self setNeedsDisplay]; //called drawRect:(CGRect)rect
    [self setNeedsLayout];
}

- (void) LoadTotalView {
    
    if(self.dataSource && self.numberOfRows > 0 && self.numberOfColumns >0)
    {
        NSUInteger numCols = self.numberOfColumns;
        NSUInteger numRows = self.numberOfRows;
        NSUInteger cellsPerPage = numCols * numRows;
        [_cellInfo removeAllObjects];
        BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
        if(isLandscape)
        {
            numCols = self.numberOfRows;
            numRows = self.numberOfColumns;
            
        }
        
        CGRect gridBounds = self.scrollView.bounds;
        
        CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
        
        CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
        
        [_scrollView setContentSize:contentSize];
        
        
        for(UIView *v in self.scrollView.subviews) 
        {
            [v removeFromSuperview];
        }
        
        for(NSUInteger i = 0 ; i< [self.dataSource numberOfCellsInGridView:self];i++)
        {
            UzysGridViewCell *cell = [self.dataSource gridView:self cellAtIndex:i];
//            [cell performSelector:@selector(setGridView:) withObject:self];
            [cell performSelector:@selector(setDelegate:) withObject:self];
            
            [cell performSelector:@selector(setCellIndex:) withObject:[NSNumber numberWithInt:i]];
            NSUInteger page = (NSUInteger)((float)i/ cellsPerPage);
            NSUInteger row = (NSUInteger)((float)i/numCols) - (page * numRows);
            
            CGPoint origin;
            CGRect contractFrame;
            if([colPosX count] == numCols &&[rowPosY count] == numRows)
            {
                NSNumber *rowPos = [rowPosY objectAtIndex:row];
                NSNumber *col= [colPosX objectAtIndex:(i % numCols)];
                origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), 
                                     [rowPos intValue]);
                contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
                cell.frame = contractFrame;
            }
            else
            {
                origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                     (row * cellBounds.size.height));
                contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
                cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
            }
            

            if(self.editable == YES)
            {
                [cell setEdit:YES];
//                [cell.ButtonDelete setHidden:NO];
                
            }
            else 
            {
                [cell setEdit:NO];
//                [cell.ButtonDelete setHidden:YES];
            }
            [_scrollView addSubview:cell];
            
            [_cellInfo addObject:cell];
        }
        
        [self MovePage:self.currentPageIndex animated:NO];
        
    }
    
}

// ----------------------------------------------------------------------------------
#pragma - Cell/Page Control

- (void) DeleteCell:(NSInteger)index {
    
    [[_cellInfo objectAtIndex:index] removeFromSuperview];
    [_cellInfo removeObjectAtIndex:index];
    
    NSUInteger numCols = self.numberOfColumns;
    NSUInteger numRows = self.numberOfRows;
    NSUInteger cellsPerPage = numCols * numRows;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    if(isLandscape)
    {
        numCols = self.numberOfRows;
        numRows = self.numberOfColumns;
        
    }
    
    CGRect gridBounds = self.scrollView.bounds;
    CGRect cellBounds = CGRectMake(0, 0, gridBounds.size.width / (float) numCols, gridBounds.size.height / (float) numRows);
    CGSize contentSize = CGSizeMake(self.numberOfPages * gridBounds.size.width , gridBounds.size.height);
    
    [UIView animateWithDuration:0.4 animations:^(void) { [_scrollView setContentSize:contentSize]; } ];
    
    
    
    
    for(NSUInteger i=index;i<[_cellInfo count];i++)
    {
        UzysGridViewCell *cell = [_cellInfo objectAtIndex:i];
        [cell performSelector:@selector(setCellIndex:) withObject:[NSNumber numberWithInt:i]];
        NSUInteger page = (NSUInteger)((float)i/ cellsPerPage);
        NSUInteger row = (NSUInteger)((float)i/numCols) - (page * numRows);
        
        CGPoint origin;
        CGRect contractFrame;
        if([colPosX count] == numCols &&[rowPosY count] == numRows)
        {
            NSNumber *rowPos = [rowPosY objectAtIndex:row];
            NSNumber *col= [colPosX objectAtIndex:(i % numCols)];
            origin = CGPointMake((page * gridBounds.size.width) + ( [col intValue]), 
                                  [rowPos intValue]);
            contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cell.cellInitFrame.size.width, (NSUInteger)cell.cellInitFrame.size.height);
            [UIView beginAnimations:@"Move" context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
            cell.frame = contractFrame;
            [UIView commitAnimations];  
        }
        else
        {
            origin = CGPointMake((page * gridBounds.size.width) + ((i % numCols) * cellBounds.size.width), 
                                 (row * cellBounds.size.height));
            contractFrame = CGRectMake((NSUInteger)origin.x, (NSUInteger)origin.y, (NSUInteger)cellBounds.size.width, (NSUInteger)cellBounds.size.height);
            [UIView beginAnimations:@"Move" context:nil];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
            cell.frame = CGRectInset(contractFrame, self.cellMargin, self.cellMargin);
            [UIView commitAnimations];  
        }
        


    }
    
}


- (void)updateCurrentPageIndex
{
//    CGFloat pageWidth = _scrollView.frame.size.width;
//    NSUInteger cpi = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    _currentPageIndex = cpi;
//    
//    if (delegate && [delegate respondsToSelector:@selector(gridView:changedPageToIndex:)]) {
//        [self.delegate gridView:self changedPageIndex:_currentPageIndex];
//    }
    NSUInteger curPage = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    static NSUInteger prevPage =0;
   // NSLog(@"CurPage %d",curPage);
    if(curPage != prevPage)
    {
        _currentPageIndex =curPage;
        if (delegate && [delegate respondsToSelector:@selector(gridView:changedPageIndex:)]) {
            
            [self.delegate gridView:self changedPageIndex:curPage];
        }
    }
    
    prevPage = curPage;
    
}
- (void) MovePage:(NSInteger)index animated:(BOOL) animate
{
    if(index < self.numberOfPages)
    {
        CGPoint move = CGPointMake(self.scrollView.frame.size.width * index, 0);        
        //  _scrollView.contentOffset = move;
        //  [_scrollView setContentOffset:move animated:YES];
        
        if(animate)
        {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{_scrollView.contentOffset = move;} completion:^(BOOL finished){
            
                if (delegate && [delegate respondsToSelector:@selector(gridView:endMovePage:)]) {
                    [delegate gridView:self endMovePage:index];
                }

            
            }];
        }
        else
        {
            _scrollView.contentOffset = move;
        }
        _currentPageIndex = index;
    }
    else
    {
        NSLog(@"MovePage - OutOfRange !");
    }

}


// ----------------------------------------------------------------------------------
#pragma - UzysGridView callback
- (void)cellWasSelected:(UzysGridViewCell *)cell
{
    NSLog(@"Cellwasselected");
    if (delegate && [delegate respondsToSelector:@selector(gridView:didSelectCell:atIndex:)]) {
        [delegate gridView:self didSelectCell:cell atIndex:cell.index];
    }
}
- (void)cellWasDelete:(UzysGridViewCell *)cell
{
    if (dataSource && [dataSource respondsToSelector:@selector(gridView:deleteAtIndex:)])
    {
        [dataSource gridView:self deleteAtIndex:cell.index];
        [self DeleteCell:cell.index];
    }
}
// ----------------------------------------------------------------------------------

#pragma - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
    
    if(delegateScrollView && [delegateScrollView respondsToSelector:@selector(gridView:scrollViewDidEndDecelerating:)])
        [self.delegateScrollView gridView:self scrollViewDidEndDecelerating:scrollView];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(delegateScrollView && [delegateScrollView respondsToSelector:@selector(gridView:scrollViewDidEndScrollingAnimation:)])
        [self.delegateScrollView gridView:self scrollViewDidEndScrollingAnimation:scrollView];
    
    [self updateCurrentPageIndex];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
    if(delegateScrollView && [delegateScrollView respondsToSelector:@selector(gridView:scrollViewDidScroll:)])
        [self.delegateScrollView gridView:self scrollViewDidScroll:scrollView];
    
    
   // NSLog(@"offset :%@",NSStringFromCGPoint(scrollView.contentOffset));
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
    if(delegateScrollView && [delegateScrollView respondsToSelector:@selector(gridView:scrollViewWillBeginDragging:)])
        [self.delegateScrollView gridView:self scrollViewWillBeginDragging:scrollView];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self updateCurrentPageIndex];
    if(delegateScrollView && [delegateScrollView respondsToSelector:@selector(gridView:scrollViewWillBeginDecelerating:)])
        [self.delegateScrollView gridView:self scrollViewWillBeginDecelerating:scrollView];
}

// ----------------------------------------------------------------------------------
#pragma - Property Override

- (void)setDataSource:(id<UzysGridViewDataSource>)uDataSource  //override
{
    dataSource = uDataSource;
   // [self reloadData];
}



- (void)setNumberOfColumns:(NSUInteger)value
{
    numberOfColumns = value;
   // [self reloadData];
}


- (void)setNumberOfRows:(NSUInteger)value
{
    numberOfRows = value;
   // [self reloadData];
}


- (void)setCellMargin:(NSUInteger)value
{
    cellMargin = value;
   // [self reloadData];
}

-(void) colPosX:(NSMutableArray *)value
{
    colPosX = [value retain];
   // [self reloadData];
    
}

- (void)setEditable:(BOOL)value
{
    editable = value;
    if(editable)
    {
        for(UIView *v in self.scrollView.subviews) 
        {
            if([v isKindOfClass:[UzysGridViewCell class]])
            {
                UzysGridViewCell *temp=(UzysGridViewCell *)v;
                [temp setEdit:YES];
                
            }
            
        }
    }
    else
    {
        for(UIView *v in self.scrollView.subviews) 
        {
            if([v isKindOfClass:[UzysGridViewCell class]])
            {
                UzysGridViewCell *temp=(UzysGridViewCell *)v;
                [temp setEdit:NO];              
            }
        }
    }
    [self editableAnimation];
    
}

- (void) setCurrentPageIndex:(NSUInteger)currentPageIndex
{
    if(currentPageIndex <  self.numberOfPages)
        _currentPageIndex = currentPageIndex;
    else
        _currentPageIndex = self.numberOfPages -1 ;
    
    if(self.numberOfPages == 0)
        _currentPageIndex = 0;
    
}

- (NSUInteger)numberOfPages
{
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInGridView:self];
    NSUInteger cellsPerPage = self.numberOfColumns * self.numberOfRows;
    return (NSUInteger)(ceil((float)numberOfCells / (float)cellsPerPage));
}


#pragma -mark UzysGridViewCell Delegate
-(void)movePagesTimer:(NSTimer*)timer
{
    
    //PageMove
    //    NSInteger MaxScrollwidth = _scrollView.bounds.size.width * gridView.currentPageIndex;
    //    NSInteger MinScrollwidth = _scrollView.bounds.size.width * gridView.currentPageIndex - _scrollView.bounds.size.width;	
    
    NSLog(@"movePageTimer in");
    NSInteger MaxScrollwidth = _scrollView.contentOffset.x + _scrollView.bounds.size.width;
    NSInteger MinScrollwidth = _scrollView.contentOffset.x;
	if([(NSString*)timer.userInfo isEqualToString:@"right"])
    {
        
        if(MaxScrollwidth - _curcell.center.x < PAGEMOVEMARGIN)
        {
            if(self.numberOfPages-1 > self.currentPageIndex)
            {
                [self MovePage:self.currentPageIndex+1 animated:YES];
                [_curcell moveByOffset:CGPointMake(_scrollView.frame.size.width, 0)];
                _touchLocation =CGPointMake(_touchLocation.x + _scrollView.frame.size.width, _touchLocation.y);
                
                if(self.numberOfPages-1 == self.currentPageIndex)
                {
                    NSUInteger maxCnt = [_cellInfo count]-1;
                    UzysGridViewCell *targetCell = (UzysGridViewCell *)[_cellInfo objectAtIndex:maxCnt];
                    [self CellRearrange:_curcell.index with:targetCell.index];                    
                }
      
            }
        }
    }
    else if([(NSString*)timer.userInfo isEqualToString:@"left"])
    {
        if(_curcell.center.x - MinScrollwidth < PAGEMOVEMARGIN)
        {
            if(self.currentPageIndex >0)
            {
                [self MovePage:self.currentPageIndex-1 animated:YES];
                [_curcell moveByOffset:CGPointMake(_scrollView.frame.size.width*-1, 0)];
                _touchLocation =CGPointMake(_touchLocation.x - _scrollView.frame.size.width, _touchLocation.y);
            }   
        }
        
    }
    
    
    
    _movePagesTimer = nil;
    _curcell = nil;
}

-(void) gridViewCell:(UzysGridViewCell *)cell touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchLocation = [[touches anyObject] locationInView:_scrollView];
    
    if(self.editable)
    {
        _scrollView.scrollEnabled = NO;
        //Bring Subview to Front
        [_scrollView bringSubviewToFront:cell];
        
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
                             
                             cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             cell.alpha = 0.8;
                             
                             
                         }
                         completion:nil];
        
        
    }
    else
    {
        if([[touches anyObject] tapCount] == 1)
        {
            if (delegate && [delegate respondsToSelector:@selector(gridView:TouchUpInside:)]) {
                [delegate gridView:self TouchUpInside:cell];
            }
        }

    }
}
-(void) gridViewCell:(UzysGridViewCell *)cell touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CGPoint newTouchLocation = [[touches anyObject] locationInView:_scrollView];
    
    if(self.editable)
    {
        
        //Picking & Move
        float deltaX = newTouchLocation.x - _touchLocation.x;
        float deltaY = newTouchLocation.y - _touchLocation.y;
        
        [cell moveByOffset:CGPointMake(deltaX, deltaY)];
        [self performSelector:@selector(CellCollisionDetection:) withObject:cell];
        
        //PageMove
        
        NSInteger MaxScrollwidth = _scrollView.contentOffset.x + _scrollView.bounds.size.width;
        NSInteger MinScrollwidth = _scrollView.contentOffset.x;
        if(MaxScrollwidth - cell.center.x < PAGEMOVEMARGIN)
        {
            if(_movePagesTimer == nil)
            {
                _curcell = cell;
                _movePagesTimer = [NSTimer scheduledTimerWithTimeInterval:0.7
                                                                   target:self 
                                                                 selector:@selector(movePagesTimer:) 
                                                                 userInfo:@"right" 
                                                                  repeats:NO];
                
                NSLog(@"movePageTmr right");
            }
        }
        else if(cell.center.x - MinScrollwidth < PAGEMOVEMARGIN)
        {
            
            if(_movePagesTimer ==nil)
            {
                _curcell = cell;
                _movePagesTimer = [NSTimer scheduledTimerWithTimeInterval:0.7
                                                                   target:self 
                                                                 selector:@selector(movePagesTimer:) 
                                                                 userInfo:@"left" 
                                                                  repeats:NO];
                NSLog(@"movePageTmr left");
            }
        }
        else
        {
            if(_movePagesTimer !=nil)
            {
                NSLog(@"MovPageTimver invalidate");
                [_movePagesTimer invalidate];
                NSLog(@"MovPageTimver nil");
                _movePagesTimer = nil;
                _curcell = nil;
                
            }
        }
        
        _touchLocation = newTouchLocation;
    }

}
-(void) gridViewCell:(UzysGridViewCell *)cell touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.scrollView.scrollEnabled = YES;
    
    if(self.editable)
    {
        [_movePagesTimer invalidate];
        _movePagesTimer = nil;
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
                             
							 cell.transform = CGAffineTransformIdentity;
							 cell.alpha = 1;
                             
                             
                         }
                         completion:nil];
        
        
        [self CellSetPosition:cell];
    }
    else
    {
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
                             
							 cell.transform = CGAffineTransformIdentity;
							 cell.alpha = 1;
                             
                             
                         }
                         completion:nil];

        SEL singleTapSelector = @selector(cellWasSelected:);
        //    SEL doubleTapSelector = @selector(cellWasDoubleTapped:);
        
        if (self) {
            UITouch *touch = [touches anyObject];
            
            switch ([touch tapCount]) 
            {
                case 0: //오랫동안 길게 누른경우
                {
                    CGPoint curPos = [touch locationInView:self];
                    NSLog(@"CELL Frame:%@",NSStringFromCGRect(cell.frame));
                    if(CGRectContainsPoint(cell.frame, curPos))
                    {
                        //select
                        if (delegate && [delegate respondsToSelector:@selector(gridView:TouchUpOoutside:)]) {
                            [delegate gridView:self TouchUpOoutside:cell];
                        }
                        
                        [self performSelector:singleTapSelector withObject:cell];
                    }
                    else
                    {
                        if (delegate && [delegate respondsToSelector:@selector(gridView:TouchCanceled:)]) {
                            [delegate gridView:self TouchCanceled:cell];
                        }
                    }

                }
                    break;
                case 1:
                    if (delegate && [delegate respondsToSelector:@selector(gridView:TouchUpOoutside:)]) {
                        [delegate gridView:self TouchUpOoutside:cell];
                    }
                    [self performSelector:singleTapSelector withObject:cell];
                    break; 
                default:
                    break;
            }
        }

    }
    
    NSLog(@"TE");
}

-(void) gridViewCell:(UzysGridViewCell *)cell touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_movePagesTimer invalidate];
    _movePagesTimer = nil;
    if(self.editable)
    {
        NSLog(@"add to GridView");
        _scrollView.scrollEnabled = YES;
        [UIView animateWithDuration:0.1
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseIn 
                         animations:^{
                             
							 cell.transform = CGAffineTransformIdentity;
							 cell.alpha = 1;
                             
                             
                         }
                         completion:nil];
        [self CellSetPosition:cell];
    }
    else
    {
        if (delegate && [delegate respondsToSelector:@selector(gridView:TouchCanceled:)]) {
            [delegate gridView:self TouchCanceled:cell];
        }

    }
    
}

-(void) gridViewCell:(UzysGridViewCell *)cell didDelete:(NSUInteger)index
{
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         cell.alpha = 0;
                         cell.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
                     }
                     completion:nil];
    [self cellWasDelete:cell];
}
-(void) gridViewCell:(UzysGridViewCell *)cell handleLongPress:(NSUInteger)index
{
    self.editable =YES;    
}
@end
