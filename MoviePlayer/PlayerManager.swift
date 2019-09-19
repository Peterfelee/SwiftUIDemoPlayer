//
//  PlayerManager.swift
//  MoviePlayer
//
//  Created by peterlee on 2019/9/19.
//  Copyright © 2019 Personal. All rights reserved.
//


import UIKit
import AVKit
import MediaPlayer
import SnapKit

class PlayerManager:NSObject {
    static var manager:PlayerManager = PlayerManager()
    
    private var playerLayer:AVPlayerLayer?
    private var player:AVPlayer?
    private var playerItem:AVPlayerItem?
    private weak var playView:UIView?
    private var observer:Any?
    private var controlView:PlayerControlView?
    private var currentUrl:String?
    private var previewProgress:Double = 0.0
    lazy private var mpVolueView:MPVolumeView = {
        let temp = MPVolumeView(frame: CGRect(x: -50, y: -50, width: 0.1, height: 0.1))
        temp.showsRouteButton = false
        temp.showsVolumeSlider = true
        temp.setVolumeThumbImage(UIImage(named: "slider"), for: .normal)
        temp.isHidden = true
        return temp
    }()
    
    lazy  private var arrowProgress:UILabel = {
        let temp = UILabel()
        temp.isHidden = true
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        temp.textColor = UIColor.white
        return temp
    }()
    
    var progress:Float {
        get{
            if controlView == nil
            {
                return 0.0
            }
            return controlView!.progressSlider.value
        }
    }
    private func setupPlayer(url:String){
        if url.hasPrefix("http") == false
        {
            return
        }
        let assetURL = AVAsset(url: URL(string: url)!)
        playerItem = AVPlayerItem(asset: assetURL, automaticallyLoadedAssetKeys: ["duration"])
        if playerLayer == nil {
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
           try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [AVAudioSession.CategoryOptions.mixWithOthers])
        }
        else
        {
            player?.pause()
            player?.replaceCurrentItem(with: playerItem)
        }
        playerItem!.addObserver(self, forKeyPath: "status", options: [.new,.old], context: nil)
        if controlView != nil {
            return
        }
        controlView = PlayerControlView(frame: .zero)
        controlView?.showTitle(isShow: false)
        controlView?.progressSlider.addTarget(self, action: #selector(sliderValueChange(slider:)), for: .valueChanged)
    }
    
    private func seekToTime(time:Double){
        playerItem?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
    
    
    //添加手势
    private func addGesture(){
        self.playView!.isUserInteractionEnabled = true
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture))
        singleTap.numberOfTapsRequired = 1
        self.playView!.addGestureRecognizer(singleTap)
        
        let doubleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture))
        doubleTap.numberOfTapsRequired = 2
        self.playView!.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        
        
        let pan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        playView?.addGestureRecognizer(pan)
        
    }
    
    
    @objc private func sliderValueChange(slider:UISlider){
        seekToTime(time: Double(slider.value))
    }
    @objc private func singleTapGesture(){
        if controlView != nil
        {
            controlView?.isHidden = !(controlView?.isHidden)!
        }
    }
    
    @objc private func doubleTapGesture(){
        if player != nil
        {
            controlView?.setPlay(play: player?.rate == 0 ? true : false)
        }
    }
    
    @objc private func panGesture(gesture:UIPanGestureRecognizer){
        let temp = gesture.translation(in: playView)
        let vectiy = gesture.velocity(in: playView)
        let location = gesture.location(in: playView)
        guard playerLayer != nil else {
            return
        }
        
        let tempX = Int(abs(temp.x))
        let tempY = Int(abs(temp.y))
        if CATransform3DIsIdentity(playerLayer!.transform) //竖屏
        {
            if tempX < tempY || abs(vectiy.x) < abs(vectiy.y)//上下滑动
            {
                arrowProgress.isHidden = true
                //区分左右去
                
                if location.x < ScreenWidth/3
                {
                    //左侧 亮度
                    let movePointX = -temp.y/(playView?.frame.height)!/2
                    UIScreen.main.brightness = UIScreen.main.brightness + movePointX
                }
                else if location.x > ScreenWidth/3*2//右侧 声音
                {
                    let volume = (-temp.y/(playView?.frame.height)!)
                    setUpVoulme(value: Float(volume), gesture: gesture)
                }
                return
            }
            print(NSCoder.string(for: temp))
            print(NSCoder.string(for: vectiy))
            seekProgress(progress: temp.x, gesture: gesture)
        }
        else//全屏
        {
            if tempY < tempX || abs(vectiy.y) < abs(vectiy.x)//上下滑动
            {
                arrowProgress.isHidden = true
                //区分左右去
                if location.y < ScreenHeight/3
                {
                    //左侧 亮度
                    let movePointY = temp.x/(playView?.frame.width)!/2
                    UIScreen.main.brightness = UIScreen.main.brightness + movePointY
                }
                else if location.y > ScreenHeight/3*2//右侧 声音
                {
                    let volume = (temp.x/(playView?.frame.width)!)
                    setUpVoulme(value: Float(volume), gesture: gesture)
                }
                return
            }
            print(NSCoder.string(for: temp))
            print(NSCoder.string(for: vectiy))
            seekProgress(progress: temp.y, gesture: gesture)
        }
    }
    
    private func seekProgress(progress:CGFloat,gesture:UIGestureRecognizer){
        var title:String = "快进"
        if progress < 0 {
            title = "快退"
        }
        let temp = Int(abs(progress))
        arrowProgress.isHidden = false
        arrowProgress.text = String(format: "%@:%02d:%02d",title, temp/60,temp%60)
        //在移动
        if gesture.state == UIGestureRecognizer.State.ended
        {
            controlView?.progressSlider.value = Float(CMTimeGetSeconds((player?.currentTime())!) + Double(progress))
            sliderValueChange(slider: (controlView?.progressSlider)!)
            arrowProgress.isHidden = true
        }
    }
    
    
    private func setUpVoulme(value:Float,gesture:UIGestureRecognizer){
        mpVolueView.isHidden = false
        for view:UIView in mpVolueView.subviews {
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider"{
                let slider:UISlider  = view as! UISlider
                slider.value = slider.value + value/10
                if gesture.state == UIGestureRecognizer.State.ended || gesture.state == UITapGestureRecognizer.State.failed
                {
                    mpVolueView.isHidden = true
                }
                return
            }
        }
    }
    
}


extension PlayerManager{
    //功能外放的方法
    public func playVideo(playView:UIView,videoUrl:String,progress:Double,title:String,subtitle:String){
        self.previewProgress = progress
        if currentUrl != nil && currentUrl == videoUrl && player != nil{
            //同一个视频 没有初始化成功播放器 传的地址为空
            return
        }
        //先停止
        player?.pause()
        currentUrl = videoUrl
        self.playView = playView
        addGesture()
        setupPlayer(url: videoUrl)
        playView.layer.addSublayer(playerLayer!)
        playView.addSubview(controlView!)
        playView.addSubview(arrowProgress)
        playView.addSubview(mpVolueView)
        arrowProgress.snp.makeConstraints { (make) in
            make.center.equalTo(playView)
        }
        mpVolueView.snp.makeConstraints { (make) in
            make.right.equalTo(((controlView?.snp.right)!)).offset(-15)
            make.centerY.equalTo(controlView!)
            make.size.equalTo(CGSize(width: 100, height: 40))
        }
        mpVolueView.transform = CGAffineTransform.init(rotationAngle: -CGFloat(Double.pi/2))
        player?.play()
        controlView?.setTitle(title: title, subtitle: subtitle)
        
        self.observer = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main, using: {[weak self] (time) in
            let current:Int = Int(CMTimeGetSeconds(time))
            self?.controlView!.startTime.text = String(format: "%02d:%02d:%02d", current/3600,current%3600/60,current%60)
            if self?.player?.rate == 0
            {
                return
            }
            let progress:Double = CMTimeGetSeconds(time)
            self?.controlView?.progressSlider.value = Float(progress)
        })
    }
    
    public func play(){
        if player?.rate != 0
        {
            return
        }
        player?.play()
        controlView?.setPlay(play: true)
    }
    
    public func pause(){
        if player?.rate  == 0
        {
            return
        }
        player?.pause()
        controlView?.setPlay(play: false)
    }
    
    public func stop(){
        pause()
        player?.removeTimeObserver(self.observer as Any)
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem = nil
        player = nil
        controlView?.removeFromSuperview()
        controlView = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        playView = nil
    }
    
    public func scale(full:Bool){
        var tranform3d:CATransform3D? = nil
        var temp:CGSize? = nil
        var tranform2d:CGAffineTransform? = nil
        if let temp:UINavigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        {
            temp.isNavigationBarHidden = full
        }
        //是否全屏
        if full
        {
            tranform2d = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
            tranform3d =  CATransform3DMakeRotation(CGFloat(Double.pi/2), 0, 0, 1)
            temp =  CGSize(width: ScreenWidth, height: ScreenHeight)
            
        }
        else
        {
            tranform2d = CGAffineTransform.identity
            tranform3d = CATransform3DIdentity
            temp = CGSize(width: ScreenWidth, height: 300)
            
        }
        var playViewFrame = full ? CGRect.zero : CGRect(origin: CGPoint(x: 0, y: 64), size: CGSize.zero)
        playViewFrame.size = temp!
        playView!.frame = playViewFrame
        playerLayer?.transform = tranform3d!
        playerLayer!.frame = CGRect(origin: CGPoint.zero, size: temp!)
        controlView!.transform = tranform2d!
        controlView!.frame = CGRect(origin: CGPoint.zero, size: temp!)
        arrowProgress.transform = tranform2d!
        controlView?.showTitle(isShow: full)
    }
}

extension PlayerManager{
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status"
        {
            if playerItem?.status == AVPlayerItem.Status.readyToPlay
            {
                let videoDuration:Int = Int(CMTimeGetSeconds((playerItem?.duration)!))
                playerLayer?.frame = playView!.bounds
                controlView!.frame = playView!.bounds
                controlView?.progressSlider.maximumValue = Float(videoDuration)
                controlView!.endTime.text = String(format: "%02d:%02d:%02d", videoDuration/3600,videoDuration%3600/60,videoDuration%60)
                if previewProgress <= 0
                {
                    return
                }
                seekToTime(time: previewProgress)
                previewProgress = 0.0
            }
        }
    }
}




class PlayerControlView: UIView {
    private var title:UILabel!
    private var subttitle:UILabel!
    private var scaleScreenButton:UIButton!
    private var playButton:UIButton!
    private var nextButton:UIButton!

    private var bottomBackgroundView:UIView!
    
    override var isHidden: Bool{
        didSet{
            if isHidden == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if self.isHidden == true
                    {
                        return
                    }
                    self.isHidden = true
                }
            }
        }
    }
    
    var startTime:UILabel!
    var endTime:UILabel!
    var progressSlider:UISlider!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView(){
        title = UILabel(frame: .zero)
        title.font = UIFont.systemFont(ofSize: 13)
        title.textColor = UIColor.white
        addSubview(title)
        
        subttitle = UILabel(frame: .zero)
        subttitle.font = UIFont.systemFont(ofSize: 11)
        subttitle.textColor = UIColor.white
        addSubview(subttitle)
        
        
        bottomBackgroundView = UIView(frame: .zero)
        bottomBackgroundView.layer.contents = UIImage(named: "bottom_shadow")?.cgImage
        addSubview(bottomBackgroundView)
        
        scaleScreenButton = UIButton(type: .custom)
        scaleScreenButton.setImage(UIImage(named: "fullscreen"), for: .normal)
        scaleScreenButton.setImage(UIImage(named: "shrinkscreen"), for: .selected)
        bottomBackgroundView.addSubview(scaleScreenButton)
        
        startTime = UILabel(frame: .zero)
        startTime.text = "00:00:00"
        startTime.textColor = UIColor.white
        startTime.font = UIFont.systemFont(ofSize: 13)
        bottomBackgroundView.addSubview(startTime)
        
        
        endTime = UILabel(frame: .zero)
        endTime.text = "00:00:00"
        endTime.textColor = UIColor.white
        endTime.font = UIFont.systemFont(ofSize: 13)
        bottomBackgroundView.addSubview(endTime)
        
        
        playButton = UIButton(type: .custom)
        playButton.setImage(UIImage(named: "new_allPause"), for: .normal)
        playButton.setImage(UIImage(named: "new_allPlay"), for: .selected)
        addSubview(playButton)
        
        nextButton = UIButton(type: .custom)
        nextButton.setImage(UIImage(named: "nextPlay"), for: .normal)
        addSubview(nextButton)
        
        scaleScreenButton.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside)

        playButton.isSelected = false
        scaleScreenButton.isSelected = false
        
        progressSlider = UISlider(frame: .zero)
        progressSlider.maximumTrackTintColor = UIColor.gray
        progressSlider.minimumTrackTintColor = UIColor.blue
        progressSlider.setThumbImage( UIImage(named: "slider"), for: .normal)
        bottomBackgroundView.addSubview(progressSlider)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.isHidden
            {
                return
            }
            self.isHidden = true
        }
        
    }
    
    private func setupConstraints(){
        
        title.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(10)
        }
        
        subttitle.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(title.snp.bottom).offset(5)
        }
        
        
        let width = ("99:99:99" as NSString).size(withAttributes: [NSAttributedString.Key.font:startTime.font]).width
        bottomBackgroundView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self)
            make.height.equalTo(50)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(playButton.snp.right).offset(15)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        startTime.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.width.equalTo(width)
            make.centerY.equalTo(bottomBackgroundView)
        }
        
        scaleScreenButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(bottomBackgroundView)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        endTime.snp.makeConstraints { (make) in
            make.right.equalTo(scaleScreenButton.snp.left).offset(5)
            make.width.equalTo(width)
            make.centerY.equalTo(bottomBackgroundView)
        }
        
        progressSlider.snp.makeConstraints { (make) in
            make.left.equalTo(startTime.snp.right).offset(5)
            make.right.equalTo(endTime.snp.left).offset(-5)
            make.height.equalTo(10)
            make.centerY.equalTo(bottomBackgroundView)
        }
    }
    
    
    @objc private func buttonClick(btn:UIButton){
        btn.isSelected = !btn.isSelected
        if btn == playButton
        {
            btn.isSelected ? PlayerManager.manager.pause():PlayerManager.manager.play()
        }
        else if btn == scaleScreenButton
        {
            PlayerManager.manager.scale(full: btn.isSelected)
        }
        else if btn == nextButton
        {
            //发通知传递播放下一个事件
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: kControlPlayerViewNextPlayNotificationName), object: nil)
        }
    }
    
    deinit {
        print(NSStringFromClass(self.classForCoder))
    }
    
    
}


extension PlayerControlView{
    public func setPlay(play:Bool){
        if play//播放
        {
            playButton.isSelected = true
            buttonClick(btn: playButton)
        }
        else//暂停
        {
            playButton.isSelected = false
            buttonClick(btn: playButton)
        }
    }
    // isshow = true 显示
    public func showTitle(isShow:Bool){
        if isShow
        {
            title.isHidden = false
            subttitle.isHidden = false
        }
        else
        {
            title.isHidden = true
            subttitle.isHidden = true
        }
    }
    
    public func setTitle(title:String,subtitle:String){
        self.title.text = title
        self.subttitle.text = subtitle
    }
}

