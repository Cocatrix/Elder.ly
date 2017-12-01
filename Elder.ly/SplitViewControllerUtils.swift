//
//  SplitViewControllerUtils.swift
//  Elder.ly
//
//  Created by Arnaud on 01/12/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

// ONLY USE WITH THA APPLE MASTER DETAILS VIEW CONTROLLER
extension UISplitViewController {
    
    func popToMasterViewController() {
        if isCollapsed {
            (self.viewControllers[0] as? UINavigationController)?.popViewController(animated: true)
        }
    }
    
}
