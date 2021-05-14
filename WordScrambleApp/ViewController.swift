//
//  ViewController.swift
//  WordScrambleApp
//
//  Created by Satinder Panesar on 5/7/21.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add bar button
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(propmtForAnswer))
        
        
        
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
        if let startwords = try?  String(contentsOf: startWordUrl){
            allWords = startwords.components(separatedBy: "\n")
        }
        }
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        startGame()
        
    }
    func startGame(){
        
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    @objc func propmtForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){
                [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(_answer: answer)
         }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func submit(_answer:String){
        let lowerAnswer = _answer.lowercased()
        
        let errorTitle:String
        let errorMessage:String
        
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(_answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                    
                }else{
                    errorTitle = "word not recognized"
                    errorMessage = "You can't just make them up, you know!"
                }
            }else{
                errorTitle = "word already used "
                errorMessage = "Be more original!"
            }
        } else{
            guard let title = title else {return}
            errorTitle = "word not possible "
            errorMessage = "You can't spell that word from \(title.lowercased())"
        }
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
       present(ac, animated: true)
        
        
    }
    func isPossible(word:String) -> Bool{
        guard var tempword = title?.lowercased() else {return false}
        
        for letter in word{
            if let position = tempword.firstIndex(of: letter){
                tempword.remove(at: position)
            }
            else{
                return false
            }
        }
         return true
    }
    
    func isOriginal(word:String) -> Bool{
        return !usedWords.contains(word)
    }
    func isReal(word:String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0 , length: word.utf16.count)
        let misspessedRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspessedRange.location == NSNotFound
    }
}
