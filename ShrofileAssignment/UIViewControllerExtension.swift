//
//  UIViewControllerExtension.swift
//  ShrofileAssignment
//
//  Created by Surjeet Rajput on 13/12/17.
//  Copyright © 2017 appigizer. All rights reserved.
//

import Foundation
import UIKit

//===================================================================================================
//MARK: - Child-Parent VC
//===================================================================================================
extension UIViewController {
  ///if holderView is nil then self.view is used
  func addChildVC(vc: UIViewController, holderView: UIView? = nil, constraintToHolder: Bool = true) {
    self.addChildViewController(vc)
    var containerView: UIView! = self.view
    if let validView = holderView {
      containerView = validView
    }
    containerView.addSubview(vc.view)
    if constraintToHolder {
      constrainViewEqual(containerView, vc.view)
      vc.view.frame = containerView.bounds
    }
    //    vc.didMove(toParentViewController: self)
  }
  
  func constrainViewEqual(_ holderView: UIView, _ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                    toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
    let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                       toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
    let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                     toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
    let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                      toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
    holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
  }
  
}
