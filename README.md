## AAActivityAction [![build](https://travis-ci.org/r-plus/AAActivityAction.png?branch=master)](https://travis-ci.org/r-plus/AAActivityAction)

AAActivityAction is Reeder like ActionSheet. Method architecture is inspired by `UIActivity` and `UIActivityViewController`.

![https://dl.dropbox.com/u/149268/AA.png](https://dl.dropbox.com/u/149268/AA.png)

### Installation

#### CocoaPods
Add `pod 'AAActivityAction'` to your Podfile.

#### Manually

1. Link `QuartzCore` framework.
1. Drag the `AAActivityAction` folder to your project.

### Requirement

* iOS 5 or higher.
* `QuartzCore` framework.
* ARC.

### Usage

````
AAActivity *activity = [[AAActivity alloc] initWithTitle:@"Safari"
                                                   image:[UIImage imageNamed:@"Safari.png"]
                                             actionBlock:^(AAActivity *activity, NSArray *activityItems) {
    // do something...
}];
AAActivityAction *activityAction = [[AAActivityAction alloc] initWithActivityItems:@[@"http://www.apple.com/"]
                                                             applicationActivities:@[activity]
                                                                         imageSize:AAImageSizeSmall];
activityAction.title = @"sample title";
[activityAction show];
// or showInView
// [activityAction showInView:view];
````

### License
MIT License.
