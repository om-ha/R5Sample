import UIKit
import R5Streaming

/// This ViewController handles Subscriber UI and App-Specific features
class LivePlayerViewController: UIViewController {
    
    // MARK: Properties
    // R5
    var r5Player: LiveR5SubscriberViewController?
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.playVideoStream()
        }
    }
    
    func playVideoStream() {
        r5Player?.setR5Config()
        r5Player?.start()
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        r5Player?.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation & Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextScene = segue.destination as? LiveR5SubscriberViewController {
            r5Player = nextScene
        }
    }
}
