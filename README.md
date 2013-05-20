UzysGridView
============

UzysGridView is simple GridView iOS Component which you can easily change position &amp; delete cell.  

![Screenshot](https://github.com/uzysjung/UzysGridView/raw/master/UzysGridView1.png) ![Screenshot](https://github.com/uzysjung/UzysGridView/raw/master/UzysGridView2.png)

![Screenshot](https://github.com/uzysjung/UzysGridView/raw/master/UzysGridView3.gif)

[![UzysGridViewDemo](http://img.youtube.com/vi/1nk1SK0RiWs/0.jpg)](http://www.youtube.com/watch?v=1nk1SK0RiWs)


**UzysGridView features:**
* you can move the cell position to other page.
* Unlike of spring board, page was not seperated. cells stand in a row.
* Portrait &amp; LandScape supported

#####+ I made this long time ago when iOS version wass 3.xx ~ 4.xx. at that time, I was a beginner at iOS. but it works :)


## Installation
Copy over the files 'UzysGridView' folder to your project folder

## Usage

### Initialize
``` objective-c
    gridView = [[UzysGridView alloc] initWithFrame:self.view.frame numOfRow:3 numOfColumns:2 cellMargin:2];
    gridView.delegate = self;
    gridView.dataSource = self;
    [self.view addSubview:gridView];
````

### DataSource &amp Delegate
``` objective-c
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


````



