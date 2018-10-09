import R5Streaming

/// This ViewController handles Subscriber's Red5-specific features
class LiveR5SubscriberViewController: R5VideoViewController {
    
    // MARK: R5 Attributes
    var config: R5Configuration = R5Configuration()
    var stream: R5Stream?
    var streamName: String = ""
    
    // Reconnect
    var shouldReconnect = false
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldReconnect = true
        #if DEBUG
        r5_set_log_level((Int32)(r5_log_level_debug.rawValue))
        self.showDebugInfo(true)
        #endif
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
}

extension LiveR5SubscriberViewController {
    
    func setR5Config() {
        config.host = UserDefaults.standard.object(forKey: MainViewController.kHost) as? String ?? ""
        config.port = Int32(UserDefaults.standard.object(forKey: MainViewController.kPort) as? String ?? "") ?? 8554
        config.contextName = UserDefaults.standard.object(forKey: MainViewController.kContextName) as? String ?? ""
        config.licenseKey = UserDefaults.standard.object(forKey: MainViewController.kLicense) as? String ?? ""
        streamName = UserDefaults.standard.object(forKey: MainViewController.kStreamName) as? String ?? ""
    }
    
    public func start() {
        let connection = R5Connection(config: config)
        stream = R5Stream(connection: connection)
        stream?.delegate = self
        self.attach(stream)
        self.scaleMode = r5_scale_to_fill  //scale to fill and maintain aspect ratio (cropping will occur)
        stream?.play(streamName)
    }
    
    public func stop() {
        shouldReconnect = false
        stream?.stop()
    }
}

// MARK: Reconnection
extension LiveR5SubscriberViewController: R5StreamDelegate {
    func onR5StreamStatus(_ stream: R5Stream!, withStatus statusCode: Int32, withMessage msg: String!) {
        //liveStateDelegate?.onR5StatusChanged(r5Status: r5_status(rawValue: r5_status.RawValue(statusCode)))
        let disconnected = (Int(statusCode) == Int(r5_status_disconnected.rawValue))
        let connected = (Int(statusCode) == Int(r5_status_connected.rawValue))
        let connectionError = (Int(statusCode) == Int(r5_status_connection_error.rawValue))
        let started = (Int(statusCode) == Int(r5_status_start_streaming.rawValue))
        let stopped = (Int(statusCode) == Int(r5_status_stop_streaming.rawValue))
        
        if disconnected { print( "********** R5 Status: disconnected")}
        if connected { print( "********** R5 Status: connected") }
        if (connectionError) { print( "********** R5 Status: connection error") }
        
        if started {
            print( "********** R5 Status: started")
            //liveStateDelegate?.onLiveStreamStateChanged(state: .started)
        }
        if stopped {
            print( "********** R5 Status: stopped")
        }
        if connectionError {
            print( "********** R5 Status: reconnecting")
            reconnect()
        } else if (statusCode == Int32(r5_status_netstatus.rawValue) && msg == "NetStream.Play.UnpublishNotify") {
            // reconnect
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if(self.stream != nil) {
                    self.stream?.stop()
                    self.attach(nil)
                    self.stream = nil
                }
                self.reconnect()
            }
            */
        }
        
    }
    
    func reconnect () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.shouldReconnect {
                return
            }
            self.validateStream()
        }
    }
    
    func validateStream() {
        DispatchQueue.main.async {
            self.setR5Config()
            self.start()
        }
    }
}
