//
//  UniverseScene.swift
//  MO
//
//  Created by travis on 2017-02-08.
//  Copyright © 2017 Slant. All rights reserved.
//

import SpriteKit
import MO
import C4

class UniverseScene: SKScene {
    var cassini: CassiniSpaceCraft?
    var voyager: VoyagerSpaceCraft?
    var copyableAsteroids: [Asteroid]?
    var copyableKuiperAsteroids: [KuiperAsteroid]?
    var cometAuraFrames: [SKTexture]?
    var cometAura: SKSpriteNode?
    let cometAuraAtlas = SKTextureAtlas(named: "comet_aura")

    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = .clear

        cometAuraFrames = [SKTexture]()
        for i in 0..<cometAuraAtlas.textureNames.count/2 {
            let texture = cometAuraAtlas.textureNamed("comet_aura_\(i)")
            cometAuraFrames?.append(texture)
        }

        copyableAsteroids = [Asteroid]()
        for i in 0...3 {
            let asteroid = Asteroid(imageNamed: "Asteroid_0\(i)")
            asteroid.size = CGSize(width: 132, height: 132)
            asteroid.physicsBody = nil
            copyableAsteroids?.append(asteroid)
        }

        copyableKuiperAsteroids = [KuiperAsteroid]()
        for i in 0...3 {
            let asteroid = KuiperAsteroid(imageNamed: "Asteroid_0\(i)")
            asteroid.size = CGSize(width: 132, height: 132)
            asteroid.physicsBody = nil
            copyableKuiperAsteroids?.append(asteroid)
        }

        playRandomAmbient()
        listener = SKNode()
    }

    var currentAudio: AudioPlayer?

    func playRandomAmbient() {
        let fileName = "spaceAmbient\(random(below: 5)).aiff"

        guard let audio = AudioPlayer(fileName) else {
            print("Couldn't load \(fileName)")
            return
        }

        audio.play()
        currentAudio = audio

        wait(audio.duration) {
            self.currentAudio?.stop()
            self.currentAudio = nil
            self.playRandomAmbient()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .clear

        size = view.bounds.size
    }

    // creates a comet at a specific point and removes an asteroid (if the asteroid exists)
    func addComet(identifier: Int, position: CGPoint) {
        createComet(identifier: identifier, position: position)
    }

    func addKuiperComet(identifier: Int, position: CGPoint) {
        createKuiperComet(identifier: identifier, position: position)
    }

    //creates a comet (an asteroid with an animated aura)
    func createComet(identifier: Int, position: CGPoint) {
        guard let comet = self.copyableAsteroids?[identifier % 4].copy() as! Asteroid? else {
            print("Couldn't create a copy of the asteroid")
            return
        }

        comet.isUserInteractionEnabled = false
        comet.position = position
        comet.physicsBody = nil
        addAura(to: comet)

        let audio = SKAudioNode(fileNamed: "cometNoise.aiff")
        audio.autoplayLooped = true
        comet.addChild(audio)
        audio.isPositional = true
        let actions = moveComet()
        comet.run(actions.0)
        audio.run(actions.1)

        self.addChild(comet)
    }

    func createKuiperComet(identifier: Int, position: CGPoint) {
        guard let comet = self.copyableKuiperAsteroids?[identifier % 4].copy() as! KuiperAsteroid? else {
            print("Couldn't create a copy of the asteroid")
            return
        }

        comet.isUserInteractionEnabled = false
        comet.position = position
        comet.physicsBody = nil
        addKuiperAura(to: comet)

        let audio = SKAudioNode(fileNamed: "cometNoise.aiff")
        audio.autoplayLooped = true
        comet.addChild(audio)
        audio.isPositional = true
        let actions = moveKuiperComet()
        comet.run(actions.0)
        audio.run(actions.1)

        self.addChild(comet)
    }

    //creates an action for the motion of a comet
    func moveComet() -> (SKAction, SKAction) {
        let movement = SKAction.move(by: CGVector(dx: CGFloat(frameCanvasWidth * 26.0), dy: 0), duration: 10.0)
        let scale = SKAction.scale(by: 0.25, duration: movement.duration * 0.5)
        let fade = SKAction.fadeOut(withDuration: movement.duration * 0.5)
        let wait = SKAction.wait(forDuration: movement.duration * 0.5)
        let fadeScale = SKAction.group([fade, scale])
        let waitFadeScale = SKAction.sequence([wait, fadeScale, SKAction.removeFromParent()])

        let play = SKAction.play()
        let audioWait = SKAction.wait(forDuration: movement.duration * 0.25)
        let audioFade = SKAction.changeVolume(to: 0.0, duration: movement.duration*0.25)
        let audioWaitFade = SKAction.sequence([audioWait, audioFade, SKAction.stop(), SKAction.removeFromParent()])

        return (SKAction.group([movement, waitFadeScale]), SKAction.group([play, audioWaitFade]))
    }

    func moveKuiperComet() -> (SKAction, SKAction) {
        let movement = SKAction.move(by: CGVector(dx: CGFloat(-frameCanvasWidth * 24.0), dy: 0), duration: 10.0)
        let scale = SKAction.scale(by: 0.25, duration: movement.duration * 0.5)
        let fade = SKAction.fadeOut(withDuration: movement.duration * 0.5)
        let wait = SKAction.wait(forDuration: movement.duration * 0.5)
        let fadeScale = SKAction.group([fade, scale])
        let waitFadeScale = SKAction.sequence([wait, fadeScale, SKAction.removeFromParent()])

        let play = SKAction.play()
        let audioWait = SKAction.wait(forDuration: movement.duration * 0.25)
        let audioFade = SKAction.changeVolume(to: 0.0, duration: movement.duration*0.25)
        let audioWaitFade = SKAction.sequence([audioWait, audioFade, SKAction.stop(), SKAction.removeFromParent()])

        return (SKAction.group([movement, waitFadeScale]), SKAction.group([play, audioWaitFade]))
    }

    //adds an animated aura to an asteroid
    func addAura(to asteroid: Asteroid) {
        guard let texture = cometAuraFrames?[0] else {
            print("could not extract a texture")
            return
        }

        let aura = SKSpriteNode(texture: texture)
        aura.anchorPoint = CGPoint(x: 0.85, y: 0.45)

        guard let frames = cometAuraFrames else {
            print("Frames weren't available")
            return
        }

        let anim = SKAction.animate(with: frames, timePerFrame: 1.0/12.0, resize: false, restore: true)
        let repeatAnim = SKAction.repeatForever(anim)
        aura.run(repeatAnim)
        asteroid.addChild(aura)
        asteroid.aura = aura
    }

    //adds an animated aura to an asteroid
    func addKuiperAura(to asteroid: KuiperAsteroid) {
        guard let texture = cometAuraFrames?[0] else {
            print("could not extract a texture")
            return
        }

        let aura = SKSpriteNode(texture: texture)
        aura.anchorPoint = CGPoint(x: 0.85, y: 0.45)
        aura.zRotation = CGFloat(M_PI)

        guard let frames = cometAuraFrames else {
            print("Frames weren't available")
            return
        }

        let anim = SKAction.animate(with: frames, timePerFrame: 1.0/12.0, resize: false, restore: true)
        let repeatAnim = SKAction.repeatForever(anim)
        aura.run(repeatAnim)
        asteroid.addChild(aura)
        asteroid.aura = aura
    }

    //MARK: Cassini
    func transmitCassini(coordinates: CGPoint) {
        cassini?.rotateAndMove(to: convertCoordinates(coordinates))
    }

    func transmitVoyager(coordinates: CGPoint) {
        voyager?.rotateAndMove(to: convertCoordinates(coordinates))
    }

    func convertCoordinates(_ point: CGPoint) -> CGPoint {
        var dx = CGFloat(-SocketManager.sharedManager.deviceID)
        dx *= CGFloat(frameCanvasWidth)
        dx -= CGFloat(frameCanvasWidth/2.0)
        let coordinates = CGPoint(x: point.x + dx, y: point.y)
        return coordinates
    }
}
