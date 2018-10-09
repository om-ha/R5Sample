import UIKit

class MainViewController: UIViewController {

    // Properties
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var contextNameField: UITextField!
    @IBOutlet weak var licenseKeyField: UITextField!
    @IBOutlet weak var streamNameField: UITextField!
    
    // Constants
    public static let kHost = "kHost"
    public static let kPort = "kPort"
    public static let kContextName = "kContextName"
    public static let kLicense = "kLicense"
    public static let kStreamName = "kStreamName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // store red5 config into UITextFields
        hostField.text = UserDefaults.standard.object(forKey: MainViewController.kHost) as? String ?? ""
        portField.text = UserDefaults.standard.object(forKey: MainViewController.kPort) as? String ?? ""
        contextNameField.text = UserDefaults.standard.object(forKey: MainViewController.kContextName) as? String ?? ""
        licenseKeyField.text = UserDefaults.standard.object(forKey: MainViewController.kLicense) as? String ?? ""
        streamNameField.text = UserDefaults.standard.object(forKey: MainViewController.kStreamName) as? String ?? ""
        
        // hard-coded config
        /*
        hostField.text = ""
        portField.text = ""
        contextNameField.text = ""
        licenseKeyField.text = ""
        streamNameField.text = ""
        */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // this is called before presenting publisher/subscriber views
        
        // get red5 config from UITextFields
        let host: String? = hostField.text
        let port: String? = portField.text
        let contextName: String? = contextNameField.text
        let licenseKey: String? = licenseKeyField.text
        let streamName: String? = streamNameField.text
        // save the config to UserDefaults
        UserDefaults.standard.set(host ?? "", forKey: MainViewController.kHost)
        UserDefaults.standard.set(port ?? "", forKey: MainViewController.kPort)
        UserDefaults.standard.set(contextName ?? "", forKey: MainViewController.kContextName)
        UserDefaults.standard.set(licenseKey ?? "", forKey: MainViewController.kLicense)
        UserDefaults.standard.set(streamName ?? "", forKey: MainViewController.kStreamName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
