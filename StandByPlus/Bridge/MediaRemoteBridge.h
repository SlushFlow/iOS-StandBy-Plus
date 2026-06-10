#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Command identifiers understood by the private MediaRemote framework.
typedef NS_ENUM(NSInteger, MRBCommand) {
    MRBCommandPlay = 0,
    MRBCommandPause = 1,
    MRBCommandTogglePlayPause = 2,
    MRBCommandStop = 3,
    MRBCommandNextTrack = 4,
    MRBCommandPreviousTrack = 5,
    MRBCommandToggleShuffle = 6,
    MRBCommandToggleRepeat = 7,
};

/// Thin, crash-safe wrapper around Apple's private MediaRemote framework.
///
/// MediaRemote is a private framework, so every symbol is resolved lazily with
/// `dlopen`/`dlsym`. If resolution fails (for example on the simulator, on a
/// future iOS version, or in a sandbox that blocks the framework) the bridge
/// reports `available == NO` and the app falls back to its built-in demo
/// experience. Nothing here links against private symbols directly, so the
/// project always compiles and never crashes on launch.
@interface MediaRemoteBridge : NSObject

+ (instancetype)shared;

/// YES when the MediaRemote framework and required functions were resolved.
@property (nonatomic, readonly) BOOL available;

/// Begin observing the system "now playing" session. The handler is invoked on
/// the main queue whenever the track or playback state changes.
- (void)startWithHandler:(void (^)(NSDictionary * _Nullable info, BOOL isPlaying))handler;

/// Stop observing.
- (void)stop;

/// Force an immediate refresh of the current now-playing info.
- (void)refresh;

/// Send a transport command (play/pause/next/previous/...).
- (void)sendCommand:(MRBCommand)command;

/// Seek the active session to an absolute time, in seconds.
- (void)setElapsedTime:(double)seconds;

@end

NS_ASSUME_NONNULL_END
