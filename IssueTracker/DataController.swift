//
//  DataController.swift
//  IssueTracker
//
//  Created by Joel Storr on 24.10.23.
//

import CoreData


class DataController: ObservableObject{
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataConroller = DataController(inMemory: true)
        dataConroller.createSampleData()
        return dataConroller
    }()
    
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
    
    
}

