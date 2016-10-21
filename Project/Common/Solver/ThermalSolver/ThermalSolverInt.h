#import <Foundation/Foundation.h>

@class LayerModelInt;
@class TSParamsInt;


struct ThermalSolverImpl;


@interface ThermalSolverInt : NSObject {
@public
	struct ThermalSolverImpl *impl;
}

@property (nonatomic, readonly) NSArray *layers;
@property (nonatomic) TSParamsInt *params;


+ (instancetype)sharedTermalSolver;

- (void)addLayer:(LayerModelInt *)layer;

- (void)show;

- (NSArray *)data;

#pragma mark - C++ methods
- (void)initSolver;
- (void)solve:(int)t;

@end
