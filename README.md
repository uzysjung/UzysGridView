UzysGridView
============
**This repository is not maintained.**

UzysGridView is simple GridView iOS Component which you can easily change position &amp; delete cell.  

![Screenshot](https://github.com/uzysjung/UzysGridView/raw/master/UzysGridView1.png) ![Screenshot](https://github.com/uzysjung/UzysGridView/raw/master/UzysGridView2.png)

![Screenshot](https://github.com/uzysjung/UzysGridView/raw/master/UzysGridView3.gif) 

[Youtube Link](http://www.youtube.com/watch?v=1nk1SK0RiWs)

**UzysGridView features:**
* you can move the cell position to other page.
* Unlike of spring board, page was not seperated. cells stand in a row.
* Portrait & LandScape supported

#####+ I made this long time ago when iOS version was 3.xx ~ 4.xx. at that time, I was a beginner. but it works :)


## Installation
Copy over the files 'UzysGridView' folder to your project folder

## Usage

### Initialize
``` objective-c
	_gridView = [[UzysGridView alloc] initWithFrame:self.view.frame numOfRow:3 numOfColumns:2 cellMargin:2];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    [self.view addSubview:_gridView];
````
### Reload
``` objective-c
	[_gridView reloadData];
````
### DataSource & Delegate
``` objective-c
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


````



