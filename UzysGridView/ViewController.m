//
//  ViewController.m
//  UzysGridView
//
//  Created by Uzys on 11. 11. 7..
//  Copyright (c) 2011 Uzys. All rights reserved.
//

#import "ViewController.h"
#import "UzysGridViewCustomCell.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
-(void)dealloc
{
    [_gridView release];
    
    [super dealloc];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"UzysGridView";
    UIBarButtonItem *barBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(ButtonTapp:)] autorelease];
    self.navigationItem.rightBarButtonItem = barBtn;
    
    _gridView = [[UzysGridView alloc] initWithFrame:self.view.frame numOfRow:3 numOfColumns:2 cellMargin:2];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    [self.view addSubview:_gridView];
    
    _test_arr = [[NSMutableArray alloc] init];
    
    for(int i=0;i < 42;i++)
    {
        [_test_arr addObject:[NSString stringWithFormat:@"Content %d",i]];
    }
    
  	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction) ButtonTapp :(id)sender
{
    static BOOL toggle = NO;
    
    if(toggle == YES)
    {
        toggle = NO;
    }
    else 
    {
        toggle = YES;
    }
    _gridView.editable = toggle;
    [_gridView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



#pragma mark- UzysGridViewDataSource

-(NSInteger) numberOfCellsInGridView:(UzysGridView *)gridview {
    return [_test_arr count];
}
-(UzysGridViewCell *)gridView:(UzysGridView *)gridview cellAtIndex:(NSUInteger)index
{
    UzysGridViewCustomCell *cell = [[[UzysGridViewCustomCell alloc] initWithFrame:CGRectNull] autorelease];
    cell.textLabel.text = [_test_arr objectAtIndex:index];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", _test_arr[index]];
    cell.backgroundView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    if(index ==0)
        cell.deletable = NO;
    return cell;
}

- (void)gridView:(UzysGridView *)gridview moveAtIndex:(NSUInteger)fromindex toIndex:(NSUInteger)toIndex
{
    NSMutableDictionary *Temp = [[_test_arr objectAtIndex:fromindex] retain];
    
    [_test_arr removeObjectAtIndex:fromindex];
    [_test_arr insertObject:Temp atIndex:toIndex];
    [Temp release];
}

-(void) gridView:(UzysGridView *)gridview deleteAtIndex:(NSUInteger)index 
{
    [_test_arr removeObjectAtIndex:index];
}

#pragma mark- UzysGridViewDelegate
-(void) gridView:(UzysGridView *)gridView changedPageIndex:(NSUInteger)index 
{
    NSLog(@"Page : %d",index);
}
-(void) gridView:(UzysGridView *)gridView didSelectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index
{
    NSLog(@"Cell index %d",index);
}
// ----------------------------------------------------------------------------------


@end
