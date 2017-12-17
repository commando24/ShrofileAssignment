//
//  SAImagePreviewVC.swift
//  ShrofileAssignment
//
//  Created by Surjeet Rajput on 17/12/17.
//  Copyright © 2017 appigizer. All rights reserved.
//

import UIKit

class SAImagePreviewVC: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  
  var image : UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageView.image = image
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissButtonTapped(_:)))
    self.navigationItem.leftBarButtonItem = cancelButton
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func dismissButtonTapped(_ sender : UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
