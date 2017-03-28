//
//  ViewController.swift
//  MyCamera
//
//  Created by Takehana Yukinobu on 2016/11/26.
//  Copyright © 2016年 Takehana Yukinobu. All rights reserved.
//

import UIKit
import AWSS3

class ViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var pictureImage: UIImageView!
  let uuid = UUID().uuidString
  
  //カメラかフォトライブラリか？
  let alertController = UIAlertController(title: "確認", message:"選択してください", preferredStyle: .actionSheet)

  @IBAction func cameraButtonAction(_ sender: Any) {
    //カメラが利用可能かチェック
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      //カメラ用の選択肢
      let cameraAction = UIAlertAction(title: "カメラ", style: .default,handler: {(action:UIAlertAction) in
      //カメラ起動
      //UIImagePickerControllerのインスタンスを作成
      let ipc:UIImagePickerController = UIImagePickerController()
      //sorceTypeにCameraを設定
      ipc.sourceType = .camera
      //delegate設置
      ipc.delegate = self
      //モーダルビューで表示
      self.present(ipc, animated: true, completion: nil)
      })
      alertController.addAction(cameraAction)
    }
    
    //フォトライブラリが利用可能かチェック
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      //フォト用の選択肢
      let photoAction = UIAlertAction(title: "フォトライブラリー", style: .default,handler: { (action:UIAlertAction) in
      //フォトライブラリ起動
      let ipc:UIImagePickerController = UIImagePickerController()
      ipc.sourceType = .photoLibrary
      ipc.delegate = self
      self.present(ipc, animated:true, completion: nil)
      })
      alertController.addAction(photoAction)
    }
      //キャンセル用の選択肢
      let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel,handler: nil)
      alertController.addAction(cancelAction)
      
      //ipadで落ちる対策
      alertController.popoverPresentationController?.sourceView = view

      //選択肢を画面に表示
      present(alertController, animated: true, completion:nil)
  }
  
  //SNS投稿ボタン
  @IBAction func SNSButtonAction(_ sender: Any) {
    //画像をアンラップ
    if let shareImage = pictureImage.image {
      //UIActivityControllerが配列指定なので配列に入れて渡す
      let shareItems = [shareImage]
      let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
      controller.popoverPresentationController?.sourceView = view
      //UIActivityViewControllerを表示
      present(controller, animated: true, completion: nil)
    }
  }
  
  //画像取得が終わった時に呼ばれるdelegate
  func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info : [String : Any]){

    //撮影した写真を、captureImageに渡す
    captureImage = info[UIImagePickerControllerOriginalImage] as? UIImage

    //画像をS３にアップロード
    let uploadFileURL = info[UIImagePickerControllerReferenceURL] as? NSURL
    let imageName = uploadFileURL?.lastPathComponent
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String

    let localPath = (documentDirectory as NSString).appendingPathComponent(imageName!)
    
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    let data = UIImagePNGRepresentation(image!)
    do {
      try data?.write(to: URL(fileURLWithPath: localPath), options: .atomic)
      } catch {
      print(error)
    }
    let imageData = NSData(contentsOfFile: localPath)!
    let imageURL = NSURL(fileURLWithPath: localPath)
    
    let S3BucketName: String = "myphoto.takecodecamp"
    let S3UploadKeyName: String = "public/" + uuid + ".png"
    
    let transferUtility = AWSS3TransferUtility.default()
    let expression = AWSS3TransferUtilityUploadExpression()
    
    transferUtility.uploadFile(imageURL as URL, bucket: S3BucketName, key: S3UploadKeyName, contentType: "image/jpeg", expression: expression, completionHandler: nil).continueWith { (task) -> AnyObject! in
      if let error = task.error {
        print("Error: \(error.localizedDescription)")
      }
      if let _ = task.result {
        print("Upload開始")
      }
      return nil;
    }
    
    
    
    //モーダルビューを閉じる
    dismiss(animated: true, completion: {
      //画面遷移
      self.performSegue(withIdentifier: "showEffectView", sender: nil)
    })
  }


  
  
  
  
  //次の画面に遷移するときに渡す画像を格納する場所
  var captureImage : UIImage?
  //次の画面のインスタンスを取得
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let nextViewController = segue.destination as! EffectViewController
    //次の画面のインスタンスに取得した画像を渡す
    nextViewController.originalImage = captureImage
    nextViewController.uuid = uuid

  }

}
