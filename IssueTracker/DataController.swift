//
//  DataController.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import CoreData


enum SortType: String{
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

class DataController: ObservableObject{
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataConroller = DataController(inMemory: true)
        dataConroller.createSampleData()
        return dataConroller
    }()
    
    
    //Returns all the unselected Tags for suggestion under search as soon as you add a # to search field
    var suggestedFilterTokens: [Tag]{
        guard filterText.starts(with: "#") else { return []}
        
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    
    init(inMemory: Bool = false){
        container = NSPersistentCloudKitContainer(name: "Main")
        
        
        if inMemory{
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        //Automatically syncs data with iCloud
        container.viewContext.automaticallyMergesChangesFromParent = true
        //In memory changes over cloud changes when merge conflict happens
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        //tells us when a change in cloudKit happens
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        //When the change happens pleas call the remoteStoreChanged
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanaged)
        
        container.loadPersistentStores { storeDescription, error in
            if let error{
                fatalError("Fatel error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    
    //Updates the UI and Local data when a chinge in cloudKit happens
    func remoteStoreChanaged(_ notification: Notification){
        objectWillChange.send()
    }
    
    
    func createSampleData(){
        let viewContext = container.viewContext
        
        for i in 1...5{
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"
            
            for j in 1...10{
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i)-\(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        
        try? viewContext.save()
    }
    
    
    //Only saves when there are chnages in the view context
    func save(){
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    
    //Waits three seconds before saving the current task
    func queueSave(){
        saveTask?.cancel()
        
        saveTask = Task{ @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    
    //Delete single element
    func delete(_ object: NSManagedObject){
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    
    //Delete all sample data
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>){
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs //Return the IDs of the elements that got deleted
        
        //Execute the Batch Delete request
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult{
            //Returns the object IDs that were deleted
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            //Merge store into view context so both stay in sync
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    
    
    func deleteAll(){
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        
        save()
    }
    
    
    func missingTags(from issue: Issue) -> [Tag]{
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)
        return difference.sorted()
    }
 
    //Handles the Search and Filter Quereis
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        
        if let tag = filter.tag{
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        }else{
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        
        if trimmedFilterText.isEmpty == false {
            // [c] makes the check case insensitive
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
       
        //Filters out only the elements that contains all of the searchd Tags
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        //Handle Filters
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %@", filterPriority)
                predicates.append(priorityFilter)
            }
            
            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }
        
        
        let request = Issue.fetchRequest()
        //Alows you to chaine a number of predicates together
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues.sorted()
    }
}

