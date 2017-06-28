//
//  LibraryListViewController.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 15/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import MagicalRecord
import MBProgressHUD

class LibraryListViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    internal var fetchController: NSFetchedResultsController<UploadedVideo>!
    internal var creationDateFormatter: DateFormatter!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM, dd yyyy - HH:mm:ss"
        self.creationDateFormatter = formatter
        
        let sortByDateDesc = NSSortDescriptor(key: "creationDate", ascending: false)
        let fetchRequest = NSFetchRequest<UploadedVideo>(entityName: "UploadedVideo")
        fetchRequest.sortDescriptors = [sortByDateDesc]
        
        self.fetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest
            , managedObjectContext: NSManagedObjectContext.mr_default()
            , sectionNameKeyPath: nil
            , cacheName: nil
        )
        self.fetchController.delegate = self
        
        do
        {
            try self.fetchController.performFetch()
        }
        catch let error
        {
            print("Fetch Results controller failed to fetch: '\(error.localizedDescription)'")
        }
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableHeaderView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = tableHeaderView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "ShowLibraryItem" { return }
        
        let itemVC = segue.destination as! LibraryItemViewController
        itemVC.video = sender as! UploadedVideo
    }
}

// MARK: -
// MARK: UITableViewDataSource
extension LibraryListViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if let sections = self.fetchController.sections
        {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = self.fetchController.sections
        {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellReuseID = "UploadedVideoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        
        let video = self.fetchController.object(at: indexPath)
        cell.textLabel?.text = self.creationDateFormatter
            .string(from: video.creationDate as Date)
        cell.detailTextLabel?.text =
            (video.processingStatus == .Processed) ? "Processed" : "Processing"
        
        cell.imageView?.image = nil
        if let fileName = video.thumbnailFileName
        {
            let url = URL.docsDirectory.appendingPathComponent(fileName)
            do
            {
                let pngData = try Data(contentsOf: url)
                let image = UIImage(data: pngData)
                cell.imageView?.image = image
            }
            catch
            {
                print("Failed to load thumbnail image")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle != .delete { return }
        
        let alert = UIAlertController(
            title: "Warning"
            , message: "This will delete the selected video. Would you like to proceed?"
            , preferredStyle: .alert
        )
        
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .default) {
            [weak self]
            _ in
            self?.proceedDeleteVideoAt(indexPath: indexPath)
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func proceedDeleteVideoAt(indexPath: IndexPath)
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Deleting video. Please, wait"
        
        let video = self.fetchController.object(at: indexPath)
        Backend.deleteVideo(videoID: video.videoID) {
            [weak self]
            isSuccess in
            
            hud.hide(animated: true)
            if isSuccess
            {
                let ctx = NSManagedObjectContext.mr_default()
                ctx.delete(video)
                ctx.mr_saveToPersistentStoreAndWait()
            }
            else
            {
                let alert = UIAlertController(
                    title: "Failed to delete video"
                    , message: "Please, make sure your Wi-Fi connection is active and try again later"
                    , preferredStyle: .alert
                )
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(ok)
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: -
// MARK: UITableViewDelegate
extension LibraryListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let uploadedVideo = self.fetchController.object(at: indexPath)
        
        if uploadedVideo.processingStatus == .Processed
        {
            self.performSegue(withIdentifier: "ShowLibraryItem", sender: uploadedVideo)
        }
        else if uploadedVideo.processingStatus == .isProcessing
        {
            let alert = UIAlertController(
                title: nil
                , message: "The swing is still being processed, we will notify you when it's ready"
                , preferredStyle: .alert
            )
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    {
        return 1
    }
}

// MARK: -
// MARK: NSFetchedResultsControllerDelegate
extension LibraryListViewController: NSFetchedResultsControllerDelegate
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert:
            guard let path = newIndexPath else { return }
            
            self.tableView.insertRows(at: [path], with: .left)
            
        case .update:
            guard let path = indexPath else { return }
            
            self.tableView.reloadRows(at: [path], with: .automatic)
            
        case .delete:
            guard let path = indexPath else { return }
            
            self.tableView.deleteRows(at: [path], with: .fade)
            
        default:
            break
        }
    }
}
