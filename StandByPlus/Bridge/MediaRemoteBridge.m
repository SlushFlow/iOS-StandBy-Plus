#import "MediaRemoteBridge.h"
#import <dlfcn.h>

// Function pointer typedefs matching the private MediaRemote ABI.
typedef void (*MRGetNowPlayingInfoFn)(dispatch_queue_t queue, void (^handler)(NSDictionary * _Nullable info));
typedef void (*MRRegisterForNotificationsFn)(dispatch_queue_t queue);
typedef void (*MRUnregisterForNotificationsFn)(void);
typedef void (*MRGetIsPlayingFn)(dispatch_queue_t queue, void (^handler)(Boolean isPlaying));
typedef Boolean (*MRSendCommandFn)(int command, NSDictionary * _Nullable userInfo);
typedef void (*MRSetElapsedTimeFn)(double time);

static NSString *MRBStringConstant(void *handle, const char *symbol, NSString *fallback) {
    CFStringRef *ref = (CFStringRef *)dlsym(handle, symbol);
    if (ref != NULL && *ref != NULL) {
        return (__bridge NSString *)(*ref);
    }
    return fallback;
}

@interface MediaRemoteBridge ()
@property (nonatomic, assign) BOOL available;
@property (nonatomic, copy, nullable) void (^handler)(NSDictionary * _Nullable, BOOL);

@property (nonatomic, assign) MRGetNowPlayingInfoFn getInfo;
@property (nonatomic, assign) MRRegisterForNotificationsFn registerNotifications;
@property (nonatomic, assign) MRUnregisterForNotificationsFn unregisterNotifications;
@property (nonatomic, assign) MRGetIsPlayingFn getIsPlaying;
@property (nonatomic, assign) MRSendCommandFn sendCommandFn;
@property (nonatomic, assign) MRSetElapsedTimeFn setElapsedFn;

@property (nonatomic, copy, nullable) NSString *infoChangedName;
@property (nonatomic, copy, nullable) NSString *isPlayingChangedName;
@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL lastIsPlaying;
@end

@implementation MediaRemoteBridge

+ (instancetype)shared {
    static MediaRemoteBridge *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MediaRemoteBridge alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resolveSymbols];
    }
    return self;
}

- (void)resolveSymbols {
    void *handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY);
    if (handle == NULL) {
        self.available = NO;
        return;
    }

    self.getInfo = (MRGetNowPlayingInfoFn)dlsym(handle, "MRMediaRemoteGetNowPlayingInfo");
    self.registerNotifications = (MRRegisterForNotificationsFn)dlsym(handle, "MRMediaRemoteRegisterForNowPlayingNotifications");
    self.unregisterNotifications = (MRUnregisterForNotificationsFn)dlsym(handle, "MRMediaRemoteUnregisterForNowPlayingNotifications");
    self.getIsPlaying = (MRGetIsPlayingFn)dlsym(handle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying");
    self.sendCommandFn = (MRSendCommandFn)dlsym(handle, "MRMediaRemoteSendCommand");
    self.setElapsedFn = (MRSetElapsedTimeFn)dlsym(handle, "MRMediaRemoteSetElapsedTime");

    self.infoChangedName = MRBStringConstant(handle,
        "kMRMediaRemoteNowPlayingInfoDidChangeNotification",
        @"kMRMediaRemoteNowPlayingInfoDidChangeNotification");
    self.isPlayingChangedName = MRBStringConstant(handle,
        "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification",
        @"kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification");

    self.available = (self.getInfo != NULL && self.registerNotifications != NULL);
}

- (void)startWithHandler:(void (^)(NSDictionary * _Nullable, BOOL))handler {
    self.handler = handler;
    if (!self.available) {
        return;
    }

    if (!self.observing) {
        self.registerNotifications(dispatch_get_main_queue());
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:self.infoChangedName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:self.isPlayingChangedName
                                                   object:nil];
        self.observing = YES;
    }
    [self refresh];
}

- (void)stop {
    if (self.observing) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (self.unregisterNotifications != NULL) {
            self.unregisterNotifications();
        }
        self.observing = NO;
    }
    self.handler = nil;
}

- (void)handleNotification:(NSNotification *)note {
    [self refresh];
}

- (void)refresh {
    if (!self.available) {
        return;
    }

    __weak typeof(self) weakSelf = self;

    if (self.getIsPlaying != NULL) {
        self.getIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {
            weakSelf.lastIsPlaying = isPlaying ? YES : NO;
        });
    }

    self.getInfo(dispatch_get_main_queue(), ^(NSDictionary * _Nullable info) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf == nil || strongSelf.handler == nil) {
            return;
        }
        strongSelf.handler(info, strongSelf.lastIsPlaying);
    });
}

- (void)sendCommand:(MRBCommand)command {
    if (self.sendCommandFn != NULL) {
        self.sendCommandFn((int)command, nil);
    }
}

- (void)setElapsedTime:(double)seconds {
    if (self.setElapsedFn != NULL) {
        self.setElapsedFn(seconds);
    }
}

@end
