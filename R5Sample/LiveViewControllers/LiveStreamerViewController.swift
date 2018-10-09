import AVKit
import UIKit
import R5Streaming

/// This ViewController handles Publisher UI and App-Specific features
class LiveStreamerViewController: UIViewController {
    // MARK: Properties
    // R5
    var r5Publisher: LiveR5PublisherViewController?
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.publishVideoStream()
        }
    }
    
    func publishVideoStream() {
        r5Publisher?.setR5Config()
        r5Publisher?.start()
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        r5Publisher?.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation & Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextScene = segue.destination as? LiveR5PublisherViewController {
            r5Publisher = nextScene
        }
    }
}
