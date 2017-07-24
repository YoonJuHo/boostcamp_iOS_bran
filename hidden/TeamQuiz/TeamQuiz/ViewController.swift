//
//  ViewController.swift
//  TeamQuiz
//
//  Created by JU HO YOON on 2017. 7. 14..
//  Copyright © 2017년 YJH Studio. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var members: [String] = [] {
        didSet {
            for (index, member) in members.enumerated() {
                guard let firstChar = member.lowercased().characters.first else { continue }
                
                if memberIndexs.contains(String(firstChar)) == false {
                    memberIndexs.append(String(firstChar))
//                    print(firstChar)
                }
            }
        }
    }
    
    var memberIndexs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "MemberList", withExtension: "rtf") else { return }
        let attString = try? NSAttributedString(url: url, options: [:], documentAttributes: nil)
        guard let names = attString?.string.components(separatedBy: "\n") else { return }
        self.members = names
        
        self.tableView.register(SwipableCell.self, forCellReuseIdentifier: "SwipableCell")
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return memberIndexs
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.memberIndexs[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return memberIndexs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempMembers = self.members.filter { String($0.characters.first!) == memberIndexs[section] }
        return tempMembers.count
//        return self.members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempMembers = self.members.filter { String($0.characters.first!) == memberIndexs[indexPath.section] }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwipableCell", for: indexPath) as? SwipableCell else { return UITableViewCell() }
        cell.textLabel?.text = tempMembers[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
