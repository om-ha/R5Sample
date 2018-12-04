import UIKit

class MainViewController: UIViewController {

    // Properties
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var contextNameField: UITextField!
    @IBOutlet weak var licenseKeyField: UITextField!
    @IBOutlet weak var streamNameField: UITextField!
    @IBOutlet weak var localRecordSwitch: UISwitch!
    
    // Constants
    public static let kHost = "kHost"
    public static let kPort = "kPort"
    public static let kContextName = "kContextName"
    public static let kLicense = "kLicense"
    public static let kStreamName = "kStreamName"
    public static let kLocalRecord = "kLocalRecord"
    static let kDefaultHost = ""
    static let kDefaultPort = "8554"
    static let kDefaultContextName = "rombeye-dev"
    static let kDefaultStreamName = "liveStream1"
    static let kDefaultLocalRecord = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // store red5 config into UITextFields
        hostField.text = UserDefaults.standard.object(forKey: MainViewController.kHost) as? String ?? MainViewController.kDefaultHost
        portField.text = UserDefaults.standard.object(forKey: MainViewController.kPort) as? String ?? MainViewController.kDefaultPort
        contextNameField.text = UserDefaults.standard.object(forKey: MainViewController.kContextName) as? String ?? MainViewController.kDefaultContextName
        licenseKeyField.text = UserDefaults.standard.object(forKey: MainViewController.kLicense) as? String ?? ""
        streamNameField.text = UserDefaults.standard.object(forKey: MainViewController.kStreamName) as? String ?? MainViewController.kDefaultStreamName
        localRecordSwitch.isOn = UserDefaults.standard.object(forKey: MainViewController.kLocalRecord) as? Bool ?? MainViewController.kDefaultLocalRecord
        
        // hard-coded config
        /*
        hostField.text = ""
        portField.text = ""
        contextNameField.text = ""
        licenseKeyField.text = ""
        streamNameField.text = ""
        localRecordSwitch.isOn = false
        */
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
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
        let localRecord: Bool? = localRecordSwitch.isOn
        // save the config to UserDefaults
        UserDefaults.standard.set(host ?? "", forKey: MainViewController.kHost)
        UserDefaults.standard.set(port ?? "", forKey: MainViewController.kPort)
        UserDefaults.standard.set(contextName ?? "", forKey: MainViewController.kContextName)
        UserDefaults.standard.set(licenseKey ?? "", forKey: MainViewController.kLicense)
        UserDefaults.standard.set(streamName ?? "", forKey: MainViewController.kStreamName)
        UserDefaults.standard.set(streamName ?? "", forKey: MainViewController.kStreamName)
        UserDefaults.standard.set(localRecord ?? "", forKey: MainViewController.kLocalRecord)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
