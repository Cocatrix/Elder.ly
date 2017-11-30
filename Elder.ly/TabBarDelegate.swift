//
//  TabBarDelegate.swift
//  Elder.ly
//
//  Created by Maxime REVEL on 30/11/2017.
//  Copyright © 2017 Old Mojito. All rights reserved.
//

import Foundation

extension MasterViewController: UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        /**
         * Tab bar items controller :
         * Calls function depending on which tab was clicked
         */
        guard let tabs = self.tabBar.items, tabs.count == 3 else {
            print("Error in getting tab bar items")
            return
        }
        
        switch item {
        case tabs[0]:
            self.displayFavouriteContacts()
        case tabs[1]:
            self.displayAllContacts()
        case tabs[2]:
            self.displayFrequentContacts()
        default:
            print("default: error")
        }
    }
    
    func displayFavouriteContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest to reset some settings, and get favourites only :
         * - no fetchLimitNumber
         * - sorted by first name, then last name
         * - predicate to display favourite contacts only
         */
        guard let frc = self.resultController else {
            return
        }
        // Reset fetch limit number
        frc.fetchRequest.fetchLimit = 0
        
        // Get predicate corresponding to favourite
        let scdProvider = SearchCoreDataProvider.sharedInstance
        let favouritePredicate = scdProvider.getFavouritePredicate()
        frc.fetchRequest.predicate = favouritePredicate
        
        // Sort by first name, then by last name
        frc.fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
    
    func displayAllContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest to reset default settings :
         * - no fetchLimitNumber
         * - sorted by first name, then last name
         * - no predicate
         */
        guard let frc = self.resultController else {
            return
        }
        // Reset fetch limit number
        frc.fetchRequest.fetchLimit = 0
        
        // Sort by first name, then by last name
        let scdProvider = SearchCoreDataProvider.sharedInstance
        frc.fetchRequest.sortDescriptors = scdProvider.getDefaultSortDescriptor()
        
        // Reset predicate
        frc.fetchRequest.predicate = nil
        
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
    
    func displayFrequentContacts() {
        /**
         * Gets fetchResultsController and update its fetchRequest with :
         * - a fetchLimitNumber
         * - sorted by frequency, then first name, then last name
         * - no predicate
         */
        guard let frc = self.resultController else {
            return
        }
        // Set fetch limit number
        let fetchLimitNumber = 5
        frc.fetchRequest.fetchLimit = fetchLimitNumber
        
        // Sort by frequency, then by first name, then by last name
        let scdProvider = SearchCoreDataProvider.sharedInstance
        frc.fetchRequest.sortDescriptors = scdProvider.getFrequentSortDescriptor()
        
        // Reset predicate
        frc.fetchRequest.predicate = nil
        
        // Perform fetch and reload data
        try? frc.performFetch()
        self.tableView.reloadData()
    }
}
