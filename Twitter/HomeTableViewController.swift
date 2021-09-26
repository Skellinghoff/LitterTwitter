//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Jarod Wellinghoff on 9/25/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
	
	var tweetArray = [NSDictionary]()
	var numberOfTweets: Int!
	
	let myRefreshControl = UIRefreshControl()

	override func viewDidLoad() {
		super.viewDidLoad()
		loadTweets()
		
		myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
		self.tableView.refreshControl = myRefreshControl

    }

	@IBAction func onLogout(_ sender: Any) {
		UserDefaults.standard.set(false, forKey: "userLoggedIn")
		TwitterAPICaller.client?.logout()
		self.dismiss(animated: true, completion: nil)
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
		let user = tweetArray[indexPath.row]["user"] as! NSDictionary
		
		let username = user["name"] as! String
		let tweetContent = tweetArray[indexPath.row]["text"] as! String
		
		let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
		let data = try? Data(contentsOf: imageUrl!)
		if let imageData = data {
			cell.profileImageView.image = UIImage(data: imageData)
		}
		
		cell.usernameLabel.text = username
		cell.tweetContentLabel.text = tweetContent
		
		return cell
	}
	
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
    }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweetArray.count
		
	}
	
	@objc func loadTweets() {
		let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		numberOfTweets = 20
		let myParams = ["count" : numberOfTweets!] as [String : Any]
		TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: {
			(tweets: [NSDictionary]) in
			self.tweetArray.removeAll()
			for tweet in tweets {
				self.tweetArray.append(tweet)
			}
			self.tableView.reloadData()
			self.myRefreshControl.endRefreshing()
//			print(self.tweetArray)
			
		}, failure: { (Error) in
			print("Could not retreive tweets...")
		})
	}
	
	func loadMoreTweets() {
		let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		let myParams = ["count" : numberOfTweets += 20]
		TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: {
			(tweets: [NSDictionary]) in
			self.tweetArray.removeAll()
			for tweet in tweets {
				self.tweetArray.append(tweet)
			}
			self.tableView.reloadData()
			self.myRefreshControl.endRefreshing()
//			print(self.tweetArray)
			
		}, failure: { (Error) in
			print("Could not retreive tweets...")
		})
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row + 1 == tweetArray.count {
			loadMoreTweets()
		}
	}

}