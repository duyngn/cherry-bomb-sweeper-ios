//
//  CreditsViewController.swift
//  CherryBombSweeper
//
//  Created by Duy Nguyen on 2/2/18.
//  Copyright © 2018 Duy.Ninja. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {
    
    struct CreditEntry {
        var image: UIImage?
        var text: String
        var link: String
        
        init(image: UIImage? = nil, text: String, link: String) {
            self.image = image
            self.text = text
            self.link = link
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var creditsTitle: UILabel!
    @IBOutlet private weak var imagesTitle: UILabel!
    @IBOutlet private weak var soundsTitle: UILabel!
    @IBOutlet private weak var fontsTitle: UILabel!
    @IBOutlet private weak var imagesCredits: UITextView!
    @IBOutlet private weak var soundsCredits: UITextView!
    @IBOutlet private weak var fontsCredits: UITextView!
    @IBOutlet private weak var aboutText: UITextView!
    
    lazy private var initOnce: Void = {
        self.setupAboutText()
        self.setupImagesCredits()
        self.setupSoundsCredits()
        self.setupFontsCredits()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.insertSubview(blurEffectView, at: 0)
        }
        
        let _ = initOnce
    }
    
    private func setupAboutText() {
        let aboutString = NSMutableAttributedString()
        aboutString.append(NSAttributedString(string: "Created with love by Duy Nguyen. :)\n\nPlease visit the README on GitHub for source code, play instructions and additional info."))
        
        let linkRangeName = (aboutString.string as NSString).range(of: "Duy Nguyen")
        aboutString.addAttribute(NSAttributedStringKey.link, value: "https://github.com/duyngn/cherry-bomb-sweeper-ios", range: linkRangeName)
        
        let linkRange = (aboutString.string as NSString).range(of: "README on GitHub")
        aboutString.addAttribute(NSAttributedStringKey.link, value: "https://github.com/duyngn/cherry-bomb-sweeper-ios", range: linkRange)
        
        self.aboutText.attributedText = aboutString
        self.aboutText.font = UIFont(name: Constants.digital7MonoFont, size: 18)
        
        let linkAttributes: [String : Any] = [NSAttributedStringKey.foregroundColor.rawValue: Constants.accentColor]
        
        self.aboutText.linkTextAttributes = linkAttributes
        self.aboutText.textColor = UIColor.white
    }
    
    private func setupImagesCredits() {
        let imageCredits: [CreditEntry] = [
            CreditEntry(image: GameIconsService.shared.bombImage, text: "Cherry Bomb Icon", link: "https://www.1001freedownloads.com/free-clipart/cartoon-bomb"),
            CreditEntry(image: GameIconsService.shared.gearImage, text: "Gear Icon", link: "https://www.1001freedownloads.com/free-clipart/architetto-ruota-dentata-2"),
            CreditEntry(image: GameIconsService.shared.shovelImage, text: "Shovel Icon", link: "https://www.1001freedownloads.com/free-clipart/shovel-4"),
            CreditEntry(image: GameIconsService.shared.flagImage, text: "Flag Icon", link: "https://www.1001freedownloads.com/free-clipart/game-marbles-flags"),
            CreditEntry(image: GameIconsService.shared.boomImage, text: "Explode Icon", link: "https://www.1001freedownloads.com/free-clipart/boom"),
            CreditEntry(image: GameIconsService.shared.brickTileImage, text: "Brick Background", link: "https://www.1001freedownloads.com/free-clipart/brick-tile"),
            CreditEntry(image: UIImage(named: "music-icon"), text: "Music Icon", link: "https://www.1001freedownloads.com/free-clipart/double_croche")
        ]
        
        self.setupCreditTexts(for: self.imagesCredits, credits: imageCredits)
    }
    
    private func setupSoundsCredits() {
        let musicIcon = UIImage(named: "music-icon")
        
        let soundCredits: [CreditEntry] = [
            CreditEntry(image: musicIcon, text: "Reveal", link: "https://freesound.org/people/NenadSimic/sounds/171697/"),
            CreditEntry(image: musicIcon, text: "Probe", link: "https://freesound.org/people/kwahmah_02/sounds/256116/"),
            CreditEntry(image: musicIcon, text: "Cancel", link: "https://freesound.org/people/hodomostvarujemritam/sounds/171273/"),
            CreditEntry(image: musicIcon, text: "Explosion", link: "https://freesound.org/people/Iwiploppenisse/sounds/156031/"),
            CreditEntry(image: musicIcon, text: "Flag Drop", link: "https://freesound.org/people/plasterbrain/sounds/237422/"),
            CreditEntry(image: musicIcon, text: "New Game", link: "https://freesound.org/people/InspectorJ/sounds/403009/"),
            CreditEntry(image: musicIcon, text: "Game Win", link: "https://freesound.org/people/LittleRobotSoundFactory/sounds/270404/"),
            CreditEntry(image: musicIcon, text: "Beep Beep", link: "https://freesound.org/people/Kodack/sounds/258193/"),
            CreditEntry(image: musicIcon, text: "Icon Selection", link: "https://freesound.org/people/PaulMorek/sounds/330052/"),
            CreditEntry(image: musicIcon, text: "Option Selection", link: "https://freesound.org/people/pan14/sounds/263133/"),
            CreditEntry(image: musicIcon, text: "Background Music", link: "https://freesound.org/people/RokZRooM/sounds/344778/"),
        ]
        
        self.setupCreditTexts(for: self.soundsCredits, credits: soundCredits)
    }
    
    private func setupFontsCredits() {
        let fontIcon = UIImage(named: "font-icon")
        
        let fontCredit: [CreditEntry] = [
            CreditEntry(image: fontIcon, text: Constants.digital7Font, link: "http://www.styleseven.com/php/get_product.php?product=Digital-7")
        ]
        
        self.setupCreditTexts(for: self.fontsCredits, credits: fontCredit)
    }

    private func setupCreditTexts(for textView: UITextView, credits: [CreditEntry]) {
        let fullAttributedString = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 29
        
        var count = 1
        for creditItem in credits {
            let creditString = NSMutableAttributedString()
            
            var iconBulletString: NSAttributedString
            if let image = creditItem.image {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = image
                imageAttachment.bounds = CGRect.init(x: 0, y: -3, width: 25, height: 25)
                
                iconBulletString = NSAttributedString(attachment: imageAttachment)
            } else {
                // do a normal bullet and increase the indent to compensate
                paragraphStyle.headIndent = 50
                iconBulletString = NSAttributedString(string: "\u{2022}")
            }
            
            creditString.append(iconBulletString)
            
            let returnCarriage = (count < credits.count) ? "\n\n" : ""
            creditString.append(NSAttributedString(string: "    \(creditItem.text) - [source]\(returnCarriage)"))
            
            creditString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, creditString.length))
            
            let linkRange = (creditString.string as NSString).range(of: "source")
            creditString.addAttribute(NSAttributedStringKey.link, value: creditItem.link, range: linkRange)
            
            fullAttributedString.append(creditString)
            
            count += 1
        }
        
        textView.attributedText = fullAttributedString
        textView.font = UIFont(name: Constants.digital7Font, size: 18)
        
        let linkAttributes: [String : Any] = [NSAttributedStringKey.foregroundColor.rawValue: Constants.accentColor]
        
        textView.linkTextAttributes = linkAttributes
        textView.textColor = UIColor.white
    }
    
    @IBAction func onCloseButtonPressed(_ sender: UIButton) {
        AudioService.shared.playRevealSound()
        
        self.scrollView.alpha = 0
        self.dismiss(animated: true)
    }
}

extension UITextView {
    override open func becomeFirstResponder() -> Bool {
        return false
    }
}
