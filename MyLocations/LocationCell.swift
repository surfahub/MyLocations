//
//  LocationCell.swift
//  MyLocations
//
//  Created by Surfa on 15.08.2021.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(for location: Location){
        
        descriptionLabel.text = location.locationDescription != "" ? location.locationDescription : "(No Description)"
        
        
        if let placemark = location.placemark{
            var txt = ""
            
            txt.add(text: placemark.subThoroughfare)
            txt.add(text: placemark.thoroughfare, separatedBy: " ")
            txt.add(text: placemark.locality, separatedBy: ", ")

            addressLabel.text = txt
        }else {
            addressLabel.text = String(format: "Lat: %.8f, Long %.8f", location.latitude,location.longitude)
        }
        
        
        photoImageView.image = thumbnail(for: location)
    }
    
    func thumbnail(for location: Location) -> UIImage {
      if location.hasPhoto, let image = location.photoImage {
        return image.resize(withBounds: CGSize(width: 52, height: 52))
      }else {
        return UIImage(named: "No Photo")!
      }
      return UIImage()
    }
    
}
