//
//  FavoritesViewController.swift
//  BooksApp
//
//  Created by Nodir on 20/12/22.
//

import UIKit
import Combine

final class FavoritesViewController: UIViewController, BookDetailRouter {
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var dataSource = makeDataSource()
    private let viewModel: BooksViewModelProtocol
    private let imageService: ImageServiceProtocol
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: BooksViewModelProtocol, imageService: ImageServiceProtocol) {
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
        title = .localized(.favoritesTitle)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
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
        
        viewModel.errorMessageSubject.sink { [weak self] message in
            self?.showAlert(with: message)
        }.store(in: &subscriptions)
        
        viewModel.openURLSubject.sink { url in
            UIApplication.shared.open(url)
        }.store(in: &subscriptions)
    }

}

extension FavoritesViewController {
    
    enum Section: Int, CaseIterable {
        case main
        case placeholder
    }
    
    func makeDataSource() -> UITableViewDiffableDataSource<Section, AnyHashable> {
        let dataSource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { [weak self] tableView, indexPath, item in
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: BookItemCell.identifier, for: indexPath) as? BookItemCell,
                let self = self, let model = item as? VolumeItem
            else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            cell.configure(with: model, imageService: self.imageService)
            cell.delegate = self
            return cell
            
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }
    
    func update(with items: [VolumeItem], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items, toSection: .main)
        
        if items.isEmpty {
            tableView.show(with: .localized(.emptyListTitle))
        } else {
            tableView.hide()
        }

        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.bookItems.value[indexPath.row]
        openBookDetail(item: item)
    }
    
}

// MARK: - BookItemCellDelegate
extension FavoritesViewController: BookItemCellDelegate {
    
    func didTapFavorite(for id: String) {
        viewModel.changeFavoriteState(for: id)
    }
    
    func downloadSample(for id: String) {
        viewModel.openURL(for: id)
    }
    
}
