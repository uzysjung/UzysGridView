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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"UzysGridView";
    UIBarButtonItem *barBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(ButtonTapp:)] autorelease];
    self.navigationItem.rightBarButtonItem = barBtn;
    
    gridView = [[UzysGridView alloc] initWithFrame:self.view.frame numOfRow:3 numOfColumns:2 cellMargin:2];
    gridView.delegate = self;
    gridView.dataSource = self;
    [self.view addSubview:gridView];
    
    test_arr = [[NSMutableArray alloc] init];
    
    for(int i=0;i < 42;i++)
    {
        [test_arr addObject:[NSString stringWithFormat:@"%d",i]];
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
    gridView.editable = toggle;
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



#pragma - UzysGridViewDataSource

-(NSInteger) numberOfCellsInGridView:(UzysGridView *)gridview {
    return [test_arr count];
}
-(UzysGridViewCell *)gridView:(UzysGridView *)gridview cellAtIndex:(NSUInteger)index
{
    UzysGridViewCustomCell *cell = [[[UzysGridViewCustomCell alloc] initWithFrame:CGRectNull] autorelease];
    cell.textLabel.text = [test_arr objectAtIndex:index];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", index];
    cell.backgroundView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    if(index ==0)
        cell.deletable = NO;
    return cell;
}

-(void) gridView:(UzysGridView *)gridview deleteAtIndex:(NSUInteger)index 
{
    [test_arr removeObjectAtIndex:index];
}
-(void) gridView:(UzysGridView *)gridView changedPageIndex:(NSUInteger)index 
{
    NSLog(@"Page : %d",index);
}
// ----------------------------------------------------------------------------------


@end
