//
//  LBCollectionViewController.swift
//  SeeBeauty
//
//  Created by JLB on 2016/11/7.
//  Copyright © 2016年 LB. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire

private let reuseIdentifier = "LBCollectionViewCell"

class LBCollectionViewController: UICollectionViewController, LBImageBrowserDelegate {

    @IBOutlet weak var layout: LBCollectionViewFlowLayout!
    var images = NSMutableArray()
    var browserView: LBImageBrowser!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "看美女"
        self.layout.columnCount = 2

        let nib = UINib(nibName: "LBCollectionViewCell", bundle: Bundle.main)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: "reuseIdentifier")

        loadData()

        weak var weakSelf = self
        self.collectionView?.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            DispatchQueue.global().async {
                weakSelf?.loadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LBCollectionViewCell

        let image = self.images[indexPath.item] as! LBImage
        cell.image = image

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let rect = self.view?.convert((cell?.frame)!, from: self.collectionView)
        let image = self.images[indexPath.item] as! LBImage
        self.browserView = LBImageBrowser(frame: self.view.bounds, originRect: rect!, image: image)
        self.browserView.delegate = self
        self.view.addSubview(self.browserView!)
        self.browserView?.showBrowser();

        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: - LBImageBrowserDelegate

    func showNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
    }

    // MARK: - 自定义方法

    func loadData() {

        // Alamofire 加载数据

        let urlString = "http://c.3g.163.com/recommend/getChanListNews?channel=T1456112189138"

        Alamofire.request(urlString, method: .get).responseJSON { response in
            guard let JSON = response.result.value else {
                return
            }

            print("JSON: \(JSON)")

            let jsonData = JSON as! [String: Any]
            let array = jsonData["美女"] as! [NSDictionary]

            for dict in array {
                let image = LBImage.mj_object(withKeyValues: dict)
                self.images.add(image)
            }

            self.layout.images = self.images

            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.collectionView?.mj_footer.endRefreshing()
            }

        }

        // URLSession 加载数据

//        let url = URL(string: "http://c.3g.163.com/recommend/getChanListNews?channel=T1456112189138")
//        let request = NSMutableURLRequest(url: url!)
//        request.timeoutInterval = 5
//        request.httpMethod = "GET"
//
//        let sessionConfiguration = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfiguration)
//
//        let task = session.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
//            if nil == error {
//                print(error?.localizedDescription)
//            }
//
//            if nil != data {
//                let jsonData = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)  as! [String: Any]
//                let array = jsonData["美女"] as! [NSDictionary]
//                print(array)
//
//                for dict in array {
//                    let image = LBImage.mj_object(withKeyValues: dict)
//                    self.images.add(image)
//                }
//
//                self.layout.images = self.images
//
//                DispatchQueue.main.async {
//                    self.collectionView?.reloadData()
//                    self.collectionView?.mj_footer.endRefreshing()
//                }
//            }
//        }
//
//        task.resume()
    }

}
