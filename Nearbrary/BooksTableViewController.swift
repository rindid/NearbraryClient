//
//  BooksTableViewController.swift
//  Nearbrary
//
//  Created by Release on 19/05/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit

class BooksTableViewController: UITableViewController {
    var dataset = [
        ("여행의 이유", "김영하", "문학동네", "2019.04.17")
    ]
    
    var queryText:String?
    
    lazy var list: [book] = {
        var datalist = [book]()
        
        for (title, author, publisher, pubdate) in self.dataset {
            let bvo = book()
            bvo.title = title
            bvo.author = author
            bvo.publisher = publisher
            bvo.pubdate = pubdate
            datalist.append(bvo)
        }
        return datalist
    } ()
    
    override func viewDidLoad() {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! BookCell
        cell.title?.text = row.title
        cell.author?.text = row.author
        cell.publisher?.text = row.publisher
        cell.pubdate?.text = row.pubdate
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다")
    }
}
