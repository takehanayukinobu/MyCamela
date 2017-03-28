//
//  EffectViewController.swift
//  MyCamera
//
//  Created by Takehana Yukinobu on 2016/11/26.
//  Copyright © 2016年 Takehana Yukinobu. All rights reserved.
//

import UIKit
import AWSS3
import JTSImageViewController

class EffectViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //画面遷移時に元の画像を表示
    effectImage.image = originalImage
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var effectImage: UIImageView!
  //エフェクト画像を前の画面から設定
  var originalImage : UIImage?

 //加工後の画像をS3からダウンロード
  func downloadImage(bucketName: String, fileName: String, completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
    let transferUtility = AWSS3TransferUtility.default()
    
    transferUtility.downloadData(fromBucket: bucketName, key: fileName, expression: nil) { (task, url, data, error) in
      var resultImage: UIImage?
      
      if let data = data {
        resultImage = UIImage(data: data)
      }
      completion(resultImage, error as NSError?)

      self.effectImage.image = resultImage
    }
  }
  
  @IBAction func effectButtonAction(_ sender: Any) {
    let S3downKeyName: String = "public/" + uuid + "_reverse.png"
    downloadImage(bucketName: "myphoto.takecodecamp", fileName: "public/sample_reverse.png", completion: {(downloadImage:UIImage?,error:NSError?) ->
      Void in
      self.effectImage.image = downloadImage
      
    } )

  }
  
  @IBAction func shareButtonAction(_ sender: Any) {
    let controller = UIActivityViewController(activityItems: [effectImage.image!], applicationActivities: nil)
    controller.popoverPresentationController?.sourceView = view
    present(controller, animated: true, completion:nil)
  }
  @IBAction func closeButtonAction(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}
