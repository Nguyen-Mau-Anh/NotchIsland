//
//  MediaRemote-Bridging-Header.h
//  NotchIsland
//
//  Bridging header for MediaRemote private framework
//  This allows access to system-wide Now Playing information
//

#ifndef MediaRemote_Bridging_Header_h
#define MediaRemote_Bridging_Header_h

#import <Foundation/Foundation.h>

// MediaRemote Framework - Private API for Now Playing info
// This is what macOS uses internally for Control Center media controls

// Notification names
extern NSString *kMRMediaRemoteNowPlayingInfoDidChangeNotification;
extern NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;

// Now Playing info dictionary keys
extern NSString *kMRMediaRemoteNowPlayingInfoTitle;
extern NSString *kMRMediaRemoteNowPlayingInfoArtist;
extern NSString *kMRMediaRemoteNowPlayingInfoAlbum;
extern NSString *kMRMediaRemoteNowPlayingInfoArtworkData;
extern NSString *kMRMediaRemoteNowPlayingInfoDuration;
extern NSString *kMRMediaRemoteNowPlayingInfoElapsedTime;

// Functions to get Now Playing info
extern void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
extern void MRMediaRemoteUnregisterForNowPlayingNotifications(void);
extern void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, void (^completion)(NSDictionary *info));
extern void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue, void (^completion)(BOOL isPlaying));
extern void MRMediaRemoteGetNowPlayingApplicationPID(dispatch_queue_t queue, void (^completion)(int pid));

// Playback commands
typedef enum : NSUInteger {
    MRMediaRemoteCommandPlay = 0,
    MRMediaRemoteCommandPause = 1,
    MRMediaRemoteCommandTogglePlayPause = 2,
    MRMediaRemoteCommandStop = 3,
    MRMediaRemoteCommandNextTrack = 4,
    MRMediaRemoteCommandPreviousTrack = 5,
} MRMediaRemoteCommand;

extern void MRMediaRemoteSendCommand(MRMediaRemoteCommand command, NSDictionary *userInfo);

#endif /* MediaRemote_Bridging_Header_h */
