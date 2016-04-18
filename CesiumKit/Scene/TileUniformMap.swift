//
//  TileUniformMap.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 30/09/14.
//  Copyright (c) 2014 Test Toast. All rights reserved.
//

import Foundation
import simd

typealias Float4Tuple = (float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4, float4)

var float4Tuple: Float4Tuple = {
    (float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4(), float4())
}()

typealias FloatTuple = (Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float)

var floatTuple: FloatTuple = {
    (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
}()

private let MaximumMetalTextureCount = 31

struct TileUniformStruct: MetalUniformStruct {
    // Honestly...
    var dayTextureTexCoordsRectangle = float4Tuple
    var dayTextureTranslationAndScale = float4Tuple
    var dayTextureAlpha = floatTuple
    var dayTextureBrightness = floatTuple
    var dayTextureContrast = floatTuple
    var dayTextureHue = floatTuple
    var dayTextureSaturation = floatTuple
    var dayTextureOneOverGamma = floatTuple
    var waterMaskTranslationAndScale = float4()
    var initialColor = float4()
    var tileRectangle = float4()
    var modifiedModelView = float4x4()
    var center3D = float3()
    var southMercatorYAndOneOverHeight = float2()
    var southAndNorthLatitude = float2()
    var lightingFadeDistance = float2()
    var zoomedOutOceanSpecularIntensity = Float(0.0)
}
    
class TileUniformMap: UniformMap {
    
    let maxTextureCount: Int
    
    var initialColor: float4 {
        get {
            return _uniformStruct.initialColor
        }
        set {
            _uniformStruct.initialColor = newValue
        }
    }
    
    var zoomedOutOceanSpecularIntensity: Float {
        get {
            return _uniformStruct.zoomedOutOceanSpecularIntensity
        }
        set {
            _uniformStruct.zoomedOutOceanSpecularIntensity = newValue
        }
    }
    
    var oceanNormalMap: Texture? = nil
    
    var lightingFadeDistance: float2 {
        get {
            return _uniformStruct.lightingFadeDistance
        }
        set {
            _uniformStruct.lightingFadeDistance = newValue
        }
    }
    
    var center3D: float3 {
        get {
            return _uniformStruct.center3D
        }
        set {
            _uniformStruct.center3D = newValue
        }
    }
    
    var modifiedModelView: float4x4 {
        get {
            return _uniformStruct.modifiedModelView
        }
        set {
            _uniformStruct.modifiedModelView = newValue
        }
    }
    
    var tileRectangle: float4 {
        get {
            return _uniformStruct.tileRectangle
        }
        set {
            _uniformStruct.tileRectangle = newValue
        }
    }
    
    var dayTextures: [Texture]
    
    var dayTextureTranslationAndScale: [float4] {
        get {
            var floatArray = [float4](count: MaximumMetalTextureCount, repeatedValue: float4())
            memcpy(&floatArray, &_uniformStruct.dayTextureTranslationAndScale, sizeof(float4) * MaximumMetalTextureCount)
            return floatArray
        }
        set {
            memcpy(&_uniformStruct.dayTextureTranslationAndScale, newValue, sizeof(float4) * MaximumMetalTextureCount)
        }
    }
    
    var dayTextureTexCoordsRectangle: [float4] {
        get {
            var floatArray = [float4](count: MaximumMetalTextureCount, repeatedValue: float4())
            memcpy(&floatArray, &_uniformStruct.dayTextureTexCoordsRectangle, sizeof(float4) * MaximumMetalTextureCount)
            return floatArray
        }
        set {
            memcpy(&_uniformStruct.dayTextureTexCoordsRectangle, newValue, sizeof(float4) * MaximumMetalTextureCount)
        }
    }
    
    var dayTextureAlpha: [Float]
    var dayTextureBrightness: [Float]
    var dayTextureContrast: [Float]
    var dayTextureHue: [Float]
    var dayTextureSaturation: [Float]
    var dayTextureOneOverGamma: [Float]
    
    var dayIntensity = 0.0
    
    var southAndNorthLatitude: float2 {
        get {
            return _uniformStruct.southAndNorthLatitude
        }
        set {
            _uniformStruct.southAndNorthLatitude = newValue
        }
    }
    
    var southMercatorYAndOneOverHeight: float2 {
        get {
            return _uniformStruct.southMercatorYAndOneOverHeight
        }
        set {
            _uniformStruct.southMercatorYAndOneOverHeight = newValue
        }
    }
    
    var waterMask: Texture? = nil
    
    var waterMaskTranslationAndScale: float4 {
        get {
            return _uniformStruct.waterMaskTranslationAndScale
        }
        set {
            _uniformStruct.waterMaskTranslationAndScale = newValue
        }
    }
    
    private var _uniformStruct = TileUniformStruct()
    
    let uniforms: [String: UniformFunc] = [:
            /*
    
        "u_initialColor": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).initialColor.floatRepresentation
            memcpy(buffer, [simd], strideofValue(simd))
        },
        
        "u_zoomedOutOceanSpecularIntensity": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! TileUniformMap).zoomedOutOceanSpecularIntensity], sizeof(Float))
        },
        
        "u_lightingFadeDistance": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).lightingFadeDistance.floatRepresentation
            memcpy(buffer, [simd], sizeof(float2))
        },
        
        "u_center3D": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = vector_float((map as! TileUniformMap).center3D.simdType)
            memcpy(buffer, [simd], sizeof(float3))
        },
        
        "u_tileRectangle": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).tileRectangle.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4x4))
        },
        
        "u_modifiedModelView": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).modifiedModelView.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4x4))
        },

        "u_dayTextureTranslationAndScale": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).dayTextureTranslationAndScale.map { $0.floatRepresentation }
            memcpy(buffer, simd, simd.sizeInBytes)
        },
        
        "u_dayTextureTexCoordsRectangle": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).dayTextureTexCoordsRectangle.map { $0.floatRepresentation }
            memcpy(buffer, simd, simd.sizeInBytes)
        },
        
        "u_dayTextureAlpha": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureAlpha = (map as! TileUniformMap).dayTextureAlpha
            memcpy(buffer, dayTextureAlpha, dayTextureAlpha.sizeInBytes)
        },
        
        "u_dayTextureBrightness": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureBrightness = (map as! TileUniformMap).dayTextureBrightness
            memcpy(buffer, dayTextureBrightness, dayTextureBrightness.sizeInBytes)
        },
        
        "u_dayTextureContrast": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureContrast = (map as! TileUniformMap).dayTextureContrast
            memcpy(buffer, dayTextureContrast, dayTextureContrast.sizeInBytes)
        },
        
        "u_dayTextureHue": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureHue = (map as! TileUniformMap).dayTextureHue
            memcpy(buffer, dayTextureHue, dayTextureHue.sizeInBytes)
        },
        
        "u_dayTextureSaturation": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureSaturation = (map as! TileUniformMap).dayTextureSaturation
            memcpy(buffer, dayTextureSaturation, dayTextureSaturation.sizeInBytes)
        },
        
        "u_dayTextureOneOverGamma": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let dayTextureOneOverGamma = (map as! TileUniformMap).dayTextureOneOverGamma
            memcpy(buffer, dayTextureOneOverGamma, dayTextureOneOverGamma.sizeInBytes)
        },
        
        "u_dayIntensity": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            memcpy(buffer, [(map as! TileUniformMap).dayIntensity], sizeof(Float))
        },
        
        "u_southAndNorthLatitude": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).southAndNorthLatitude.floatRepresentation
            memcpy(buffer, [simd], sizeof(float2))
        },
        
        "u_southMercatorYLowAndHighAndOneOverHeight": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = vector_float((map as! TileUniformMap).southMercatorYLowAndHighAndOneOverHeight.simdType)
            memcpy(buffer, [simd], sizeof(float3))
        },

        "u_waterMaskTranslationAndScale": { (map: UniformMap, buffer: UnsafeMutablePointer<Void>) in
            let simd = (map as! TileUniformMap).waterMaskTranslationAndScale.floatRepresentation
            memcpy(buffer, [simd], sizeof(float4))
        }
    */
    ]
    
    init(maxTextureCount: Int) {
        self.maxTextureCount = maxTextureCount
        dayTextures = [Texture]()
        dayTextures.reserveCapacity(maxTextureCount)
        //dayTextureTranslationAndScale = [Cartesian4]()
        //dayTextureTexCoordsRectangle = [Cartesian4]()
        dayTextureAlpha = [Float]()
        dayTextureBrightness = [Float]()
        dayTextureContrast = [Float]()
        dayTextureHue = [Float]()
        dayTextureSaturation = [Float]()
        dayTextureOneOverGamma = [Float]()
        
         metalUniformUpdateBlock = { buffer in
            memcpy(buffer.data, &self._uniformStruct, sizeof(TileUniformStruct))
            var textures = self.dayTextures
            if let waterMask = self.waterMask {
                textures.append(waterMask)
            }
            if let oceanNormalMap = self.oceanNormalMap {
                textures.append(oceanNormalMap)
            }
            return textures
        }

    }
    
    var metalUniformUpdateBlock: ((buffer: Buffer) -> ([Texture]))!
    
    
    func textureForUniform (uniform: UniformSampler) -> Texture? {
        let dayTextureCount = dayTextures.count
        if uniform.textureUnitIndex == dayTextureCount {
            return waterMask
        } else if uniform.textureUnitIndex == dayTextureCount + 1 {
            return oceanNormalMap
        }
        return dayTextures[uniform.textureUnitIndex]
    }
    
}