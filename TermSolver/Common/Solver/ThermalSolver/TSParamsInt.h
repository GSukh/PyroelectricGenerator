#import <Foundation/Foundation.h>


struct TSParamsImpl;
@interface TSParamsInt : NSObject {
@public
	struct TSParamsImpl *impl;
}

@property (nonatomic) float dt;
@property (nonatomic) int per;
@property (nonatomic) int Nper;
@property (nonatomic) int NHeat;
@property (nonatomic) int NHeatDispl;

@property (nonatomic) int s;
@property (nonatomic) int power;

@end
