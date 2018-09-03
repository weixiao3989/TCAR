//
//  JNStarRateView.swift
//  StarRateView
//
//  Created by iOS Developer on 16/9/19.
//  Edit by Chris on 18/01/24.
//  Copyright © 2016年 yinjn. All rights reserved.
//

import UIKit

@objc protocol JNStarReteViewDelegate {
    // 返回星星的值.
    @objc optional func starRate(view starRateView:JNStarRateView,score:Float) -> ()
}

// 星星評分規則: 1顆星 = 1分
class JNStarRateView: UIView {
    var delegate:JNStarReteViewDelegate?
    var usePanAnimation:Bool = false // 是否使用滑動評分, 默認為 false
    var allowUnderCompleteStar:Bool = false { // 是否允許非整星評分, 默認為 false
        willSet{
            self.allowUnderCompleteStar = newValue
            showStarRate()
        }
    }
    var allowHalfCompleteStar:Bool = false { // 是否允許(半星,全星)評分, 默認為 false
        willSet{
            self.allowHalfCompleteStar = newValue
            showStarRate()
        }
    }
    
    var allowUserPan:Bool{ // 滑動評分開關
        set{
            if newValue {
                let pan = UIPanGestureRecognizer(target: self,action: #selector(JNStarRateView.starPan(_:)))
                self.addGestureRecognizer(pan)
            }
            _allowUserPan = newValue
        }get{
            return _allowUserPan
        }
    }

    fileprivate var starBackgroundView:UIView! // 背景星星圖
    fileprivate var starForegroundView:UIView! // 前景星星圖
    fileprivate var _allowUserPan:Bool = false // 默認不支援滑動評分
    fileprivate var count:Int! // 星星數量
    fileprivate var score:Float! // 分數
    fileprivate var firstInit:Bool = true // 是否創建View
    
    /*
     * 一顆星代表一分
     * starCount: 代表創建多少顆星
     * score: 創建時顯示分數
     */
    override convenience init(frame: CGRect) {
       self.init(frame: frame,starCount:5,score:0.0)
    }
    
    init(frame: CGRect,starCount:Int,score:Float) {
        super.init(frame: frame)
        self.count = starCount
        self.score = score
        self.clipsToBounds = true
        createStarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createStarView()->(){
        starBackgroundView = starViewWithImageName("backgroundStar.png")
        starForegroundView = starViewWithImageName("foregroundStar.png")
        self.addSubview(starBackgroundView)
        self.addSubview(starForegroundView)
        showStarRate()
        self.firstInit = false
        // 添加手勢
        let tap = UITapGestureRecognizer(target: self,action: #selector(JNStarRateView.starTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    fileprivate func starViewWithImageName(_ imageName:String) -> UIView {
        let starView = UIView.init(frame: self.bounds)
        starView.clipsToBounds = true
        // 添加星星
        let width = self.frame.size.width / CGFloat(count)
        for index in 0...count {
            let imageView = UIImageView.init(frame: CGRect(x:CGFloat(index) * width,y: 0,width:width,height:self.bounds.size.height))
            imageView.image = UIImage(named: imageName)
            starView.addSubview(imageView)
        }
        return starView
    }
    
    // 滑動評分
    @objc func starPan(_ recognizer:UIPanGestureRecognizer) -> () {
        var OffX:CGFloat = 0
        if recognizer.state == .began{
            OffX = recognizer.location(in: self).x
        }else if recognizer.state == .changed{
            OffX += recognizer.location(in: self).x
        }else{
            return
        }
        self.score = Float(OffX) / Float(self.bounds.width) * Float(self.count)
        showStarRate()
        backSorce()
    }
    
    // 點擊評分
    @objc func starTap(_ recognizer:UIPanGestureRecognizer) -> () {
        let OffX = recognizer.location(in: self).x
        
        if self.allowHalfCompleteStar {
            switch Float(OffX) / Float(self.bounds.width) * Float(self.count) {
            case 0..<0.5:
                self.score = 0.5
                break
            case 0.5..<1.0:
                self.score = 1.0
                break
            case 1.0..<1.5:
                self.score = 1.5
                break
            case 1.5..<2:
                self.score = 2.0
                break
            case 2..<2.5:
                self.score = 2.5
                break
            case 2.5..<3:
                self.score = 3.0
                break
            case 3..<3.5:
                self.score = 3.5
                break
            case 3.5..<4:
                self.score = 4.0
                break
            case 4..<4.5:
                self.score = 4.5
                break
            case 4.5..<5.1:
                self.score = 5.0
                break
            default:
                self.score = 3.0
                break
            }
        } else {
            self.score = Float(OffX) / Float(self.bounds.width) * Float(self.count)
        }
        
        showStarRate()
        backSorce()
    }
    
    // 返回分數
    fileprivate func backSorce(){
        if (self.delegate != nil) {
            
            var newScore: Float
            if self.allowUnderCompleteStar || self.allowHalfCompleteStar {
                newScore = score
            } else {
                newScore = Float(Int(score + 0.8))
            }
            
            if  newScore > Float(count){
                newScore = Float(count)
            }else if newScore < 0{
                newScore = 0
            }
            // 代理協議
            self.delegate?.starRate!(view: self, score: newScore)
        }
    }
    
    // 顯示評分
    fileprivate func showStarRate(){
        let duration = (usePanAnimation && !firstInit) ? 0.1 : 0.0
        UIView.animate(withDuration: duration, animations: {
            if self.allowUnderCompleteStar || self.allowHalfCompleteStar { // 支援非整星評分 or 只支援半,整星評分
                self.starForegroundView.frame = CGRect(x: 0,y: 0,width: self.bounds.width / CGFloat(self.count) * CGFloat(self.score),height: self.bounds.height)
            }else { // 只支援整星評分
                self.starForegroundView.frame = CGRect(x: 0,y: 0,width: self.bounds.width / CGFloat(self.count) * CGFloat(Int(self.score + 0.8)),height: self.bounds.height)
            }
        }) 
    }
}
