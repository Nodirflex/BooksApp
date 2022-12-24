//
//  BookItemCell.swift
//  BooksApp
//
//  Created by Nodir on 20/12/22.
//

import UIKit
import Combine

protocol BookItemCellDelegate: AnyObject {
    func didTapFavorite(for id: String)
    func downloadSample(for id: String)
}

final class BookItemCell: UITableViewCell {
    
    static let identifier = "BookItemCell"
    
    private var cancellable: Cancellable?
    
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    private var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.ellipsis, for: .normal)
        button.setTitle("", for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var itemId: String?
    
    weak var delegate: BookItemCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareLayout() {
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(bookImageView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            bookImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
            bookImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2)
        ])
        
        mainStackView.addArrangedSubview(labelsStackView)
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(authorLabel)
        labelsStackView.addArrangedSubview(spacerView)
        
        mainStackView.addArrangedSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 28),
            actionButton.widthAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookImageView.image = nil
        cancellable?.cancel()
        itemId = nil
        actionButton.menu = nil
    }
    
    func configure(with item: VolumeItem, imageService: ImageServiceProtocol) {
        
        self.itemId = item.id
        
        titleLabel.text = item.volumeInfo.title
        authorLabel.text = item.volumeInfo.authors?.joined() ?? ""
        
        cancellable = imageService.fetchImage(for: item.image)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak bookImageView] completion in
                switch completion {
                case .failure:
                    bookImageView?.image = .bookClosed
                default:
                    break
                }
            }, receiveValue: { [weak bookImageView] image in
                bookImageView?.image = image
            })
        
        addActionsForButton(item.isFavorite)
    }
    
    private func addActionsForButton(_ isFavorite: Bool) {
        let title: String = isFavorite ? .localized(.noMoreFavoriteActionTitle) : .localized(.addToFavoriteTitle)
        let image: UIImage? = isFavorite ? .starSlash : .star
        let removeOrAddFavotireAction = UIAction(title: title, image: image) { [weak self] _ in
            guard let itemId = self?.itemId else {
                return
            }
            self?.delegate?.didTapFavorite(for: itemId)
        }
        
        let downloadAction = UIAction(
            title: .localized(.sampleActionTitle),
            image: .arrowshapeTurnUpForward)
        { [weak self] _ in
            guard let itemId = self?.itemId else {
                return
            }
            self?.delegate?.downloadSample(for: itemId)
        }
        
        actionButton.menu = UIMenu(title: "", options: .displayInline, children: [downloadAction, removeOrAddFavotireAction])
    }

}
