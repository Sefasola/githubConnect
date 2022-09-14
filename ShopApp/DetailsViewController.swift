//
//  DetailsViewController.swift
//  ShopApp
//
//  Created by Sefa Akyüz on 9.09.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var İmage: UIImageView!
    @IBOutlet weak var ProductText: UITextField!
    @IBOutlet weak var SaleText: UITextField!
    @IBOutlet weak var SizeText: UITextField!
    @IBOutlet weak var Button: UIButton!
    
    var secılenUrunIsmı = ""
    var secılenUrunUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if secılenUrunIsmı != ""{
            Button.isHidden = true
            
            
            if let uuidString = secılenUrunUUID?.uuidString {
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appdelegate.persistentContainer.viewContext
                
                let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                fetchrequest.predicate = NSPredicate(format: "id = %@", uuidString )
                fetchrequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try context.fetch(fetchrequest)
                    
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "name") as? String {
                                ProductText.text = isim
                            }
                            
                            if let fiyat = sonuc.value(forKey: "fiyat") as? Int {
                                SaleText.text = String(fiyat)
                            }
                            
                            if let beden = sonuc.value(forKey: "size") as? String{
                                SizeText.text = beden
                            }
                            
                            if let gorselData = sonuc.value(forKey: "image") as? Data {
                                let image = UIImage(data: gorselData)
                                İmage.image = image
                            }
                        }
                    }
                }catch{
                    print("hata var")
                }
            }
        }
        else{
            Button.isHidden = false
            Button.isEnabled = false
            ProductText.text = ""
            SaleText.text = ""
            SizeText.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyikapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        İmage.isUserInteractionEnabled = true
        let imagegesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        İmage.addGestureRecognizer(imagegesturerecognizer)
       
        }
    
    @objc func gorselSec(){
      let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        İmage.image = info[.originalImage] as? UIImage
        Button.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
        
    

  @objc func klavyeyikapat(){
      view.endEditing(true)
}
    
    @IBAction func Button(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(ProductText.text, forKey: "name")
        alisveris.setValue(SizeText.text, forKey: "size")
        
        if let fiyat = Int(SaleText.text!) {
            alisveris.setValue(fiyat, forKey: "fiyat")
        }
        
        alisveris.setValue(UUID(), forKey: "id")
        
        let data = İmage.image?.jpegData(compressionQuality: 0.5)
        alisveris.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("kayıt edildi")
        }catch{
            print("hata var")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
 

}
