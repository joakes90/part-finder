# Part Finder

This is a proof of concept application the uses Vision and CoreML frameworks to detect, turn signals, start buttons and mannetenos in Ferrari 458, 488 and parts of some other models like the F430's steering wheel. 

The majority of the work to do this can be found in `CameraViewController+AVCaptureVideoDataOutputSampleBufferDelegate` with comments explaining most of the parts. 

Right now detected items are only listed on a label due to time restrictions, but future versions could highlight where theses items are in the video preview.
