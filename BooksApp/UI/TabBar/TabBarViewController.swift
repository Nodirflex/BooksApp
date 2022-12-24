//
//  TabBarViewController.swift
//  BooksApp
//
//  Created by Nodir on 21/12/22.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers(viewControllers, animated: false)
    }

}

