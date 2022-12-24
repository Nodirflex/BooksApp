//
//  BookDetailViewController.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import UIKit
import Combine

final class BookDetailViewController: UIViewController {
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 24)
        textView.textColor = .darkGray
        return textView
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: BookDetailViewModelProtocol
    private let imageService: ImageServiceProtocol
    
    init(viewModel: BookDetailViewModelProtocol, imageService: ImageServiceProtocol) {
        self.viewModel = viewModel
        self.imageService = imageService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
        setData()
    }
    
    private func prepareLayout() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        navigationController?.navigationBar.prefersLargeTitles = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        stackView.addArrangedSubview(bookImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            bookImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            bookImageView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
    }
    
    private func setData() {
        title = viewModel.item.volumeInfo.title
        titleLabel.text = viewModel.item.volumeInfo.title
        descriptionTextView.text = viewModel.item.volumeInfo.description
        
        imageService.fetchImage(for: viewModel.item.image).sink(receiveCompletion: { [weak bookImageView] completion in
            switch completion {
            case .failure:
                DispatchQueue.main.async {
                    bookImageView?.image = .bookClosed
                }
            default:
                break
            }
        }, receiveValue: { [weak bookImageView] image in
            DispatchQueue.main.async {
                bookImageView?.image = image
            }
        }).store(in: &subscriptions)
    }

}
