import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var photoLabel:UILabel!
    @IBOutlet var imageView:UIImageView!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.isHidden = false
            photoLabel.text = ""
            imageHeight.constant = 260
            tableView.reloadData()
            // 1.5 = 3 / 2
            if let image = self.image{
                let aspectRatio = Int(image.size.width) / Int(image.size.height)
                let aspectAfterCheck = aspectRatio == 0 ? 1 : aspectRatio
                addPhotoCellHeight = Int(260 / aspectAfterCheck)
            }
            
        }
    }
    var addPhotoCellHeight = 44
    
    var editLocation: Location? {
        didSet{
            if let location = editLocation{
                descriptionText = location.locationDescription
                categoryName = location.category
                coordinate = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude)
                placemark = location.placemark
                date = location.date
            }
        }
    }
    var descriptionText = ""
    var observer: Any!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    
    var categoryName = "No Category"
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    private let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        print("check")
        return formatter
    }()
    
    func format(date: Date) -> String{
        return dateFormatter.string(from: date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenToBackgroundNotifications()
        
        if let location = editLocation{
            title = "Edit Location"
            if location.hasPhoto{
                if let theImage = location.photoImage{
                    show(image: theImage)
                }
                
            }
        }
        descriptionTextView.text = descriptionText
        
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark{
            addressLabel.text = string(from: placemark)
        }else {
            addressLabel.text = "No address found"
        }
        
        dateLabel.text = format(date: date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
    }
    deinit{
        print("*** Doing DEINIT ] \(self)")
        NotificationCenter.default.removeObserver(observer!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2{
            return indexPath
        }else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            
            descriptionTextView.becomeFirstResponder()
        }else if indexPath.section == 2 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return CGFloat(140)
            
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            return CGFloat(addPhotoCellHeight)
        }else if indexPath.section == 3 && indexPath.row == 2{
            return CGFloat(60)
        }else {
            return CGFloat(44)
        }
        
    }
    override func didReceiveMemoryWarning() {
        print("*****!!!!******!!!!!!!*******!!!! LOW MEMORY!!!!")
    }
    
    
    // MARK: - Helper methods
    func string(from placemark: CLPlacemark) -> String{
        
        var text = ""
        text.add(text: placemark.subThoroughfare)
        text.add(text: placemark.thoroughfare, separatedBy: " ")
        text.add(text: placemark.locality, separatedBy: "\n")
        text.add(text: placemark.administrativeArea, separatedBy: ", ")
        text.add(text: placemark.postalCode, separatedBy: ", ")
        text.add(text: placemark.country, separatedBy: "\n")
        
        return text
    }
    
    func listenToBackgroundNotifications(){
        observer = NotificationCenter.default.addObserver(
            forName: UIScene.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main){[weak self] _ in
            if let weakSelf = self{
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: true, completion: nil)
                }
                weakSelf.descriptionTextView.resignFirstResponder()
                
            }
            
        }
        
    }
    // MARK: - Actions
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view else {return}
        let hudView = HudView.hud(inView: mainView, animated: true)
        
        let location: Location
        if let tmp = editLocation{
            hudView.text = "Updated"
            location = tmp
        }else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            if let data = image.jpegData(compressionQuality: 0.5){
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                }catch {
                    print("Error writing file:" + error.localizedDescription)
                }
            }
        }
        
        do{
            try managedObjectContext.save()
            afterDelay(0.6){
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
            
        }catch{
            fatalCoreDataError(error)
        }
        
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory"{
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    
    // MARK: - Hide Keyboard
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
        
    }
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        photoLabel.text = ""
        
        
        let aspectRatio = Int(image.size.width) / Int(image.size.height)
        let aspectAfterCheck = aspectRatio == 0 ? 1 : aspectRatio
        addPhotoCellHeight = Int(260 / aspectAfterCheck)
        
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // MARK: - Image Helper Methods
    
    
    func pickPhoto(){
        if true || UIImagePickerController.isSourceTypeAvailable(.camera){
            showPhotoMenu()
        }else {
            choosePhotoFromLIbrary()
        }
    }
    
    func showPhotoMenu(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default){
            _ in self.takePhotoWithCamera()
        }
        alert.addAction(actPhoto)
        let actMedia = UIAlertAction(title: "Choose From Library", style: .default){
            _ in self.choosePhotoFromLIbrary()
        }
        alert.addAction(actMedia)
        
        present(alert, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLIbrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
