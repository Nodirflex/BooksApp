//
//  ViewController.swift
//  BooksApp
//
//  Created by Nodir on 20/12/22.
//

import UIKit
import Combine

final class SearchBookViewController: UIViewController, BookDetailRouter {
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.addTarget(self, action: #selector(searchTyped), for: .editingChanged)
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.searchTextField.delegate = self
        searchBar.placeholder = .localized(.searchPlaceholderText)
        return searchBar
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        return activityIndicator
    }()
    
    private lazy var dataSource = makeDataSource()
    private var subscriptions = Set<AnyCancellable>()
    
    private let viewModel: SearchBooksViewModelProtocol
    private let imageService: ImageServiceProtocol
    
    init(viewModel: SearchBooksViewModelProtocol, imageService: ImageServiceProtocol) {
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
        setupTableView()
        setupBindings()
    }
    
    private func prepareLayout() {
        view.backgroundColor = .white
        title = .localized(.searchTitle)
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(BookItemCell.self, forCellReuseIdentifier: BookItemCell.identifier)
        tableView.setPlaceholder()
    }
    
    private func setupBindings() {
        viewModel.bookItems.sink { [weak self] items in
            self?.update(with: items)
        }.store(in: &subscriptions)
        
        viewModel.reloadItem.sink { [weak self] item in
            self?.reload(item)
        }.store(in: &subscriptions)
        
        viewModel.isFetching.sink { [weak self] isFetching in
            if isFetching {
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }.store(in: &subscriptions)
        
        viewModel.errorMessageSubject.sink { [weak self] message in
            self?.showAlert(with: message)
        }.store(in: &subscriptions)
        
        viewModel.openURLSubject.sink { url in
            UIApplication.shared.open(url)
        }.store(in: &subscriptions)
    }
    
    @objc private func searchTyped(_ sender: UISearchBar) {
        guard let text = sender.text else {
            return
        }
        viewModel.search.send(text)
    }

}

extension SearchBookViewController {
    
    enum Section: CaseIterable {
        case main
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Section, VolumeItem> {
        let dataSource =  UITableViewDiffableDataSource<Section, VolumeItem>(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: BookItemCell.identifier, for: indexPath) as? BookItemCell,
                let self = self
            else {
                return UITableViewCell()
            }
            
            self.viewModel.checkIfFavorite(item: item)
            
            cell.selectionStyle = .none
            cell.configure(with: item, imageService: self.imageService)
            cell.delegate = self
            
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }
    
    func update(with items: [VolumeItem], animate: Bool = true) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, VolumeItem>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items, toSection: .main)
        
        if items.isEmpty {
            var text: String = .localized(.emptyListTitle)
            if searchBar.searchTextField.hasText {
                text = .localized(.emptySearchTitle)
            }
            tableView.show(with: text)
        } else {
            tableView.hide()
        }
        
        dataSource.apply(snapshot, animatingDifferences: animate)
        
    }
    
    func reload(_ item: VolumeItem) {
        var snapshot = dataSource.snapshot()
        if snapshot.indexOfItem(item) != nil {
            snapshot.reloadItems([item])
            dataSource.apply(snapshot)
        }
    }
    
}

extension SearchBookViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.bookItems.value[indexPath.row]
        openBookDetail(item: item)
    }
    
}

// MARK: - BookItemCellDelegate
extension SearchBookViewController: BookItemCellDelegate {
    
    func didTapFavorite(for id: String) {
        viewModel.changeFavoriteState(for: id)
    }
    
    func downloadSample(for id: String) {
        viewModel.openURL(for: id)
    }
    
}

// MARK: - UITextFieldDelegate
extension SearchBookViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
