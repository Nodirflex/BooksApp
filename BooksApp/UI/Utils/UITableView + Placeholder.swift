//
//  UITableView + Placeholder.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import UIKit

class PlaceholderView: UIView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    private func prepareLayout() {
        
        self.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
}

extension UITableView {
    
    func setPlaceholder() {
        let view = PlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func show(with text: String) {
        let view = subviews.first(where: { $0 is PlaceholderView } ) as? PlaceholderView
        view?.configure(with: text)
        UIView.animate(withDuration: 0.3) {
            view?.alpha = 1
        }
    }
    
    func hide() {
        let view = subviews.first(where: { $0 is PlaceholderView } )
        UIView.animate(withDuration: 0.3) {
            view?.alpha = 0
        }
    }
    
}
