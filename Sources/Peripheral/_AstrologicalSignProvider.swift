// Copyright © 2015
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:  The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import C4

//typealias that returns an astrological sign
//so we can "store" the methods in a dictionary
typealias AstrologicalSignFunction = () -> AstrologicalSign

//Structure that represents a sign
struct AstrologicalSign {
    //relative positions of big stars
    var big: [Point]!
    //relative positions of small stars
    var small: [Point]!
}

class AstrologicalSignProvider: NSObject {
    //(mark)  -
    //(mark)  Properties
    //Creates a singleton
    static let shared = AstrologicalSignProvider()

    //Sets the order of the signs
    let order = ["andromeda",
                     "antlia",
                     "apus",
                     "aquila",
                     "aquarius",
                     "ara",
                     "aries",
                     "auriga",
                     "bootes",
                     "caelum",
                     "cameoparadalis",
                     "capricornus",
                     "carina",
                     "casseopeia",
                     "centaurus",
                     "cephus",
                     "cetus",
                     "chamaeleon",
                     "circinus",
                     "canisMajor",
                     "canisMinor",
                     "cancer",
                     "columba",
                     "comaBerenices",
                     "coronaBorealis",
                     "crater",
                     "crux",
                     "corvus",
                     "canisVenatici",
                     "cygnus",
                     "coronaAustralis",
                     "dorado",
                     "draco",
                     "equuleus",
                     "eridanus",
                     "delphinus",
                     "fornax",
                     "hydrus",
                     "grus",
                     "hercules",
                     "horologium",
                     "hydra",
                     "gemini",
                     "leoMinor",
                     "lacerta",
                     "leo",
                     "lepus",
                     "libra",
                     "indus",
                     "monoceros",
                     "lynx",
                     "lyra",
                     "mensa",
                     "microscopium",
                     "lupus",
                     "pavo",
                     "norma",
                     "octans",
                     "ophiucus",
                     "orion",
                     "musca",
                     "perseus",
                     "phoenix",
                     "pictor",
                     "picisAustrinus",
                     "pegasus",
                     "pisces",
                     "reticulum",
                     "puppis",
                     "pyxis",
                     "scorpius",
                     "scutum",
                     "serpensCauda",
                     "serpensCaput",
                     "sculptor",
                     "sextans",
                     "sagittarius",
                     "taurus",
                     "telescopium",
                     "triangulumAustrale",
                     "triangulum",
                     "tucana",
                     "sagitta",
                     "ursaMinor",
                     "ursaMajor",
                     "vela",
                     "virgo",
                     "volans",
                     "vulpecula"]

    //Maps the name of a sign to a method that will return it
    internal var mappings = [String: AstrologicalSignFunction]()

    //(mark)  -
    //(mark)  Initialization
    override init() {
        super.init()
        mappings = [
            "andromeda": andromeda,
            "antlia": antlia,
            "apus": apus,
            "aquarius": aquarius,
            "aquila": aquila,
            "ara": ara,
            "aries": aries,
            "auriga": auriga,
            "bootes": bootes,
            "caelum": caelum,
            "cameoparadalis": cameoparadalis,
            "cancer": cancer,
            "canisMajor": canisMajor,
            "canisMinor": canisMinor,
            "canisVenatici": canisVenatici,
            "capricornus": capricornus,
            "carina": carina,
            "casseopeia": casseopeia,
            "centaurus": centaurus,
            "cephus": cephus,
            "cetus": cetus,
            "chamaeleon": chamaeleon,
            "circinus": circinus,
            "columba": columba,
            "comaBerenices": comaBerenices,
            "coronaAustralis": coronaAustralis,
            "coronaBorealis": coronaBorealis,
            "corvus": corvus,
            "crater": crater,
            "crux": crux,
            "cygnus": cygnus,
            "delphinus": delphinus,
            "dorado": dorado,
            "draco": draco,
            "equuleus": equuleus,
            "eridanus": eridanus,
            "fornax": fornax,
            "gemini": gemini,
            "grus": grus,
            "hercules": hercules,
            "horologium": horologium,
            "hydra": hydra,
            "hydrus": hydrus,
            "indus": indus,
            "lacerta": lacerta,
            "leo": leo,
            "leoMinor": leoMinor,
            "lepus": lepus,
            "libra": libra,
            "lupus": lupus,
            "lynx": lynx,
            "lyra": lyra,
            "mensa": mensa,
            "microscopium": microscopium,
            "monoceros": monoceros,
            "musca": musca,
            "norma": norma,
            "octans": octans,
            "ophiucus": ophiucus,
            "orion": orion,
            "pavo": pavo,
            "pegasus": pegasus,
            "perseus": perseus,
            "phoenix": phoenix,
            "picisAustrinus": picisAustrinus,
            "pictor": pictor,
            "pisces": pisces,
            "puppis": puppis,
            "pyxis": pyxis,
            "reticulum": reticulum,
            "sagitta": sagitta,
            "sagittarius": sagittarius,
            "scorpius": scorpius,
            "sculptor": sculptor,
            "scutum": scutum,
            "serpensCaput": serpensCaput,
            "serpensCauda": serpensCauda,
            "sextans": sextans,
            "taurus": taurus,
            "telescopium": telescopium,
            "triangulum": triangulum,
            "triangulumAustrale": triangulumAustrale,
            "tucana": tucana,
            "ursaMajor": ursaMajor,
            "ursaMinor": ursaMinor,
            "vela": vela,
            "virgo": virgo,
            "volans": volans,
            "vulpecula": vulpecula
        ]

    }

    //(mark)  -
    //(mark)  Get
    //method that takes the name of a sign and returns the corresponding structure
    func get(sign: String) -> AstrologicalSign? {
        //grabs the function
        let function = mappings[sign.lowercased()]
        //returns the results of executing the function
        return function!()
    }

    //(mark)
    //(mark) Signs
    //The following methods each represent an astrological sign, whose points (big/small) are calculated relative to {0, 0}
    func andromeda() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(257.701, 293.049),
                   Point(142.725, 238.09),
                   Point(60.211, 166.915),
                   Point(197.512, 281.135),
                   Point(109.529, 120.167),
                   Point(351.108, 157.079)]
        sign.big = big

        let small = [Point(166.642, 214.123),
                     Point(288.348, 135.239),
                     Point(181.923, 338.841),
                     Point(287.455, 154.306),
                     Point(150.105, 136.777),
                     Point(292.69, 162.807),
                     Point(201.583, 256.068),
                     Point(199.214, 294.645),
                     Point(161.351, 345.848),
                     Point(178.812, 191.852),
                     Point(166.061, 344.153)]
        sign.small = small
        return sign
    }

    func antlia() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(155.154, 167.649),
                     Point(259.277, 213.31),
                     Point(106.079, 224.757)]
        sign.small = small
        return sign
    }

    func apus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(225.705, 243.78),
                   Point(167.366, 237.165),
                   Point(158.999, 222.267),
                   Point(174.507, 233.962)]
        sign.big = big
        return sign
    }

    func aquarius() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(248.011, 175.579),
                     Point(198.481, 143.997),
                     Point(129.031, 235.085),
                     Point(164.427, 142.311),
                     Point(109.491, 266.976),
                     Point(130.53, 187.015),
                     Point(310.213, 201.549),
                     Point(175.073, 150.193),
                     Point(90.458, 261.607),
                     Point(154.79, 143.002),
                     Point(182.223, 187.427),
                     Point(98.786, 179.255),
                     Point(197.005, 222.918),
                     Point(94.463, 197.731),
                     Point(169.615, 134.122)]
        sign.small = small
        return sign
    }

    func aquila() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(162.806, 141.814),
                   Point(172.644, 126.572),
                   Point(261.21, 97.977),
                   Point(117.775, 226.335),
                   Point(217.882, 192.068),
                   Point(260.232, 261.792),
                   Point(152.896, 163.287)]
        sign.big = big
        
        let small = [Point(158.99, 210.506),
                     Point(273.688, 87.378),
                     Point(270.292, 269.224),
                     Point(193.41, 230.56)]
        sign.small = small
        return sign
    }

    func ara() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(193.434, 209.574),
                   Point(182.215, 143.646),
                   Point(236.711, 217.736),
                   Point(193.115, 219.449),
                   Point(184.108, 269.561),
                   Point(117.192, 150.635),
                   Point(245.899, 254.757),
                   Point(238.727, 184.789)]
        sign.big = big
        return sign
    }

    func aries() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(251.613, 169.472),
                   Point(278.297, 191.147),
                   Point(281.474, 204.19),
                   Point(166.192, 137.757)]
        sign.big = big
        return sign
    }

    func auriga() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(230.113, 129.913),
                   Point(223.05, 282.608),
                   Point(164.101, 140.309),
                   Point(161.133, 207.828),
                   Point(274.576, 238.021)]
        sign.big = big

        let small = [Point(254.775, 146.637),
                     Point(249.948, 169.922),
                     Point(167.29, 58.783),
                     Point(256.71, 170.578),
                     Point(163.816, 131.648)]
        sign.small = small
        return sign
    }

    func bootes() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(216.298, 295.857),
                   Point(157.053, 226.928),
                   Point(260.794, 300.346),
                   Point(182.635, 129.226),
                   Point(103.163, 168.739),
                   Point(132.169, 109.149),
                   Point(182.788, 198.586)]
        sign.big = big

        let small = [Point(161.692, 343.734),
                     Point(193.32, 10.839),
                     Point(207.82, 60.925),
                     Point(210.624, 10.975),
                     Point(277.179, 307.208)]
        sign.small = small
        return sign
    }

    func caelum() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(195.812, 222.806),
                   Point(140.042, 149.658)]
        sign.big = big

        let small = [Point(193.025, 167.794),
                     Point(215.491, 259.332)]
        sign.small = small
        return sign
    }

    func cameoparadalis() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(269.225, 262.199),
                   Point(324.718, 217.851),
                   Point(257.346, 229.338),
                   Point(290.68, 207.916),
                   Point(293.101, 293.419),
                   Point(185.347, 187.679),
                   Point(265.426, 185.411),
                   Point(206.884, 230.349)]
        sign.big = big
        return sign
    }

    func cancer() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(216.315, 296.001)]
        sign.big = big

        let small = [Point(154.373, 124.861),
                     Point(125.257, 271.645),
                     Point(159.719, 188.708),
                     Point(156.243, 217.594)]
        sign.small = small
        return sign
    }

    func canisMajor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(185.991, 153.468),
                   Point(160.075, 260.88),
                   Point(140.415, 238.932),
                   Point(232.761, 165.175),
                   Point(111.259, 265.88)]
        sign.big = big

        let small = [Point(168.103, 218.887),
                     Point(203.486, 175.802),
                     Point(166.391, 112.772),
                     Point(146.621, 144.642),
                     Point(162.972, 156.662),
                     Point(125.025, 252.639)]
        sign.small = small
        return sign
    }

    func canisMinor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(158.598, 223.78),
                   Point(193.811, 188.181)]
        sign.big = big
        return sign
    }

    func canisVenatici() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(193.548, 215.996)]
        sign.big = big

        let small = [Point(229.761, 187.894)]
        sign.small = small
        return sign
    }

    func capricornus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(87.462, 171.461),
                   Point(268.953, 158.641),
                   Point(276.436, 139.516)]
        sign.big = big

        let small = [Point(102.327, 175.183),
                     Point(132.426, 223.977),
                     Point(173.892, 177.71),
                     Point(202.363, 262.391),
                     Point(213.895, 248.173),
                     Point(128.049, 218.874),
                     Point(109.978, 199.281),
                     Point(172.146, 245.65),
                     Point(192.643, 256.865),
                     Point(114.844, 204.43)]
        sign.small = small
        return sign
    }

    func carina() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(336.517, 153.819),
                   Point(145.863, 272.534),
                   Point(154.967, 138.748),
                   Point(183.522, 179.212),
                   Point(123.052, 184.136),
                   Point(57.979, 258.133),
                   Point(103.182, 289.683),
                   Point(67.749, 222.323),
                   Point(55.365, 232.244),
                   Point(217.125, 123.555)]
        sign.big = big
        
        let small = [Point(22.618, 223.325),
                     Point(9.368, 234.099),
                     Point(29.246, 256.849),
                     Point(13.026, 246.091)]
        sign.small = small
        return sign
    }

    func casseopeia() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(209.287, 248.218),
                   Point(242.373, 220.712),
                   Point(189.254, 212.567),
                   Point(157.783, 215.403),
                   Point(133.401, 181.282)]
        sign.big = big
        return sign
    }

    func centaurus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(112.83, 304.225),
                   Point(138.166, 294.919),
                   Point(107.48, 158.466),
                   Point(203.651, 224.218),
                   Point(151.028, 252.117)]
        sign.big = big

        let small = [Point(84.202, 199.188),
                     Point(131.303, 218.67),
                     Point(233.612, 237.786),
                     Point(161.678, 153.137),
                     Point(132.806, 190.005),
                     Point(59.916, 207.208),
                     Point(132.228, 185.461),
                     Point(123.24, 189.409),
                     Point(269.684, 268.823),
                     Point(150.909, 169.745),
                     Point(215.804, 232.59),
                     Point(229.17, 246.799),
                     Point(93.644, 170.73),
                     Point(208.467, 172.143),
                     Point(253.068, 293.97)]
        sign.small = small
        return sign
    }

    func cephus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(260.168, 289.515),
                   Point(154.537, 164.696),
                   Point(231.646, 225.332),
                   Point(209.913, 338.383),
                   Point(295.273, 282.354)]
        sign.big = big

        let small = [Point(187.733, 337.48),
                     Point(168.902, 268.702),
                     Point(241.683, 328.703),
                     Point(205.528, 348.852),
                     Point(305.069, 265.657)]
        sign.small = small
        return sign
    }

    func cetus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(270.709, 231.463)]
        sign.big = big

        let small = [Point(68.271, 104.731),
                     Point(134.672, 142.31),
                     Point(97.274, 107.782),
                     Point(237.612, 184.359),
                     Point(186.649, 216.965),
                     Point(308.691, 180.695),
                     Point(215.707, 172.091),
                     Point(176.103, 184.346),
                     Point(103.945, 124.377),
                     Point(92.447, 67.93),
                     Point(118.85, 76.24),
                     Point(70.093, 76.454)]
        sign.small = small
        return sign
    }

    func chamaeleon() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(268.475, 191.805),
                     Point(182.595, 187.111),
                     Point(129.059, 208.94),
                     Point(263.765, 196.601),
                     Point(178.177, 209.849),
                     Point(133.452, 192.937)]
        sign.small = small
        return sign
    }

    func circinus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(170.75, 236.089),
                   Point(114.806, 170.367),
                   Point(107.354, 178.003)]
        sign.big = big

        let small = [Point(150.634, 212.002)]
        sign.small = small
        return sign
    }

    func columba() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(223.302, 156.108),
                   Point(195.744, 175.147),
                   Point(120.128, 150.316),
                   Point(242.639, 173.416),
                   Point(177.292, 257.247)]
        sign.big = big
        return sign
    }

    func comaBerenices() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(163.712, 159.502),
                     Point(165.833, 249.952),
                     Point(250.576, 154.505)]
        sign.small = small
        return sign
    }

    func coronaAustralis() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(113.152, 172.857),
                   Point(107.021, 183.273),
                   Point(107.386, 200.056),
                   Point(112.412, 213.103),
                   Point(189.412, 230.817)]
        sign.big = big
        return sign
    }

    func coronaBorealis() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(252.041, 240.283),
                   Point(267.917, 211.38),
                   Point(231.25, 246.143),
                   Point(192.381, 240.189),
                   Point(253.418, 186.009),
                   Point(213.392, 249.328)]
        sign.big = big
        
        let small = [Point(182.462, 205.56)]
        sign.small = small
        return sign
    }

    func corvus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(225.632, 176.371),
                   Point(174.435, 244.2),
                   Point(186.558, 163.988),
                   Point(239.667, 235.906)]
        sign.big = big
        return sign
    }

    func crater() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(215.897, 200.95),
                   Point(269.581, 243.213),
                   Point(200.096, 234.658),
                   Point(235.596, 295.039)]
        sign.big = big

        let small = [Point(166.62, 142.856),
                     Point(144.997, 242.725),
                     Point(201.339, 155.147),
                     Point(113.426, 229.469)]
        sign.small = small
        return sign
    }

    func crux() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(190.668, 235.402),
                   Point(160.15, 196.516),
                   Point(184.334, 165.638),
                   Point(208.616, 185.325)]
        sign.small = big
        return sign
    }

    func cygnus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(169.17, 198.575),
                   Point(199.734, 242.242),
                   Point(156.898, 296.584),
                   Point(255.9, 195.38),
                   Point(304.865, 339.008),
                   Point(103.565, 324.892)]
        sign.big = big

        let small = [Point(268.454, 134.915),
                     Point(282.078, 117.452),
                     Point(142.012, 232.947),
                     Point(208.105, 177.141)]
        sign.small = small
        return sign
    }

    func delphinus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(192.529, 184.606),
                   Point(186.629, 169.268),
                   Point(166.948, 166.727),
                   Point(205.012, 222.914),
                   Point(175.874, 179.01)]
        sign.big = big
        return sign
    }

    func dorado() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(229.66, 145.439),
                   Point(266.34, 108.523),
                   Point(132.539, 272.406),
                   Point(115.254, 244.32)]
        sign.big = big

        let small = [Point(141.021, 232.915),
                     Point(177.544, 171.68)]
        sign.small = small
        return sign
    }

    func draco() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(76.08, 255.989)]
        sign.big = big

        let small = [Point(168.029, 225.093),
                     Point(100.94, 262.796),
                     Point(88.446, 146.897),
                     Point(143.54, 195.206),
                     Point(212.927, 238.735),
                     Point(127.3, 142.185),
                     Point(257.52, 190.737),
                     Point(93.63, 229.846),
                     Point(88.913, 122.586),
                     Point(296.333, 106.809),
                     Point(277.687, 133.142),
                     Point(183.855, 243.18),
                     Point(105.877, 246.724),
                     Point(122.715, 148.903),
                     Point(135.615, 177.312)]
        sign.small = small
        return sign
    }

    func equuleus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(192.436, 235.4),
                   Point(196.219, 179.923)]
        sign.big = big

        let small = [Point(208.096, 178.435)]
        sign.small = small
        return sign
    }

    func eridanus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(297.835, 378.903)]
        sign.big = big

        let small = [Point(48.86, 73.28),
                     Point(233.162, 267.783),
                     Point(159.467, 110.083),
                     Point(180.961, 87.789),
                     Point(139.887, 229.632),
                     Point(288.592, 342.907),
                     Point(196.562, 86.064),
                     Point(213.783, 158.246),
                     Point(116.334, 213.026),
                     Point(252.078, 85.771),
                     Point(96.537, 55.74),
                     Point(132.573, 231.546),
                     Point(81.978, 57.051),
                     Point(236.214, 170.519),
                     Point(253.339, 267.316),
                     Point(174.665, 241.893),
                     Point(176.658, 166.392),
                     Point(261.748, 314.673),
                     Point(207.996, 282.285),
                     Point(194.348, 156.968),
                     Point(176.767, 101.444),
                     Point(262.688, 143.55),
                     Point(118.354, 208.12),
                     Point(189.167, 265.529),
                     Point(159.273, 171.359),
                     Point(167.664, 174.535),
                     Point(252.073, 284.986),
                     Point(267.287, 116.438),
                     Point(136.611, 72.379),
                     Point(131.671, 77.442)]
        sign.small = small
        return sign
    }

    func fornax() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(141.352, 194.155),
                     Point(185.298, 222.794),
                     Point(270.035, 199.565)]
        sign.small = small
        return sign
    }

    func gemini() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(78.58, 126.77),
                   Point(101.657, 94.65),
                   Point(212.039, 232.581),
                   Point(240.846, 178.286),
                   Point(198.288, 156.462),
                   Point(257.157, 177.59),
                   Point(196.342, 263.396),
                   Point(125.198, 182.66),
                   Point(77.706, 158.51),
                   Point(127.315, 230.35),
                   Point(181.019, 79.343)]
        sign.big = big
        
        let small = [Point(116.559, 131.352),
                     Point(157.381, 196.068),
                     Point(96.165, 138.006),
                     Point(229.358, 198.823),
                     Point(278.397, 169.679),
                     Point(145.672, 111.187)]
        sign.small = small
        return sign
    }

    func grus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(219.765, 219.557),
                   Point(168.399, 218.173),
                   Point(250.33, 138.129),
                   Point(161.829, 257.26)]
        sign.big = big

        let small = [Point(188.473, 188.191),
                     Point(146.131, 271.054),
                     Point(187.697, 190.405),
                     Point(227.686, 155.141),
                     Point(210.943, 169.937),
                     Point(209.481, 172.326),
                     Point(240.126, 146.125)]
        sign.small = small
        return sign
    }

    func hercules() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(268.114, 166.217),
                   Point(298.54, 251.942),
                   Point(209.225, 320.015),
                   Point(206.525, 228.747),
                   Point(204.364, 124.182),
                   Point(145.249, 202.847),
                   Point(259.625, 102.751)]
        sign.big = big

        let small = [Point(124.323, 188.335),
                     Point(318.024, 270.143),
                     Point(163.503, 43.655),
                     Point(131.671, 118.742),
                     Point(105.367, 191.124),
                     Point(290.904, 34.344),
                     Point(233.083, 174.592),
                     Point(189.062, 121.417),
                     Point(271.598, 70.76),
                     Point(310.157, 43.706),
                     Point(175.475, 217.777),
                     Point(316.235, 315.458),
                     Point(340.022, 60.535)]
        sign.small = small
        return sign
    }

    func horologium() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(90.547, 74.311)]
        sign.big = big

        let small = [Point(227.105, 322.809),
                     Point(225.58, 271.896),
                     Point(269.631, 216.878),
                     Point(279.359, 194.881),
                     Point(273.762, 173.261),
                     Point(185.466, 126.038)]
        sign.small = small
        return sign
    }

    func hydra() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(293.553, 183.695),
                     Point(78.188, 240.372),
                     Point(213.793, 206.989),
                     Point(332.92, 131.838),
                     Point(38.147, 260.232),
                     Point(341.929, 131.405),
                     Point(174.159, 267.438),
                     Point(251.249, 194.034),
                     Point(235.583, 210.455),
                     Point(311.835, 143.053),
                     Point(284.883, 153.347),
                     Point(204.146, 214.909),
                     Point(268.414, 205.182),
                     Point(350.682, 135.692),
                     Point(343.592, 143.567),
                     Point(157.147, 275.815),
                     Point(339.893, 133.36),
                     Point(0.924, 272.792),
                     Point(348.018, 144.541),
                     Point(193.012, 232.321),
                     Point(256.2, 197.18)]
        sign.small = small
        return sign
    }

    func hydrus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(259.408, 285.775),
                   Point(227.725, 84.665),
                   Point(121.943, 239.617),
                   Point(191.648, 164.397),
                   Point(172.1, 159.883)]
        sign.big = big
        return sign
    }

    func indus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(236.232, 93.287),
                   Point(204.674, 188.33)]
        sign.big = big

        let small = [Point(174.408, 144.336),
                     Point(127.378, 163.023),
                     Point(222.546, 132.468)]
        sign.small = small
        return sign
    }

    func lacerta() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(184.43, 155.089),
                     Point(210.648, 264.09),
                     Point(186.93, 177.597),
                     Point(194.929, 137.99),
                     Point(213.428, 246.76),
                     Point(169.795, 207.31),
                     Point(185.46, 217.65),
                     Point(199.728, 187.638),
                     Point(194.046, 162.069)]
        sign.small = small
        return sign
    }

    func leo() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(254.373, 183.333),
                   Point(228.534, 115.003),
                   Point(40.287, 157.542),
                   Point(115.735, 108.44),
                   Point(298.282, 78.663),
                   Point(114.3, 152.941),
                   Point(234.823, 83.646),
                   Point(255.562, 141.38)]
        sign.big = big

        let small = [Point(283.349, 59.707),
                     Point(92.4, 195.138),
                     Point(97.155, 234.644),
                     Point(327.734, 84.349),
                     Point(140.198, 111.973),
                     Point(340.708, 55.508),
                     Point(229.064, 118.233),
                     Point(233.722, 86.382),
                     Point(235.119, 82.892)]
        sign.small = small
        return sign
    }

    func leoMinor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(126.606, 214.377),
                     Point(172.928, 195.033),
                     Point(209.165, 207.593),
                     Point(267.05, 193.16),
                     Point(175.993, 220.53),
                     Point(179.204, 221.251),
                     Point(181.104, 219.612)]
        sign.small = small
        return sign
    }

    func lepus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(206.869, 173.69),
                   Point(218.742, 208.09),
                   Point(279.906, 228.899),
                   Point(262.521, 156.195),
                   Point(174.642, 227.543),
                   Point(167.045, 138.705),
                   Point(140.179, 131.527),
                   Point(155.855, 209.449)]
        sign.big = big
        
        let small = [Point(244.938, 120.274),
                     Point(263.126, 118.137),
                     Point(112.876, 141.3)]
        sign.small = small
        return sign
    }

    func libra() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(193.799, 152.255),
                   Point(248.467, 211.446),
                   Point(219.317, 291.488)]
        sign.big = big

        let small = [Point(153.597, 316.461),
                     Point(150.667, 330.879),
                     Point(154.52, 199.786)]
        sign.small = small
        return sign
    }

    func lupus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(236.37, 250.337),
                   Point(213.555, 211.43),
                   Point(176.748, 189.174),
                   Point(191.016, 289.143),
                   Point(175.372, 224.525),
                   Point(110.145, 174.5)]
        sign.big = big

        let small = [Point(175.266, 150.872),
                     Point(121.383, 131.203),
                     Point(182.106, 252.249),
                     Point(146.614, 225.694)]
        sign.small = small
        return sign
    }

    func lynx() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(39.339, 276.17)]
        sign.big = big

        let small = [Point(48.344, 256.71),
                     Point(87.844, 220.797),
                     Point(149.87, 216.466),
                     Point(260, 77.415),
                     Point(301.56, 61.435),
                     Point(72.49, 247.433),
                     Point(233.816, 162.652)]
        sign.small = small
        return sign
    }

    func lyra() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(215.827, 159.231),
                   Point(164.168, 230.46),
                   Point(185.912, 222.864),
                   Point(198.182, 173.362)]
        sign.big = big

        let small = [Point(175.61, 181.611),
                     Point(198.76, 149.964),
                     Point(168.92, 228.085)]
        sign.small = small
        return sign
    }

    func mensa() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(155.152, 191.528),
                     Point(184.883, 207.32),
                     Point(212.049, 150.27),
                     Point(212.75, 192.966)]
        sign.small = small
        return sign
    }

    func microscopium() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(183.505, 171.918),
                   Point(142.413, 171.912)]
        sign.big = big

        let small = [Point(140.68, 272.773),
                     Point(210.988, 189.954),
                     Point(211.153, 308.978)]
        sign.small = small
        return sign
    }

    func monoceros() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(265.499, 245.001),
                     Point(107.958, 267.007),
                     Point(295.941, 238.573),
                     Point(171.738, 187.636),
                     Point(277.128, 143.468),
                     Point(47.969, 210.069),
                     Point(224.263, 162.29),
                     Point(257.219, 119.41),
                     Point(239.571, 96.937),
                     Point(233.539, 149.031)]
        sign.small = small
        return sign
    }

    func musca() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(179.231, 191.07),
                   Point(169.005, 179.578),
                   Point(157.015, 221.044),
                   Point(237.566, 167.561),
                   Point(184.476, 225.897),
                   Point(200.266, 177.617)]
        sign.big = big
        
        let small = [Point(234.407, 168.017),
                     Point(195.084, 181.443)]
        sign.small = small
        return sign
    }

    func norma() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(149.659, 180.81),
                   Point(133.167, 151.746),
                   Point(180.562, 168.794)]
        sign.big = big

        let small = [Point(173.27, 121.643),
                     Point(154.869, 179.46),
                     Point(144.248, 174.393)]
        sign.small = small
        return sign
    }

    func octans() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(260.442, 176.815),
                   Point(205.764, 158.428),
                   Point(105.293, 276.275)]
        sign.big = big
        return sign
    }

    func ophiucus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(163.882, 4.201),
                   Point(217.663, 251.571),
                   Point(289.516, 208.17),
                   Point(341.698, 150.367),
                   Point(145.203, 74.289),
                   Point(249.07, 32.609),
                   Point(332.548, 158.633),
                   Point(192.884, 332.486),
                   Point(113.464, 200.312),
                   Point(307.419, 99.051)]
        sign.big = big
        
        let small = [Point(135.546, 90.698),
                     Point(181.987, 375.035),
                     Point(300.282, 261.474),
                     Point(309.295, 321.666),
                     Point(313.724, 292.027),
                     Point(310.43, 189.793)]
        sign.small = small
        return sign
    }

    func orion() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(221.07, 313.963),
                   Point(132.159, 177.403),
                   Point(197.315, 186.894),
                   Point(173.089, 252.879),
                   Point(163.077, 259.32),
                   Point(147.23, 326.76),
                   Point(182.338, 245.004),
                   Point(198.896, 263.328),
                   Point(273.889, 180.895),
                   Point(175.643, 155.569)]
        sign.big = big

        let small = [Point(271.088, 192.789),
                     Point(264.844, 220.533),
                     Point(258.974, 123.83),
                     Point(116.764, 157.655),
                     Point(271.95, 163.978),
                     Point(134.909, 64.962),
                     Point(106.192, 112.759),
                     Point(96.75, 117.508),
                     Point(255.532, 227.003),
                     Point(114.626, 65.942),
                     Point(262.539, 153.179),
                     Point(241.206, 107.516)]
        sign.small = small
        return sign
    }

    func pavo() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(120.571, 136.495),
                   Point(122.174, 221.611),
                   Point(153.292, 214.283),
                   Point(281.875, 218.727),
                   Point(167.482, 271.712)]
        sign.big = big

        let small = [Point(225.744, 179.659),
                     Point(84.972, 228.574),
                     Point(264.906, 202.324),
                     Point(256.272, 179.876),
                     Point(215.212, 222.714),
                     Point(220.07, 260.602)]
        sign.small = small
        return sign
    }

    func pegasus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(59.022, 131.67),
                   Point(252.366, 250.321)]
        sign.big = big

        let small = [Point(141.92, 145.368),
                     Point(136.932, 220.226),
                     Point(40.975, 210.918),
                     Point(169.174, 133.809),
                     Point(169.313, 246.78),
                     Point(159.258, 166.321),
                     Point(215.232, 273.494),
                     Point(216.315, 161.872),
                     Point(163.733, 172.474),
                     Point(245.785, 158.69),
                     Point(161.945, 238.809),
                     Point(211.074, 116.379),
                     Point(187.134, 256.83),
                     Point(82.891, 136.164)]
        sign.small = small
        return sign
    }

    func perseus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(223.002, 157.43),
                   Point(178.895, 315.915),
                   Point(173.551, 244.79),
                   Point(246.008, 122.874),
                   Point(197.135, 176.874),
                   Point(255.728, 232.232),
                   Point(263.184, 249.879)]
        sign.big = big

        let small = [Point(263.184, 249.878),
                     Point(260.515, 99.367),
                     Point(249.304, 198.675),
                     Point(197.461, 312.336),
                     Point(260.815, 127.128),
                     Point(159.292, 176.853),
                     Point(358.11, 117.806),
                     Point(244.751, 157.362),
                     Point(170.667, 281.598),
                     Point(280.245, 154.869),
                     Point(150.602, 170.165),
                     Point(163.523, 153.991),
                     Point(147.192, 153.347)]
        sign.small = small
        return sign
    }

    func phoenix() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(242.124, 137.688),
                   Point(178.188, 173.254),
                   Point(142.016, 145.593)]
        sign.big = big

        let small = [Point(264.27, 171.194),
                     Point(176.828, 247.82),
                     Point(142.669, 196.07)]
        sign.small = small
        return sign
    }

    func picisAustrinus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(78.342, 203.985),
                   Point(94.362, 240.639),
                   Point(119.57, 170.787),
                   Point(85.66, 237.457),
                   Point(145.541, 231.44),
                   Point(259.64, 241.036)]
        sign.big = big
        
        let small = [Point(202.377, 238.309),
                     Point(198.127, 233.129),
                     Point(254.305, 215.865)]
        sign.small = small
        return sign
    }

    func pictor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(92.292, 316.428),
                   Point(172.844, 178.676)]
        sign.big = big

        let small = [Point(170.226, 238.2)]
        sign.small = small
        return sign
    }

    func pisces() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(106.059, 189.65),
                     Point(56.517, 259.395),
                     Point(300.381, 257.571),
                     Point(237.362, 240.453),
                     Point(265.962, 246.293),
                     Point(83.884, 224.295),
                     Point(144.833, 234.855),
                     Point(283.16, 240.795),
                     Point(165.495, 237.085),
                     Point(88.087, 246.037),
                     Point(264.142, 268.846),
                     Point(137.2, 105.185),
                     Point(133.144, 137.126),
                     Point(126.176, 121.189),
                     Point(286.814, 270.458)]
        sign.small = small
        return sign
    }
    
    func puppis() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(129.784, 267.763),
                   Point(209.003, 240.505),
                   Point(111.217, 131.656),
                   Point(271.264, 298.581),
                   Point(147.999, 134.099),
                   Point(280.885, 383.685),
                   Point(125.612, 332.424),
                   Point(245.581, 361.017)]
        sign.big = big
        
        let small = [Point(160.088, 169.442),
                     Point(185.181, 186.562),
                     Point(176.147, 163.969),
                     Point(150.942, 337.294)]
        sign.small = small
        return sign
    }
    
    func pyxis() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(213.613, 264.104),
                   Point(221.4, 289.048),
                   Point(197.204, 200.019)]
        sign.big = big
        return sign
    }
    
    func reticulum() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(166.257, 232.712),
                   Point(205.351, 259.956),
                   Point(161.182, 195.984)]
        sign.big = big

        let small = [Point(187.434, 219.675),
                     Point(183.851, 215.934),
                     Point(165.555, 229.461)]
        sign.small = small
        return sign
    }
    
    func sagitta() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(107.161, 207.402),
                   Point(138.073, 219.634)]
        sign.big = big

        let small = [Point(155.379, 232.334),
                     Point(158.123, 226.11)]
        sign.small = small
        return sign
    }
    
    func sagittarius() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(252.044, 242.122),
                   Point(196.608, 168.959),
                   Point(182.368, 200.241),
                   Point(261.158, 202.915),
                   Point(250.661, 163.475),
                   Point(215.275, 175.415),
                   Point(173.875, 181.013),
                   Point(289.175, 211.005)]
        sign.big = big
        return sign
    }
    
    func scorpius() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(217.318, 188.095),
                   Point(101.124, 285.123),
                   Point(100.116, 337.003),
                   Point(177.423, 256.341),
                   Point(277.135, 158.449),
                   Point(87.515, 303.537),
                   Point(268.832, 133.032),
                   Point(106.281, 286.308),
                   Point(204.361, 203.36),
                   Point(277.242, 189.107),
                   Point(233.746, 181.42),
                   Point(174.797, 289.182),
                   Point(79.983, 314.126)]
        sign.big = big
        
        let small = [Point(72.557, 287.926),
                     Point(141.872, 335.706),
                     Point(170.791, 326.944),
                     Point(255.461, 129.016),
                     Point(278.42, 216.434)]
        sign.small = small
        return sign
    }
    
    func sculptor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(131.821, 180.044),
                     Point(285.006, 258.709),
                     Point(316.858, 216.751),
                     Point(265.527, 171.276),
                     Point(202.549, 175.111)]
        sign.small = small
        return sign
    }
    
    func scutum() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(200.024, 160.1),
                   Point(165.195, 119.419)]
        sign.big = big

        let small = [Point(216.66, 233.867),
                     Point(179.635, 169.503),
                     Point(176.014, 160.456)]
        sign.small = small
        return sign
    }
    
    func serpensCaput() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(173.746, 233.809),
                   Point(83.841, 350.528),
                   Point(157.479, 348.56),
                   Point(168.626, 128.974),
                   Point(154.607, 256.406),
                   Point(200.994, 185.875),
                   Point(139.657, 125.922)]
        sign.big = big
        
        let small = [Point(161.598, 97.248),
                     Point(181.776, 79.508),
                     Point(155.942, 282.992)]
        sign.small = small
        return sign
    }
    
    func serpensCauda() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(152.593, 155.586),
                   Point(217.106, 235.665),
                   Point(277.565, 301.878)]
        sign.big = big

        let small = [Point(48.817, 74.47),
                     Point(82.971, 98.701)]
        sign.small = small
        return sign
    }
    
    func sextans() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(212.593, 195.819),
                     Point(163.758, 198.135),
                     Point(246.16, 263.447),
                     Point(165.547, 216.502)]
        sign.small = small
        return sign
    }
    
    func taurus() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(205.261, 197.302),
                   Point(105.026, 89.659),
                   Point(78.595, 153.509),
                   Point(220.576, 202.652),
                   Point(280.911, 230.009),
                   Point(220.1, 173.732),
                   Point(360.252, 254.385)]
        sign.big = big

        let small = [Point(239.272, 204.311),
                     Point(354.583, 248.748),
                     Point(232.221, 187.769),
                     Point(278.484, 287.027),
                     Point(340.312, 331.855)]
        sign.small = small
        return sign
    }
    
    func telescopium() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(267.179, 164.614)]
        sign.big = big

        let small = [Point(164.598, 176.561),
                     Point(124.582, 222.778),
                     Point(183.182, 231.267),
                     Point(205.053, 213.471),
                     Point(152.8, 249.805)]
        sign.small = small
        return sign
    }
    
    func triangulum() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(162.808, 168.858),
                   Point(203.146, 231.974),
                   Point(143.714, 181.554)]
        sign.big = big

        let small = [Point(144.548, 177.185),
                     Point(146.831, 187.366),
                     Point(178.382, 188.929)]
        sign.small = small
        return sign
    }
    
    func triangulumAustrale() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(135.118, 245.374),
                   Point(192.012, 175.325),
                   Point(229.114, 239.971),
                   Point(212.896, 210.159)]
        sign.big = big
        return sign
    }
    
    func tucana() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(309.03, 180.821),
                   Point(124.88, 196.836),
                   Point(228.569, 138.5),
                   Point(142.993, 216.562)]
        sign.big = big

        let small = [Point(280.457, 229.095),
                     Point(168.224, 222.267)]
        sign.small = small
        return sign
    }
    
    func ursaMajor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(95.603, 147.023),
                   Point(184.23, 130.875),
                   Point(35.971, 159.956),
                   Point(70.55, 142.123)]
        sign.big = big

        let small = [Point(185.376, 162.163),
                     Point(140.601, 173.65),
                     Point(176.788, 231.234),
                     Point(228.258, 246.259),
                     Point(301.376, 187.318),
                     Point(264.477, 178.187),
                     Point(127.226, 150.821),
                     Point(291.3, 110.215),
                     Point(232.792, 237.327),
                     Point(163.501, 297.11),
                     Point(299.367, 193.751),
                     Point(246.316, 114.401),
                     Point(141.944, 208.82),
                     Point(238.859, 140.667),
                     Point(163.326, 306.235)]
        sign.small = small
        return sign
    }
    
    func ursaMinor() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(185.05, 55.541),
                   Point(193.585, 248.46),
                   Point(166.989, 274.788),
                   Point(144.727, 147.062)]
        sign.big = big

        let small = [Point(158.939, 203.604),
                     Point(161.592, 95.36),
                     Point(131.048, 220.583)]
        sign.small = small
        return sign
    }
    
    func vela() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(318.321, 215.066),
                   Point(256.245, 266.259),
                   Point(237.137, 164.095),
                   Point(208.89, 263.266),
                   Point(92.155, 224)]
        sign.big = big

        let small = [Point(164.816, 259.33),
                     Point(201.884, 135.779),
                     Point(129.878, 153.187)]
        sign.small = small
        return sign
    }
    
    func virgo() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(176.598, 264.688),
                   Point(252.596, 196.985),
                   Point(216.991, 110.084)]
        sign.big = big

        let small = [Point(159.926, 190.852),
                     Point(228.362, 162.984),
                     Point(341.972, 175.378),
                     Point(34.613, 174.415),
                     Point(40.866, 227.123),
                     Point(290.666, 191.799),
                     Point(350.902, 142.192),
                     Point(88.018, 229.016),
                     Point(317.103, 126.354),
                     Point(112.718, 176.09),
                     Point(203.134, 225.392)]
        sign.small = small
        return sign
    }
    
    func volans() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let big = [Point(245.607, 215.024),
                   Point(168.114, 157.363),
                   Point(244.368, 184.287),
                   Point(125.884, 166.347),
                   Point(188.878, 185.67)]
        sign.big = big
        return sign
    }
    
    func vulpecula() -> AstrologicalSign {
        var sign = AstrologicalSign()
        let small = [Point(287.975, 181),
                     Point(239.22, 189.634)]
        sign.small = small
        return sign
    }
}
