//
//  UIViewController + Alert.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import UIKit.UIViewController

extension UIViewController {
    
    func showAlert(with message: String) {
        let alertVC = UIAlertController(title: .localized(.errorTitle), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: .localized(.okTitle), style: .default)
        
        alertVC.addAction(okAction)
        
        present(alertVC, animated: true)
    }
    
}
