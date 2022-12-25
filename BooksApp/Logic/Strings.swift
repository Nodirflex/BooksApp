//
//  Strings.swift
//  BooksApp
//
//  Created by Nodir on 24/12/22.
//

import Foundation

enum Strings: String {
    case searchTitle = "search_title"
    case favoritesTitle = "favorites_title"
    case emptyListTitle = "empty_list_title"
    case emptySearchTitle = "empty_search_title"
    case errorTitle = "error_title"
    case okTitle = "ok_title"
    case saveErrorMessage = "save_error_message"
    case fetchErrorMessage = "fetch_error_message"
    case deleteErrorMessage = "delete_error_message"
    case sampleActionTitle = "sample_action_title"
    case noMoreFavoriteActionTitle = "no_more_favorite_action_title"
    case addToFavoriteTitle = "add_to_favorite_title"
    case invalidOpenFragmentUrl = "invalid_open_fragment_url"
}

extension String {
    static func localized(_ strings: Strings) -> String {
        let localizedString = NSLocalizedString(strings.rawValue, comment: "")
        return String(format: localizedString)
    }
}
