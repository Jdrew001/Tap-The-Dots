import SpriteKit

class MenuScene: SKScene {
    private var buttons: [NeonButton] = [] // Array to hold buttons
    private var selectedIndex = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        //addElementToScreen()
        
        // Create the Play button
        let playButton = NeonButton(text: "Play", size: CGSize(width: 120, height: 30), color: .cyan) // Wider button
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100) // Lower on the screen
        playButton.setScale(0.5)
        addChild(playButton)

        // Create the Exit button
        let exitButton = NeonButton(text: "Exit", size: CGSize(width: 100, height: 30), color: .red) // Wider button
        exitButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150) // Closer to Play button
        exitButton.setScale(0.5)
        addChild(exitButton)

        // Add buttons to the array
        buttons = [playButton, exitButton]

        // Highlight the first button
        updateButtonHighlight()
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
            case 13: // A key (Move up)
                selectedIndex = max(0, selectedIndex - 1)
                updateButtonHighlight()

            case 1: // D key (Move down)
                selectedIndex = min(buttons.count - 1, selectedIndex + 1)
                updateButtonHighlight()

            case 36: // Enter key
                handleSelection()

            default:
                break
        }
    }
    
    private func updateButtonHighlight() {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                // Apply the highlight animation to the selected button
                if button.action(forKey: "highlight") == nil {
                    let pulseOut = SKAction.scale(to: 1.2, duration: 0.6)
                    let pulseIn = SKAction.scale(to: 1.0, duration: 0.6)
                    let pulseSequence = SKAction.sequence([pulseOut, pulseIn])
                    button.run(SKAction.repeatForever(pulseSequence), withKey: "highlight")
                }
            } else {
                // Stop the highlight animation for unselected buttons
                button.removeAction(forKey: "highlight")
                button.run(SKAction.scale(to: 1.0, duration: 0.1)) // Reset to default size
            }
        }
    }

    private func handleSelection() {
        let selectedButton = buttons[selectedIndex]

        if selectedButton.labelNode.text == "Play" {
            EventManager.shared.notify(event: "StartGame")
        } else if selectedButton.labelNode.text == "Exit" {
            exit(0) // Quit the application
        }
    }
    
    private func addElementToScreen() {
        // Set up the menu UI
        backgroundColor = .black

        let menuLabel = SKLabelNode(text: "Press Enter to Start")
        menuLabel.name = "menuLabel"
        menuLabel.fontSize = 40
        menuLabel.fontName = "Upheaval TT (BRK)"
        menuLabel.fontColor = .white
        menuLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Add a blinking effect
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.5) // Dim the label
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)  // Brighten the label
        let blink = SKAction.sequence([fadeOut, fadeIn])          // Combine actions
        menuLabel.run(SKAction.repeatForever(blink))
        addChild(menuLabel)
    }
}
