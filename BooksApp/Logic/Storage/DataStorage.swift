//
//  DataStorage.swift
//  BooksApp
//
//  Created by Nodir on 21/12/22.
//

import CoreData
import Combine

protocol DataStorageServiceProtocol {
    
    var volumeItemsSubject: CurrentValueSubject<[VolumeItemModel], Never> { get }
    
    func save(_ item: VolumeItem) throws
    func fetch() throws
    func delete(for id: String?) throws
}

final class DataStorageService: NSObject, DataStorageServiceProtocol {
    
    private let fetchResultController: NSFetchedResultsController<VolumeItemModel>
    private let persistenceManager = CoreDataService.shared
    
    var volumeItemsSubject = CurrentValueSubject<[VolumeItemModel], Never>([])
    
    
    override init() {
        fetchResultController = NSFetchedResultsController(fetchRequest: VolumeItemModel.objectsFetchRequest,
                                                           managedObjectContext: persistenceManager.viewContext,
                                                           sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        
        fetchResultController.delegate = self
    }
    
    func save(_ item: VolumeItem) throws {
        
        let moc = persistenceManager.viewContext
        
        let savingItem = VolumeItemModel(context: moc)
        savingItem.id = item.id
        savingItem.authors = item.volumeInfo.authors?.joined(separator: ", ")
        savingItem.title = item.volumeInfo.title
        savingItem.isFavorite = item.isFavorite
        savingItem.image = item.image
        savingItem.bookDescription = item.volumeInfo.description
        savingItem.previewLink = item.volumeInfo.previewLink
        
        do {
            try moc.save()
        } catch {
            throw AppError.invalid(.localized(.saveErrorMessage))
        }
    }
    
    func fetch() throws {
        do {
            try fetchResultController.performFetch()
        } catch {
            throw AppError.invalid(.localized(.fetchErrorMessage))
        }
        volumeItemsSubject.send(fetchResultController.fetchedObjects ?? [])
    }
    
    func delete(for id: String?) throws {
        guard let item = volumeItemsSubject.value.first(where: { $0.id == id }) else {
            return
        }
                
        let moc = persistenceManager.viewContext
        
        let managedObjectID = item.objectID
        
        let object = try moc.existingObject(
            with: managedObjectID
        )
        
        moc.delete(object)
        
        do {
            try moc.save()
        } catch {
            throw AppError.invalid(.localized(.deleteErrorMessage))
        }
    }
}

extension DataStorageService: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [VolumeItemModel] else {
            return
        }
        
        volumeItemsSubject.send(items)
    }
    
}

extension VolumeItemModel {
    static var objectsFetchRequest: NSFetchRequest<VolumeItemModel> {
        let request: NSFetchRequest<VolumeItemModel> = VolumeItemModel.fetchRequest()
        request.sortDescriptors = []
        return request
    }
}
