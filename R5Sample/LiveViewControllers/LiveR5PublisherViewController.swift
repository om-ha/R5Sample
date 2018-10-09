import R5Streaming

/// This ViewController handles Publisher's Red5-specific features
class LiveR5PublisherViewController: R5VideoViewController {
    
    // MARK: Dimensions
    #if DEBUG
    static let streamWidth: Int32 = 854
    static let streamHeight: Int32 = 480
    #else
    static let streamWidth: Int32 = 1280
    static let streamHeight: Int32 = 720
    #endif
    
    // MARK: R5 Attributes
    var controller : R5AdaptiveBitrateController? = nil
    var config: R5Configuration = R5Configuration()
    var stream: R5Stream?
    var streamName: String = ""
    var captureDevicePosition: AVCaptureDevicePosition?
    
    // MARK: Live Session Local Recording Attributes
    let isSaveLiveAutosaveOn = false
    var localFileName: String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        let fileName = "LiveSession_" + df.string(from: Date()) + ".mp4"
        return fileName
    }
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // detect when app go to background andback to forground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LiveR5PublisherViewController.applicationWillResignActive),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LiveR5PublisherViewController.applicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        #if DEBUG
        r5_set_log_level((Int32)(r5_log_level_debug.rawValue))
        showDebugInfo(true)
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: R5VideoViewController Orientation
    open override var shouldAutorotate:Bool {
        get {
            return false
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return [UIInterfaceOrientationMask.portrait]
        }
    }
    
    // MARK: Pause & Resume
    func applicationWillResignActive() {
        pauseStream()
    }
    
    // Handle view transition from background
    func applicationDidBecomeActive() {
        resumeStream()
    }
    
    func pauseStream() {
        showPreview(false)
        stream?.pauseVideo = true
        stream?.pauseAudio = true
    }
    
    func resumeStream() {
        showPreview(true)
        stream?.pauseVideo = false
        stream?.pauseAudio = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: start, stop, and local record
extension LiveR5PublisherViewController {
    func setR5Config() {
        config.host = UserDefaults.standard.object(forKey: MainViewController.kHost) as? String ?? ""
        config.port = Int32(UserDefaults.standard.object(forKey: MainViewController.kPort) as? String ?? "") ?? 8554
        config.contextName = UserDefaults.standard.object(forKey: MainViewController.kContextName) as? String ?? ""
        config.licenseKey = UserDefaults.standard.object(forKey: MainViewController.kLicense) as? String ?? ""
        streamName = UserDefaults.standard.object(forKey: MainViewController.kStreamName) as? String ?? ""
        preview()
    }
    
    func preview() {
        // Attach the video from camera to stream
        let cameraDevice : AVCaptureDevice? = getCameraWithPosition(captureDevicePosition ?? AVCaptureDevicePosition.front)
        var camera: R5Camera?
        #if DEBUG
        camera = R5Camera(device: cameraDevice, andBitRate: 1000)/*for 480p: recommended 1000 https://red5pro.zendesk.com/hc/en-us/articles/235679488-Suggested-Resolution-and-Birate-Settings*/
        #else
        camera = R5Camera(device: cameraDevice, andBitRate: 2500)/*for 720p: recommended 2500 https://red5pro.zendesk.com/hc/en-us/articles/235679488-Suggested-Resolution-and-Birate-Settings*/
        #endif
        // Notes: this should be done before publishing starts only
        // Setup the rotation of the video stream.  This is meta data, and is used by the client to rotate the video.  No rotation is done on the publisher.
        camera?.orientation = 90
        // Set up resolution https://red5pro.zendesk.com/hc/en-us/articles/235679488-Suggested-Resolution-and-Birate-Settings
        camera?.width = LiveR5PublisherViewController.streamWidth
        camera?.height = LiveR5PublisherViewController.streamHeight
        // Attach the audio from microphone to stream
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let microphone = R5Microphone(device: audioDevice)
        // setup publisher
        let connection = R5Connection(config: config)
        stream = R5Stream(connection: connection)
        stream?.attachVideo(camera)
        stream?.attachAudio(microphone)
        stream?.delegate = self
        // Attach stream to the controller
        self.attach(stream)
        self.scaleMode = r5_scale_to_fill  //scale to fill and maintain aspect ratio (cropping will occur)
        self.showPreview(true)
    }
    
    // Start stream publishing after setting the config
    public func start() {
        UIApplication.shared.isIdleTimerDisabled = true
        //liveStateDelegate?.onLiveStreamStateChanged(state: .starting)
        //The Adaptive bitrate
        controller = R5AdaptiveBitrateController()
        let _ = controller?.attach(to: self.stream!)
        // online recording & publishing
        if isSaveLiveAutosaveOn {
            // record and publish
            stream?.publish(streamName, type: R5RecordTypeAppend)
            stream?.record(withName: localFileName)
        } else {
            // just publish
            stream?.publish(streamName, type: R5RecordTypeLive)
        }
    }
    
    public func stop() {
        stream?.endLocalRecord()
        stream?.stop()
        stream?.delegate = nil
        stream = nil
        if (controller != nil) {
            controller?.close()
        }
        //preview()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    public func swapCamera() {
        guard let currentCamera = self.stream?.getVideoSource() as? R5Camera else { return }
        let frontCamera : AVCaptureDevice? = getCameraWithPosition(.front)
        let backCamera : AVCaptureDevice? = getCameraWithPosition(.back)
        // swap
        if(currentCamera.device === frontCamera) {
            currentCamera.device = backCamera
            captureDevicePosition = .back
        } else {
            currentCamera.device = frontCamera
            captureDevicePosition = .front
        }
        currentCamera.width = LiveR5PublisherViewController.streamWidth
        currentCamera.height = LiveR5PublisherViewController.streamHeight
    }
    
    public func download() {
        //let tempPath = NSTemporaryDirectory() as String
        //let filePath = tempPath + localFileName
        //let url = URL(fileURLWithPath: filePath)
        //UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, self, #selector(LiveR5PublisherViewController.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject)
    {
        if let _ = error {
            // failure
        } else {
            // success
        }
    }
}

// MARK: R5StreamDelegate
extension LiveR5PublisherViewController: R5StreamDelegate {
    
    func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        //liveStateDelegate?.onR5StatusChanged(r5Status: r5_status(rawValue: r5_status.RawValue(statusCode)))
        let disconnected = (Int(statusCode) == Int(r5_status_disconnected.rawValue))
        let connected = (Int(statusCode) == Int(r5_status_connected.rawValue))
        let connectionError = (Int(statusCode) == Int(r5_status_connection_error.rawValue))
        let started = (Int(statusCode) == Int(r5_status_start_streaming.rawValue))
        let stopped = (Int(statusCode) == Int(r5_status_stop_streaming.rawValue))
        
        if disconnected { print( "********** R5 Status: disconnected")}
        if connected { print( "********** R5 Status: connected") }
        if connectionError { print( "********** R5 Status: connection error") }
        
        if started {
            print( "********** R5 Status: started")
            //liveStateDelegate?.onLiveStreamStateChanged(state: .started)
        }
        if stopped {
            print( "********** R5 Status: stopped")
        }
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
func getCameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice?
{
    if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                         mediaType: AVMediaTypeVideo,
                                                                         position: AVCaptureDevicePosition.unspecified) {
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
    }
    return nil
}
