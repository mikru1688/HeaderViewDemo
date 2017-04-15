//
//  ViewController.swift
//  HeaderViewDemo
//
//  Created by Frank.Chen on 2017/4/14.
//  Copyright © 2017年 Frank.Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var dataList: [String] = ["玩命關頭8", "目擊者", "寶貝老闆", "攻擊機動隊", "我和我的冠軍女兒"]
    let photoImage: [String] = ["photo1", "photo2"] // 圖片名稱
    var currenPageNumber: Int = 0 // 當前頁數
    
    override func viewDidLoad() {
        // 生成UILabel
        let label: UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 40)
        label.text = "法蘭克的IOS世界"
        label.font = UIFont.systemFont(ofSize: 25)
        label.backgroundColor = UIColor.gray
        self.view.addSubview(label)
        
        // 生成UITableView
        self.tableView = UITableView(frame: CGRect(x: 0, y: label.frame.origin.y + label.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .plain)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView?.backgroundColor = UIColor.white
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(self.tableView!)
        
        // 生成UIRefreshControl
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(ViewController.refresh), for: UIControlEvents.valueChanged)
        self.refreshControl.attributedTitle = NSAttributedString(string: "重新整理中...")
        self.tableView?.addSubview(self.refreshControl)
        
        // 生成UIScrollView並掛載到UITableView的headerView上
        self.scrollView = UIScrollView()
        self.scrollView.tag = 100 // 用來區別UITableView的UIScrollView或UITableView的HeaderView的UIScrollView用
        self.scrollView!.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 4)
        self.scrollView!.contentSize = CGSize(width: self.view.frame.size.width * CGFloat(self.photoImage.count), height: self.view.frame.size.height / 4)
        self.scrollView!.backgroundColor = UIColor.clear
        self.scrollView!.showsVerticalScrollIndicator = true // 顯示右側垂直拉bar條
        self.scrollView!.showsHorizontalScrollIndicator = false // 隱藏底部平行拉bar條
        self.scrollView!.isPagingEnabled = true // 設定能以本身容器的寬度做切頁(橫向的scrollView)
        self.scrollView!.delegate = self
        
        // 動態產生兩張圖片
        var imageView: UIImageView!
        for i in 0 ... 1 {
            imageView = UIImageView()
            imageView.frame = CGRect(x: self.view.frame.size.width * CGFloat(i), y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 4)
            imageView.image = UIImage(named: self.photoImage[i])
            self.scrollView!.addSubview(imageView)
        }
        
        // 將scrollView掛載到tableView的headerView上
        self.tableView.tableHeaderView = self.scrollView!
//        self.tableView.tableFooterView = self.scrollView!
//        self.tableView.backgroundView = self.scrollView!
        
        // 生成UIPageControl(頁數顯示器)
        self.pageControl = UIPageControl()
        self.pageControl.frame = CGRect(x: 0, y: 20 + 40 + self.view.frame.size.height / 4 - 20, width: self.view.frame.size.width, height: 20)
        self.pageControl.numberOfPages = photoImage.count
        self.pageControl.currentPage = 0
        self.view.addSubview(self.pageControl!)
        
        // 設定每?秒自動翻頁
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.onChangePageAction), userInfo: nil, repeats: true)
    }
    
    // MARK: - CallBack
    // ---------------------------------------------------------------------
    // 自動切頁
    func onChangePageAction() {
        // 重新改變scrollView的座標
        self.scrollView.setContentOffset(CGPoint(x: self.scrollView.frame.size.width * CGFloat(self.currenPageNumber), y: 0), animated: true)
        
        // 重新設定當前頁數
        self.pageControl.currentPage = self.currenPageNumber
        self.currenPageNumber += 1
        if self.currenPageNumber == 2 {
            self.currenPageNumber = 0
        }
    }
    
    // 載入資料
    func refresh() {
        print("載入資料...")
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - TableView DataSource
    // ---------------------------------------------------------------------
    // 設定表格section的列數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    // 表格的儲存格設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none // 選取的時侯無背景色
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // 細節型態(右箭頭)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 30)
        cell.textLabel?.text = self.dataList[indexPath.row]        
        return cell
    }
    
    // MARK: - TableView Delegate
    // ---------------------------------------------------------------------
    // 設定cell的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height / 8
    }
    
    // 點選cell所觸發的事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("點選cell所觸發的事件...")
    }
    
    // MARK: - ScrollView Delegate
    // ---------------------------------------------------------------------
    // scrollViewv停止捲動時所觸發的事件(手動切換頁數)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 利用scrollView的容器內X座標算出UIPageController要顯示第幾頁
        let currentPage: CGFloat = scrollView.contentOffset.x / self.view.frame.size.width
        self.pageControl.currentPage = Int(currentPage)
    }
    
    // scrollView捲動時觸發的事件(改變UIPageControl位置)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 當不是headerView的UIScrollView滾動時才會觸發，用來規避onChangePage時所會觸發的UIScrollView
        if scrollView.tag != 100 {
            // 當tableview向下捲動時，pageControl的位置也必須隨著headerView移動而移動
            let contentOffsetY = scrollView.contentOffset.y >= 0 ? -scrollView.contentOffset.y : abs(scrollView.contentOffset.y) // y座標若是負數(向下捲)則要變正數，反之(向上捲)則變負數
            self.pageControl.frame = CGRect(x: 0, y: 20 + 40 + self.view.frame.size.height / 4 + contentOffsetY - 20, width: self.view.frame.size.width, height: 20)
        }
        
    }
    
}

