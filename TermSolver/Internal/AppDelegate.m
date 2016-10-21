#import "AppDelegate.h"

#import "WindowController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

static WindowController* windowController = nil;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (windowController == nil) {
		windowController = [[WindowController alloc] init];
	}
//	[[windowController window] makeKeyAndOrderFront:windowController];
//	[windowController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

@end
