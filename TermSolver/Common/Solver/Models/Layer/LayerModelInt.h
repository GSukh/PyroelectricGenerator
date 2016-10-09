#import <Foundation/Foundation.h>

//#define kLayerHeight				@"height"
//#define kLayerSteps					@"steps"
//#define kLayerThermalConductivity	@"thermalConductivity"
//#define kLayerThermalDiffusivity	@"thermalDiffusivity"


struct LayerImpl;

@interface LayerModelInt : NSObject {
@public
	struct LayerImpl *impl;
}

@property (nonatomic) float height;
@property (nonatomic) int Nx;
@property (nonatomic) float thermalConductivity;
@property (nonatomic) float thermalDiffusivity;

@property (nonatomic) float startTemp;

@property (nonatomic) float dx;

- (void)show;

@end