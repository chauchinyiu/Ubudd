//
//  SCMediaManager.h
//  C2Call SDK
//
//  Created by Michael Knecht on 20.06.13.
//  Copyright 2013 C2Call GmbH. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/** The SCMediaManager class is the shared instance for managing video capture sessions.
 
 The SCMediaManager class can be controlled by the application in order to hook into a video capture session during a video call and to receive the captured frames for further processing like face recognition.
 The C2Call SDK video call subsystem uses this class to request a capture session and register a AVCaptureVideoDataOutputSampleBufferDelegate. 
 Up to two AVCaptureVideoDataOutputSampleBufferDelegate can be registered for a video capture session.
 It's important that any additional video frame processing should be fast enough to allow a smoth video call with 10 - 20 frames per second. 
 Video frames consume a lot of memory. Please don't forget to run a profiler session on any additional video processing in order to detect potential memory leaks.

 */

@interface SCMediaManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

/** @name Properties */
/** Returns the current active video capture device (front or rear camera) */
@property(nonatomic, readonly) AVCaptureDevice      *videoCaptureDevice;

/** Returns the current active video capture session */
@property(nonatomic, readonly) AVCaptureSession     *videoCaptureSession;

@property(nonatomic, readonly) AVCaptureDevicePosition cameraPosition;

/** Disable internal video capture session management 
 This option allows to setup and run the video capture session externally, in order to use tools like GPUImage for video image processing.
 The developer is then responsible  to call

 [[SCMediaManager instance] captureOutput:didOutputSampleBuffer:fromConnection:]
 
 with the processed video data for submission.
 */
@property(nonatomic) BOOL useExternalVideoCapture;

/** Add a VideoDataOutput Delegate to the current capture session.
 
 If the capture session is already running, the delegate will be simply added and called for every available video frame;
 If the session is not running it can be started with startVideoCapture.
 Every delegate should stop only its own capture session, using stopVideoCaptureForDelegate.
 This also removes the delegate. 
 
 Stop all video output with stopVideoCapture. All delegates will be removed.
 
 @param delegate - The AVCaptureVideoDataOutputSampleBufferDelegate
 @return YES if delegate has been added, NO if max delegates have been reached.
 */
-(BOOL) addVideoDataOutputDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>) delegate;

/** Is front camera available.
 @return YES / NO
 */
-(BOOL) hasFrontCamera;

/** Is rear camera available.
 @return YES / NO
 */
-(BOOL) hasRearCamera;



/** Switch between cameras
 
 AVCaptureDevicePositionUnspecified stops the capture output temporary.
 
 @param The selected camera device
 @return Returns the new device or the old device if the camera couldn't be changed.
 */
-(AVCaptureDevicePosition) switchCamera:(AVCaptureDevicePosition) camera;

/** Returns the previewLayer.
 @return The camera preview layler.
 */
-(AVCaptureVideoPreviewLayer *) previewLayer;

/** @name Media Capture Handling */
/** Start Video Capture
 
 Does nothing if the session is already running.
 */
-(void) startVideoCapture;

/** Stop video capture for a specific delegate.
 
 The delegate will be removed. If it's the last delegate, the capture session will be stopped.
 
 @param delegate - The delegate to remove.
 */
-(void) stopVideoCaptureForDelegate:(id) delegate;

/** Remove all delegates and stop the capture session.
 */
-(void) stopVideoCapture;

/** Start a screenSharing session during an active video call
 
 @param shareView The view to be shared
 */
-(void) startScreenSharingForView:(UIView *) shareView;

/** Stop active screenSharing session
 
 */
-(void) stopScreenSharing;


/** Start Recording of the current MediaStream
 
 */
-(void) startMediaRecording;

/** Stop recording of the current media stream
 
 @param handler - The completion handler will be called with the mediaKey as parameter after completion
 */
-(void) stopMediaRecordingWithCompletionHandler:(void (^)(NSString *mediaKey))handler;

/** Start ScreenCapture Recording of the provided UIView
 
 The provide view will be recorded as screen capture session into an MP4 video file.
 The view will be recorded with 10 frames / second.
 
 @param captureView - The view to be captured and recorded
 @param useAudio - Capture Audio from the microphone
 
 */
-(void) startScreenCaptureForView:(UIView *) captureView usingAudio:(BOOL) useAudio;

/** Stop recording of the current screen capture session
 
 @param handler - The completion handler will be called with the mediaKey as parameter after completion
 */

-(void) stopScreenCaptureWithCompletionHandler:(void (^)(NSString *mediaKey))handler;

/** Disable Audio / Video output while a capture session is running
 
 This is a global setting which will keep it's setting between 2 calls
 @param disable - Set YES to disable the Audio Video output, NO to re-enable
 */
-(void) disableMediaOutput:(BOOL) disable;

/** Disable Video output while a capture session is running

 This is a global setting which will keep it's setting between 2 calls

@param disable - Set YES to pause the Video output, NO to re-enable
*/
-(void) disableVideoOutput:(BOOL) disable;

/** Disable Audio output while a capture session is running

 This is a global setting which will keep it's setting between 2 calls

@param disable - Set YES to pause the Audio output, NO to re-enable
*/
-(void) disableAudioOutput:(BOOL) disable;

/** @name AVCaptureConnection properties */

/** A Boolean value that indicates whether the system should enable video stabilization when it is available.
 @param enable - Set to YES for enabling
 */
-(void) setVideoStabilizationWhenAvailable:(BOOL) enable;

/** The orientation of the video.

@see AVCaptureConnection videoOriantation

@param enable - The orientation
*/
-(void) setOrientation:(AVCaptureVideoOrientation) orientation;

/** Capture the current preview image
 
 Capture a still image recorded by the camera during a video call.
 
 @param handler - The completion handler
 */
-(void) capturePreviewImageWithCompletionHandler:(void (^)(UIImage *image, NSError *error))handler;


/** Experimental, for internal use only
 
 Directly transfer YUV encoded data
 
 @param yPtr - ptr to Y data
 @param uPtr - ptr to U data
 @param vPtr - ptr to V data
 @param width - image width
 @param height - image height
 @param rotate - [0 .. 3] : rotate image 0, 90, 180 and 270 degrees
 */

-(void) encodeAndTransferYUV:(UInt8 *) yPtr u:(UInt8 *)uPtr v:(UInt8 *)vPtr width:(int) width height:(int) height rotate:(int) rotate;

/** Returns the next decoded video frame in YUV420 format
 
 The method will wait for the next frame and returns it in YUV420 format including size and rotation metadata
 
 Dictionary Keys:
    frame : NSData - The Frame data
    width : NSNumber - Image width
    height : NSNumber - Image height
    rotation : NSNumber - Rotation Value (0 - 3)
 
 IMPORTANT: Process the frame data before retrieving the next frame.
 The data buffer takes always only one frame and will be overwritten with the next frame
 
 @return dictionary with frame data or nil
 */
-(NSDictionary *) getDecodedVideoFrame;

/** @name Static Methods */
/** Returns a share instance of SCMediaManager.
 
 @return The media manager.
 */
+(SCMediaManager *) instance;

/** Set the Default CaptureSession Preset
 
 SCMediaManager uses AVCaptureSessionPresetMedium when creating the AVCaptureSession by default.
 Use setDefaultCaptureSessionPreset: before accessing the instace first time to change the default capture session preset.
 
 @param preset - AVCaptureSessionPreset
 */
+(void) setDefaultCaptureSessionPreset:(NSString *) preset;

@end
