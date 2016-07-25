//
//  MasterViewController.swift
//  Project5
//
//  Created by Valentin PAUL on 21/02/16.
//  Copyright © 2016 Valentin PAUL. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {
    // MARK: Properties
    var objects = [String]()
    var allWords = [String]()

    // MARK: Life View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        
        
        if let startWordPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordPath, usedEncoding: nil) {
                allWords = startWords.componentsSeparatedByString("\n")
            }
        }else {
            allWords = ["silkworm"]
        }
        
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    // MARK: Functions
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self,ac] (action :  UIAlertAction!) in
            let answer = ac.textFields![0]
            self.submitAnswer(answer.text!)
        }
        
        ac.addAction(submitAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func submitAnswer(answer : String) {
        let lowerAnswer = answer.lowercaseString
        
        var errorTitle = String()
        var errorMessage = String()
        
        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    objects.insert(lowerAnswer, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    return
                }else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up, you know !"
                }
            }else {
                errorTitle = "Word used already"
                errorMessage = "Be more original !"
            }
        }else {
            errorTitle = "Word not possible"
            errorMessage = "you can't spell that word from \(title!.lowercaseString) ! "
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(ac, animated: true, completion: nil)
        
    }
    
    func wordIsPossible(word: String) -> Bool {
        var tmpWord = title!.lowercaseString
        
        for letter in word.characters {
            if let pos = tmpWord.rangeOfString(String(letter)) {
                tmpWord.removeAtIndex(pos.startIndex)
            }else {
                return false
            }
        }
        
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool {
        let checker =  UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let mispelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }


}

