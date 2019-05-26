//
//  BooksTableViewController.swift
//  Nearbrary
//
//  Created by Release on 19/05/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit
import os.log
import SafariServices


class BooksTableViewController: UITableViewController, XMLParserDelegate {
    
    @IBOutlet var titleNavigationItem: UINavigationItem!
    
    let bookImageQueue = DispatchQueue(label: "bookImage")
    
    let clientID = "FyOXvDvPu37mE9tNUNyM"
    let clientSecret = "LdfdMzoeVV"
    

    /*var dataset = [
        ("여행의 이유", "김영하", "문학동네", "2019.04.17")
    ]*/
    
    var queryText:String?
    var books:[book] = []
    
    var strXMLData: String? = ""
    var currentTag: String? = ""
    var currentElement: String = ""
    var item : book? = nil
    
    var page = 1
    @IBAction func more(_ sender: Any) {
        self.page += 10
        self.searchBooks()
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let title = queryText {
            titleNavigationItem.title = title
        }
        searchBooks()
    }
    
    func searchBooks() {
        books = []
        
        guard let query = queryText else {
            return
        }
        
        let urlString =  "https://openapi.naver.com/v1/search/book.xml?query=" + query + "&display=10&start=\(self.page)"
        let urlWithPercentEscapes = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: urlWithPercentEscapes!)
        
        var request = URLRequest(url: url!)
        request.addValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            self.item?.author = ""
            self.item?.isbn = ""
            self.item?.imageURL = ""
            self.item?.link = ""
            self.item?.pubdate = ""
            self.item?.title = ""
            self.item?.publisher = ""
            
            let parser = XMLParser(data: Data(data))
            parser.delegate = self
            let success:Bool = parser.parse()
            if success {
                print(self.strXMLData as Any)
            } else {
                print("parse failure!")
            }
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "title" || elementName == "link" || elementName == "image" || elementName == "pubdate" || elementName == "isbn" || elementName == "author" || elementName == "publisher" {
            currentElement = ""
            if elementName == "title" {
                item = book()
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElement += string
    }
    
    func parser (_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "title" {
            item?.title = currentElement.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        } else if elementName == "link" {
            item?.link = currentElement
        } else if elementName == "image" {
            item?.imageURL = currentElement
        } else if elementName == "author" {
            item?.author = currentElement.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        } else if elementName == "publisher" {
            item?.publisher = currentElement.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        } else if elementName == "pubdate" {
            item?.pubdate = currentElement
        } else if elementName == "isbn" {
            item?.isbn = currentElement
            books.append(self.item!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book = books[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCellIdentifier") as! BooksTableViewCell
        
        cell.title?.text = book.title
        cell.author?.text = book.author
        cell.publisher?.text = book.publisher
        cell.pubdate?.text = book.pubdate
        
        if let bookImage = book.image {
            cell.bookImageView.image = bookImage
        } else {
            cell.bookImageView.image = UIImage(named: "noImage")
            bookImageQueue.async(execute: {
                book.getBookImage()
                guard let thumbImage = book.image else {
                    return
                }
                DispatchQueue.main.async {
                    cell.bookImageView.image = thumbImage
                }
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("선택된 행은 \(indexPath.row) 번째 행입니다")
    }
}
