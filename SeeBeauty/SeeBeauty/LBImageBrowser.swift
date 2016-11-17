//
//  LBImageBrowser.swift
//  SeeBeauty
//
//  Created by JLB on 2016/11/8.
//  Copyright © 2016年 Color. All rights reserved.
//

import UIKit

protocol LBImageBrowserDelegate: NSObjectProtocol {
    func showNavigationBar()
}

class LBImageBrowser: UIView, UIScrollViewDelegate {

    private var originRect: CGRect!
    private var image: LBImage!
    weak var delegate: LBImageBrowserDelegate?

    init(frame: CGRect, originRect: CGRect, image: LBImage) {
        super.init(frame: frame)

        self.originRect = originRect
        self.image = image
        self.backgroundColor = UIColor.black

        addGestureRecognizer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showBrowser() {
        self.addSubview(self.animationView)
        self.animationView.kf.setImage(with: URL(string: self.image.img!)!)

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.animationView.layer.frame = UIScreen.main.bounds
            }, completion: { (finished) -> Void in
                if (finished == true) {
                    self.setupUI()
                }
        })
    }

    @objc private func hideBrowser() {
        self.animationView.isHidden = false

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.animationView.frame = self.originRect
            self.switchScrollView.alpha = 0
            self.backgroundColor = UIColor.clear;
            }, completion: { (finished: Bool) -> Void in
                if  (finished == true){
                    self.animationView.isHidden = true
                    self.removeFromSuperview()
                    self.delegate?.showNavigationBar()
                }
        })
    }

    @objc private func setupUI() {
        self.addSubview(self.switchScrollView)

        for subview in switchScrollView.subviews{
            subview.removeFromSuperview()
        }
        
        switchScrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: UIScreen.main.bounds.height)
        switchScrollView.addSubview(self.scaleScrollView)
        switchScrollView.addSubview(self.titleLabel)
        switchScrollView.addSubview(self.btnSave)

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.switchScrollView.alpha = 1.0
            }, completion: { (finished: Bool) -> Void in
                self.animationView.isHidden = true
        })
    }

    @objc private func addGestureRecognizer() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(hideBrowser))
        singleTap.numberOfTapsRequired = 1
        singleTap.delaysTouchesBegan = true
        self.scaleScrollView.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        self.scaleScrollView.addGestureRecognizer(doubleTap)

        singleTap.require(toFail: doubleTap)
    }

    func scaleImage(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self.imageView)

        if (self.scaleScrollView.zoomScale == self.scaleScrollView.maximumZoomScale) {
            self.scaleScrollView.setZoomScale(self.scaleScrollView.minimumZoomScale, animated: true)
        } else {
            self.scaleScrollView.zoom(to: CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1), animated: true)
        }
    }

    @objc private func save() {
        var image: UIImage? = nil
        image = self.imageView.image

        if image != nil {
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImageDone(_:error:context:)), nil)
        }
    }

    @objc func saveImageDone(_ image : UIImage, error: Error, context: UnsafeMutableRawPointer?) {
        print("图片已保存")
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    // MARK: - Lazy

    // 用于动画的图片

    lazy var animationView: UIImageView = {
        let animationView = UIImageView()
        animationView.frame = self.originRect
        animationView.clipsToBounds = true
        animationView.isUserInteractionEnabled = false
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = UIColor.clear;
        return animationView
    }()

    // 用于切换上下图

    lazy var switchScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.backgroundColor = UIColor.clear
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        return scrollView
    }()

    // 用于缩放图片

    lazy var scaleScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.addSubview(self.imageView)
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.5
        return scrollView
    }()

    // 当前展示的图片

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.kf.setImage(with: URL(string: self.image.img!)!)
        return imageView
    }()

    // 标题

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 2, y: 20, width: SCREEN_WIDTH - 4, height: 21))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = self.image.title
        return titleLabel
    } ()

    // 保存按钮

    lazy var btnSave: UIButton = {
        let width: CGFloat = 80
        let height: CGFloat = 40
        let x = SCREEN_WIDTH - width - 10
        let y = SCREEN_HEIGHT - height - 10
        let btnSave = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        btnSave.addTarget(self, action: #selector(save), for: .touchUpInside)
        btnSave.setTitle("保 存", for: .normal)
        return btnSave
    }()

}
