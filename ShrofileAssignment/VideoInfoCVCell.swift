//
//  VideoInfoCVCell.swift
//  ShrofileAssignment
//
//  Created by Surjeet Rajput on 13/12/17.
//  Copyright © 2017 appigizer. All rights reserved.
//

import UIKit

class VideoInfoCVCell: UICollectionViewCell {
 
  
  @IBOutlet weak var titleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.black.cgColor
  }
  
  func customizeForTitle(_ title : String, isSelected : Bool) {
    titleLabel.text = title
    if isSelected {
      self.backgroundColor = UIColor.white
      titleLabel.textColor = UIColor.darkGray
    }else {
      self.backgroundColor = UIColor.darkGray
      titleLabel.textColor = UIColor.white
    }
  }
  
}
