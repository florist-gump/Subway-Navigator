//
//  TimiLineViewControl.m
//  Klubok
//
//  Created by Roma on 8/25/14.
//  Copyright (c) 2014 908 Inc. All rights reserved.
//
// modified by Florian Deuerlein

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS

#import "TimeLineViewControl.h"
#import "Masonry.h"
#import "MASViewAttribute.h"
#import <QuartzCore/QuartzCore.h>

const float BETTWEEN_LABEL_OFFSET = 20;
const float LINE_WIDTH = 2.0;
const float CIRCLE_RADIUS = 3.0;
const float INITIAL_PROGRESS_CONTAINER_WIDTH = 20.0;
const float PROGRESS_VIEW_CONTAINER_LEFT = 51.0;
const float VIEW_WIDTH = 225.0;

@interface TimeLineViewControl () {
    BOOL didStopAnimation;
    NSMutableArray *layers;
    NSMutableArray *circleLayers;
    int layerCounter;
    int circleCounter;
    CGFloat timeOffset;
    CGFloat leftWidth;
    CGFloat rightWidth;
    
    CGFloat viewWidth;
}

@property(nonatomic, strong) UIView *progressViewContainer;
@property(nonatomic, strong) UIView *timeViewContainer;
@property(nonatomic, strong) UIView *progressDescriptionViewContainer;

@property(nonatomic, strong) NSMutableArray *labelDscriptionsArray;
@property(nonatomic, strong) NSMutableArray *labelTimesArray;
@property(nonatomic, strong) NSMutableArray *sizes;
@end

@implementation TimeLineViewControl

@synthesize viewheight = viewheight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSMutableArray *)labelDscriptionsArray {
    if (!_labelDscriptionsArray) {
        _labelDscriptionsArray = [[NSMutableArray alloc] init];
    }
    return _labelDscriptionsArray;
}

- (NSMutableArray *)labelTimesArray {
    if (!_labelTimesArray) {
        _labelTimesArray = [[NSMutableArray alloc] init];
    }
    return _labelTimesArray;
}

- (NSMutableArray *)sizes {
    if (!_sizes) {
        _sizes = [[NSMutableArray alloc] init];
    }
    return _sizes;
}

- (id)initWithTimeArray:(NSArray *)time andTimeDescriptionArray:(NSArray *)timeDescriptions andCurrentStatus:(int)status andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        viewheight = frame.size.height;
        leftWidth = frame.size.width - (PROGRESS_VIEW_CONTAINER_LEFT + INITIAL_PROGRESS_CONTAINER_WIDTH + CIRCLE_RADIUS * 2);
        self.progressViewContainer = [[UIView alloc] init ];
        self.timeViewContainer = [[UIView alloc] init ];
        self.progressDescriptionViewContainer = [[UIView alloc] init];
        
        [self addSubview:self.progressViewContainer];
        [self addSubview:self.timeViewContainer];
        [self addSubview:self.progressDescriptionViewContainer];
        //uncomment to see color view's borders
        /*
         self.timeViewContainer.layer.borderColor = UIColor.blackColor.CGColor;
         self.timeViewContainer.layer.borderWidth = 1;
         self.progressDescriptionViewContainer.layer.borderColor = UIColor.redColor.CGColor;
         self.progressDescriptionViewContainer.layer.borderWidth = 1;
         self.progressViewContainer.layer.borderColor = UIColor.greenColor.CGColor;
         self.progressViewContainer.layer.borderWidth = 1;
        */
        [self addTimeDescriptionLabels:timeDescriptions andTime:time currentStatus:status];
        [self setNeedsUpdateConstraints];
        [self addProgressBasedOnLabels:self.labelDscriptionsArray currentStatus:status];
        [self addTimeLabels:time currentStatus:status];
        
        
    }
    
    return self;
}

- (void)addTimeLabels:(NSArray *)time currentStatus:(int)currentStatus {
    CGFloat betweenLabelOffset = 0;
    CGFloat totlaHeight = 6;
    int i = 0;
    for (NSString *timeDescription in time) {
        UILabel *label = [[UILabel alloc] init];
        
        [label setText:timeDescription];
        label.numberOfLines = 2;
        label.textColor = i < currentStatus ? [UIColor blackColor] : [UIColor grayColor];
        label.textAlignment = NSTextAlignmentRight;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
        [self.timeViewContainer addSubview:label];
        [self.labelTimesArray addObject:label];
        
        UILabel *descrLabel = self.labelDscriptionsArray[i];
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(16));
            make.left.equalTo(_timeViewContainer);
            make.width.equalTo(_timeViewContainer);
            make.top.equalTo(descrLabel.top);//.with.offset(betweenLabelOffset + 1);
        }];
        CGSize fittingSize = [label systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
        betweenLabelOffset = BETTWEEN_LABEL_OFFSET;
        totlaHeight += (fittingSize.height + betweenLabelOffset);
        
        [self.labelDscriptionsArray addObject:label];
        i++;
    }
    
    viewheight = totlaHeight;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    // update constraints now
    [self updateConstraintsIfNeeded];
}

- (void)addTimeDescriptionLabels:(NSArray *)timeDescriptions andTime:(NSArray *)time currentStatus:(int)currentStatus {
    CGFloat betweenLabelOffset = 0;
    CGFloat totlaHeight = 6;
    CGSize fittingSizeLabel;
    UILabel *lastLabel = [[UILabel alloc] initWithFrame:_progressDescriptionViewContainer.frame];
    [_progressDescriptionViewContainer addSubview:lastLabel];
    int i = 0;
    for (NSString *timeDescription in timeDescriptions) {
        UILabel *label = [[UILabel alloc] init];
        [label setText:timeDescription];
        label.numberOfLines = 0;
        label.textColor = i < currentStatus ? [UIColor blackColor] : [UIColor grayColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
        [self.progressDescriptionViewContainer addSubview:label];
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_progressDescriptionViewContainer).with.offset(7);
            make.width.equalTo(leftWidth);
            make.top.equalTo(lastLabel.bottom).with.offset(betweenLabelOffset);
            make.height.greaterThanOrEqualTo(@(16));
        }];
        
        [label setPreferredMaxLayoutWidth:leftWidth];
        [label sizeToFit];
        CGSize fittingSizeLabel = [label systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
        betweenLabelOffset = BETTWEEN_LABEL_OFFSET;
        totlaHeight += (fittingSizeLabel.height + betweenLabelOffset);
        lastLabel = label;
        
        [self.labelDscriptionsArray addObject:label];
        i++;
    }
    
    viewheight = fittingSizeLabel.height;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    // update constraints now
    [self updateConstraintsIfNeeded];
}

- (void)addProgressBasedOnLabels:(NSArray *)labels currentStatus:(int)currentStatus {
    int i = 0;
    CGFloat betweenLineOffset = 0;
    CGFloat totlaHeight = 8;
    CGPoint lastpoint;
    CGFloat yCenter;
    UIColor *strokeColor;
    CGPoint toPoint;
    CGPoint fromPoint;
    circleLayers = [[NSMutableArray alloc] init];
    layers = [[NSMutableArray alloc] init];
    
    for (UILabel *label in labels) {
        //configure circle
        
        CGSize fittingSize = [label systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
        strokeColor = i < currentStatus ? [UIColor orangeColor] : [UIColor lightGrayColor];
        yCenter = (totlaHeight /*+ fittingSize.height/2*/);
        
        UIBezierPath *circle = [UIBezierPath bezierPath];
        [self configureBezierCircle:circle withCenterY:yCenter];
        CAShapeLayer *circleLayer = [self getLayerWithCircle:circle andStrokeColor:strokeColor];
        [circleLayers addObject:circleLayer];
        //add static background gray circle
        CAShapeLayer *grayStaticCircleLayer = [self getLayerWithCircle:circle andStrokeColor:[UIColor lightGrayColor]];
        [self.progressViewContainer.layer addSublayer:grayStaticCircleLayer];
        //configure line
        if (i > 0) {
            fromPoint = lastpoint;
            toPoint = CGPointMake(lastpoint.x, yCenter - CIRCLE_RADIUS);
            lastpoint = CGPointMake(lastpoint.x, yCenter + CIRCLE_RADIUS);
            
            UIBezierPath *line = [self getLineWithStartPoint:fromPoint endPoint:toPoint];
            CAShapeLayer *lineLayer = [self getLayerWithLine:line andStrokeColor:strokeColor];
            [layers addObject:lineLayer];
            //add static background gray line
            CAShapeLayer *grayStaticLineLayer = [self getLayerWithLine:line andStrokeColor:[UIColor lightGrayColor]];
            [self.progressViewContainer.layer addSublayer:grayStaticLineLayer];
        } else {
            lastpoint = CGPointMake(self.progressViewContainer.center.x + CIRCLE_RADIUS + INITIAL_PROGRESS_CONTAINER_WIDTH / 2, yCenter + CIRCLE_RADIUS);
        }
        
        betweenLineOffset = BETTWEEN_LABEL_OFFSET;
        totlaHeight += (fittingSize.height + betweenLineOffset);
        i++;
    }
    
    for (CAShapeLayer *cilrclLayer in circleLayers) {
        [self.progressViewContainer.layer addSublayer:cilrclLayer];
    }
    for (CAShapeLayer *lineLayer in layers) {
        [self.progressViewContainer.layer addSublayer:lineLayer];
    }
}

- (void)updateCurrentStatus:(int)currentStatus {
    int i = 0;
    for (UILabel *label in self.labelDscriptionsArray) {
        label.textColor = i < currentStatus ? [UIColor blackColor] : [UIColor grayColor];
        i++;
    }
    i = 0;
    for (UILabel *label in self.labelTimesArray) {
        label.textColor = i < currentStatus ? [UIColor blackColor] : [UIColor grayColor];
        i++;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    i = 0;
    for (CAShapeLayer *circleLayer in circleLayers) {
        UIColor *strokeColor = i < currentStatus ? [UIColor orangeColor] : [UIColor lightGrayColor];
        circleLayer.strokeColor = strokeColor.CGColor;
        i++;
    }
    i = 1;
    for (CAShapeLayer *lineLayer in layers) {
        UIColor *strokeColor = i < currentStatus ? [UIColor orangeColor] : [UIColor lightGrayColor];
        lineLayer.strokeColor = strokeColor.CGColor;
        i++;
    }

}

- (CAShapeLayer *)getLayerWithLine:(UIBezierPath *)line andStrokeColor:(UIColor *)strokeColor {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = line.CGPath;
    lineLayer.strokeColor = strokeColor.CGColor;
    lineLayer.fillColor = nil;
    lineLayer.lineWidth = LINE_WIDTH;
    
    return lineLayer;
}

- (UIBezierPath *)getLineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end {
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:start];
    [line addLineToPoint:end];
    
    return line;
}

- (CAShapeLayer *)getLayerWithCircle:(UIBezierPath *)circle andStrokeColor:(UIColor *)strokeColor {
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = self.progressViewContainer.bounds;
    circleLayer.path = circle.CGPath;
    
    circleLayer.strokeColor = strokeColor.CGColor;
    circleLayer.fillColor = nil;
    circleLayer.lineWidth = LINE_WIDTH;
    circleLayer.lineJoin = kCALineJoinBevel;
    
    return circleLayer;
}

- (void)configureBezierCircle:(UIBezierPath *)circle withCenterY:(CGFloat)centerY {
    [circle addArcWithCenter:CGPointMake(self.progressViewContainer.center.x + CIRCLE_RADIUS + INITIAL_PROGRESS_CONTAINER_WIDTH / 2, centerY)
                      radius:CIRCLE_RADIUS
                  startAngle:M_PI_2
                    endAngle:-M_PI_2
                   clockwise:YES];
    [circle addArcWithCenter:CGPointMake(self.progressViewContainer.center.x + CIRCLE_RADIUS + + INITIAL_PROGRESS_CONTAINER_WIDTH / 2, centerY)
                      radius:CIRCLE_RADIUS
                  startAngle:-M_PI_2
                    endAngle:M_PI_2
                   clockwise:YES];
}

- (void)updateConstraints {
    [self.progressViewContainer updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(CIRCLE_RADIUS + INITIAL_PROGRESS_CONTAINER_WIDTH));
        make.height.equalTo(viewheight);
        make.top.equalTo(self);
        make.left.equalTo(@(PROGRESS_VIEW_CONTAINER_LEFT));
    }];
    [self.timeViewContainer updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(_progressViewContainer.left);
        make.top.equalTo(self);
        make.height.equalTo(viewheight);
    }];
    [self.progressDescriptionViewContainer updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(_progressViewContainer.right).with.offset(0);
        make.top.equalTo(self);
        make.height.equalTo(viewheight);
    }];
    
    [super updateConstraints];
}

@end
