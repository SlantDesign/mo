import C4

//typealias that returns an astrological sign
//so we can "store" the methods in a dictionary
typealias AstrologicalSignFunction = () -> AstrologicalSign

//Structure that represents a sign
struct AstrologicalSign {
    //relative positions of big stars
    var big: [Point]?
    //relative positions of small stars
    var small: [Point]?
}

class AstrologicalSignProvider: NSObject {
    //(mark)  -
    //(mark)  Properties
    //Creates a singleton
    static let shared = AstrologicalSignProvider()

    //Sets the order of the signs
    let order = ["andromeda", "antlia", "apus", "aquarius", "aquila", "ara", "aries", "auriga", "bootes", "caelum", "cameoparadalis", "cancer", "canisMajor", "canisMinor", "canisVenatici", "capricornus", "carina", "casseopeia", "centaurus", "cephus", "cetus", "chamaeleon", "circinus", "columba", "comaBerenices", "coronaAustralis", "coronaBorealis", "corvus", "crater", "crux", "cygnus", "delphinus", "dorado", "draco", "equuleus", "eridanus", "fornax", "gemini", "grus", "hercules", "horologium", "hydra", "hydrus", "indus", "lacerta", "leo", "leoMinor", "lepus", "libra", "lupus", "lynx", "lyra", "mensa", "microscopium", "monoceros", "musca", "norma", "octans", "ophiucus", "orion", "pavo", "pegasus", "perseus", "phoenix", "picisAustrinus", "pictor", "pisces", "puppis", "pyxis", "reticulum", "sagitta", "sagittarius", "scorpius", "sculptor", "scutum", "serpensCaput", "serpensCauda", "sextans", "taurus", "telescopium", "triangulum", "triangulumAustrale", "tucana", "ursaMajor", "ursaMinor", "vela", "virgo", "volans", "vulpecula"]

    //Sets the order of the signs
    let readableNames = ["Andromeda", "Antlia", "Apus", "Aquarius", "Aquila", "Ara", "Aries", "Auriga", "Bootes", "Caelum", "Cameoparadalis", "Cancer", "Canis Major", "Canis Minor", "Canis Venatici", "Capricornus", "Carina", "Casseopeia", "Centaurus", "Cephus", "Cetus", "Chamaeleon", "Circinus", "Columba", "Coma Berenices", "Corona Australis", "Corona Borealis", "Corvus", "Crater", "Crux", "Cygnus", "Delphinus", "Dorado", "Draco", "Equuleus", "Eridanus", "Fornax", "Gemini", "Grus", "Hercules", "Horologium", "Hydra", "Hydrus", "Indus", "Lacerta", "Leo", "Leo Minor", "Lepus", "Libra", "Lupus", "Lynx", "Lyra", "Mensa", "Microscopium", "Monoceros", "Musca", "Norma", "Octans", "Ophiucus", "Orion", "Pavo", "Pegasus", "Perseus", "Phoenix", "Picis Austrinus", "Pictor", "Pisces", "Puppis", "Pyxis", "Reticulum", "Sagitta", "Sagittarius", "Scorpius", "Sculptor", "Scutum", "Serpens Caput", "Serpens Cauda", "Sextans", "Taurus", "Telescopium", "Triangulum", "Triangulum Australe", "Tucana", "Ursa Major", "Ursa Minor", "Vela", "Virgo", "Volans", "Vulpecula"]

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
        //returns the results of executing the function
        return mappings[sign]?()
    }

    //(mark)
    //(mark) Signs
    //The following methods each represent an astrological sign, whose points (big/small) are calculated relative to {0,0}
    func andromeda() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.209920110192838, 0.243779187817259),
                   Point(-0.106818181818182, 0.104289340101523),
                   Point(-0.334129476584022, -0.0763578680203046),
                   Point(0.0441101928374656, 0.213540609137056),
                   Point(-0.198267217630854, -0.195007614213198),
                   Point(0.467239669421488, -0.101322335025381)]
        sign.big = big

        let small = [Point(-0.040931129476584, 0.0434593908629441),
                     Point(0.294347107438017, -0.156753807106599),
                     Point(0.00116528925619835, 0.360002538071066),
                     Point(0.291887052341598, -0.108360406091371),
                     Point(-0.0864876033057852, -0.152850253807107),
                     Point(0.306308539944904, -0.0867842639593909),
                     Point(0.0553250688705234, 0.149918781725888),
                     Point(0.0487988980716253, 0.247829949238579),
                     Point(-0.0555068870523416, 0.377786802030457),
                     Point(-0.00740495867768592, -0.0130659898477157),
                     Point(-0.0425316804407713, 0.373484771573604)]
        sign.small = small

        return sign
    }

    func antlia() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.0725785123966942, -0.074494923857868),
                     Point(0.214261707988981, 0.0413959390862944),
                     Point(-0.207771349862259, 0.0704492385786802)]
        sign.small = small

        return sign
    }

    func apus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.121776859504132, 0.118730964467005),
                   Point(-0.0389366391184573, 0.101941624365482),
                   Point(-0.0619862258953168, 0.0641294416243655),
                   Point(-0.0192644628099173, 0.0938121827411167)]
        sign.big = big

        return sign
    }

    func aquarius() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.183225895316804, -0.0543680203045685),
                     Point(0.0467796143250689, -0.13452538071066),
                     Point(-0.144542699724518, 0.0966624365482234),
                     Point(-0.0470330578512397, -0.138804568527919),
                     Point(-0.198371900826446, 0.177604060913706),
                     Point(-0.140413223140496, -0.0253426395939087),
                     Point(0.354581267217631, 0.0115456852791878),
                     Point(-0.0177052341597796, -0.118799492385787),
                     Point(-0.250804407713499, 0.163977157360406),
                     Point(-0.0735812672176309, -0.13705076142132),
                     Point(0.00199173553719012, -0.0242969543147208),
                     Point(-0.227862258953168, -0.0450380710659899),
                     Point(0.0427134986225895, 0.0657817258883249),
                     Point(-0.239771349862259, 0.00185532994923856),
                     Point(-0.0327410468319559, -0.15958883248731)]
        sign.small = small

        return sign
    }

    func aquila() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0514986225895316, -0.140065989847716),
                   Point(-0.024396694214876, -0.178751269035533),
                   Point(0.219586776859504, -0.251327411167513),
                   Point(-0.175550964187328, 0.0744543147208122),
                   Point(0.100225895316804, -0.0125177664974619),
                   Point(0.216892561983471, 0.164446700507614),
                   Point(-0.0787988980716254, -0.0855659898477157)]
        sign.big = big

        let small = [Point(-0.0620110192837465, 0.0342791878172589),
                     Point(0.253961432506887, -0.278228426395939),
                     Point(0.244606060606061, 0.183309644670051),
                     Point(0.0328099173553719, 0.0851776649746193)]
        sign.small = small

        return sign
    }

    func ara() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0328760330578512, 0.0319137055837564),
                   Point(0.00196969696969698, -0.135416243654822),
                   Point(0.152096418732782, 0.0526294416243655),
                   Point(0.0319972451790634, 0.0569771573604061),
                   Point(0.00718457300275483, 0.184164974619289),
                   Point(-0.177157024793388, -0.117677664974619),
                   Point(0.177407713498623, 0.146591370558376),
                   Point(0.157650137741047, -0.0309923857868021)]
        sign.big = big

        return sign
    }

    func aries() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.193148760330579, -0.0698680203045685),
                   Point(0.266658402203857, -0.0148553299492386),
                   Point(0.275410468319559, 0.018248730964467),
                   Point(-0.0421707988980716, -0.150362944162437)]
        sign.big = big

        return sign
    }

    func auriga() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.133920110192837, -0.170271573604061),
                   Point(0.114462809917355, 0.217279187817259),
                   Point(-0.047931129476584, -0.14388578680203),
                   Point(-0.0561074380165289, 0.0274822335025381),
                   Point(0.256407713498623, 0.10411421319797)]
        sign.big = big

        let small = [Point(0.201859504132231, -0.127824873096447),
                     Point(0.188561983471074, -0.0687258883248731),
                     Point(-0.0391460055096419, -0.350804568527919),
                     Point(0.207190082644628, -0.0670609137055837),
                     Point(-0.0487162534435262, -0.165868020304569)]
        sign.small = small

        return sign
    }

    func bootes() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0958622589531681, 0.250906091370558),
                   Point(-0.0673471074380165, 0.0759593908629442),
                   Point(0.218440771349862, 0.262299492385787),
                   Point(0.00312672176308537, -0.172015228426396),
                   Point(-0.215804407713499, -0.0717284263959391),
                   Point(-0.135898071625344, -0.222972081218274),
                   Point(0.00354820936639121, 0.00402538071065993)]
        sign.big = big

        let small = [Point(-0.0545674931129476, 0.372421319796954),
                     Point(0.0325619834710744, -0.472489847715736),
                     Point(0.0725068870523416, -0.345368020304568),
                     Point(0.0802314049586777, -0.472144670050761),
                     Point(0.263578512396694, 0.279715736040609)]
        sign.small = small

        return sign
    }

    func caelum() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0394269972451791, 0.065497461928934),
                   Point(-0.114209366391185, -0.120157360406091)]
        sign.big = big

        let small = [Point(0.0317493112947659, -0.0741269035532995),
                     Point(0.0936391184573003, 0.158203045685279)]
        sign.small = small

        return sign
    }

    func cameoparadalis() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.241666666666667, 0.165479695431472),
                   Point(0.394539944903581, 0.0529213197969543),
                   Point(0.208942148760331, 0.0820761421319797),
                   Point(0.300771349862259, 0.0277055837563452),
                   Point(0.307440771349862, 0.244718274111675),
                   Point(0.0105977961432507, -0.0236573604060914),
                   Point(0.231201101928375, -0.0294137055837563),
                   Point(0.0699283746556473, 0.0846421319796954)]
        sign.big = big

        return sign
    }

    func cancer() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0959090909090909, 0.251271573604061)]
        sign.big = big

        let small = [Point(-0.0747300275482094, -0.183093908629442),
                     Point(-0.154939393939394, 0.189454314720812),
                     Point(-0.0600027548209367, -0.0210456852791878),
                     Point(-0.0695785123966942, 0.0522690355329949)]
        sign.small = small

        return sign
    }

    func canisMajor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0123719008264463, -0.11048730964467),
                   Point(-0.0590220385674931, 0.162131979695431),
                   Point(-0.113181818181818, 0.106426395939086),
                   Point(0.141214876033058, -0.0807741116751269),
                   Point(-0.193501377410468, 0.174822335025381)]
        sign.big = big

        let small = [Point(-0.0369063360881542, 0.0555507614213198),
                     Point(0.0605674931129476, -0.0538020304568528),
                     Point(-0.0416225895316805, -0.213776649746193),
                     Point(-0.0960853994490358, -0.132888324873096),
                     Point(-0.0510413223140496, -0.102380710659898),
                     Point(-0.155578512396694, 0.141215736040609)]
        sign.small = small

        return sign
    }

    func canisMinor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0630909090909091, 0.0679695431472081),
                   Point(0.0339146005509642, -0.0223832487309644)]
        sign.big = big

        return sign
    }

    func canisVenatici() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0331900826446281, 0.0482131979695432)]
        sign.big = big

        let small = [Point(0.13295041322314, -0.0231116751269035)]
        sign.small = small

        return sign
    }

    func capricornus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.259057851239669, -0.0648197969543147),
                   Point(0.240917355371901, -0.0973578680203046),
                   Point(0.261531680440771, -0.14589847715736)]
        sign.big = big

        let small = [Point(-0.218107438016529, -0.0553730964467005),
                     Point(-0.135190082644628, 0.0684695431472081),
                     Point(-0.0209586776859504, -0.0489593908629441),
                     Point(0.0574738292011019, 0.165967005076142),
                     Point(0.0892424242424243, 0.129880710659898),
                     Point(-0.147247933884297, 0.0555177664974619),
                     Point(-0.197030303030303, 0.00578934010152286),
                     Point(-0.0257685950413224, 0.123477157360406),
                     Point(0.0306969696969697, 0.151941624365482),
                     Point(-0.183625344352617, 0.0188578680203046)]
        sign.small = small

        return sign
    }

    func carina() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.427044077134986, -0.109596446700508),
                   Point(-0.0981735537190083, 0.191710659898477),
                   Point(-0.0730936639118457, -0.147847715736041),
                   Point(0.00557024793388427, -0.0451472081218274),
                   Point(-0.161013774104683, -0.0326497461928934),
                   Point(-0.340278236914601, 0.155159898477157),
                   Point(-0.215752066115702, 0.235236040609137),
                   Point(-0.313363636363636, 0.0642715736040609),
                   Point(-0.347479338842975, 0.0894517766497462),
                   Point(0.0981404958677686, -0.186408629441624)]
        sign.big = big

        let small = [Point(-0.437691460055096, 0.0668147208121827),
                     Point(-0.474192837465565, 0.0941598984771573),
                     Point(-0.419432506887052, 0.151901015228426),
                     Point(-0.464115702479339, 0.124596446700508)]
        sign.small = small

        return sign
    }

    func casseopeia() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0765482093663912, 0.129994923857868),
                   Point(0.167694214876033, 0.0601827411167512),
                   Point(0.0213608815426997, 0.039510152284264),
                   Point(-0.06533608815427, 0.0467081218274111),
                   Point(-0.132504132231405, -0.0398934010152284)]
        sign.big = big

        return sign
    }

    func centaurus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.189173553719008, 0.272144670050761),
                   Point(-0.11937741046832, 0.24852538071066),
                   Point(-0.203911845730028, -0.0978020304568528),
                   Point(0.0610220385674931, 0.0690812182741116),
                   Point(-0.0839449035812672, 0.139890862944162)]
        sign.big = big

        let small = [Point(-0.268038567493113, 0.00555329949238576),
                     Point(-0.138283746556474, 0.055),
                     Point(0.143559228650138, 0.103517766497462),
                     Point(-0.0546060606060606, -0.111327411167513),
                     Point(-0.134143250688705, -0.017753807106599),
                     Point(-0.334942148760331, 0.0259086294416244),
                     Point(-0.135735537190083, -0.0292868020304568),
                     Point(-0.160495867768595, -0.019266497461929),
                     Point(0.242931129476584, 0.182291878172589),
                     Point(-0.0842727272727273, -0.0691751269035533),
                     Point(0.0945013774104683, 0.0903299492385787),
                     Point(0.131322314049587, 0.126393401015228),
                     Point(-0.242027548209366, -0.0666751269035533),
                     Point(0.0742892561983471, -0.0630888324873096),
                     Point(0.197157024793388, 0.246116751269036)]
        sign.small = small

        return sign
    }

    func cephus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.216716253443526, 0.234809644670051),
                   Point(-0.0742782369146005, -0.081989847715736),
                   Point(0.138143250688705, 0.0719086294416243),
                   Point(0.0782727272727273, 0.358840101522843),
                   Point(0.313424242424242, 0.216634517766497)]
        sign.big = big

        let small = [Point(0.0171707988980716, 0.356548223350254),
                     Point(-0.0347052341597796, 0.181984771573604),
                     Point(0.165793388429752, 0.334271573604061),
                     Point(0.0661928374655647, 0.38541116751269),
                     Point(0.340410468319559, 0.174256345177665)]
        sign.small = small

        return sign
    }

    func cetus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.245754820936639, 0.0874695431472081)]
        sign.big = big

        let small = [Point(-0.311925619834711, -0.234185279187817),
                     Point(-0.129002754820937, -0.138807106598985),
                     Point(-0.232027548209366, -0.226441624365482),
                     Point(0.154578512396694, -0.0320837563451776),
                     Point(0.0141845730027548, 0.0506725888324873),
                     Point(0.350388429752066, -0.0413832487309645),
                     Point(0.0942341597796143, -0.0632208121827411),
                     Point(-0.0148677685950413, -0.0321167512690355),
                     Point(-0.213650137741047, -0.184322335025381),
                     Point(-0.245325068870523, -0.32758883248731),
                     Point(-0.172589531680441, -0.306497461928934),
                     Point(-0.306906336088154, -0.305954314720812)]
        sign.small = small

        return sign
    }

    func chamaeleon() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.239600550964187, -0.0131852791878172),
                     Point(0.00301652892561983, -0.0250989847715736),
                     Point(-0.144465564738292, 0.0303045685279188),
                     Point(0.226625344352617, -0.00101269035532995),
                     Point(-0.00915426997245181, 0.0326116751269035),
                     Point(-0.132363636363636, -0.0103121827411167)]
        sign.small = small

        return sign
    }

    func circinus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0296143250688705, 0.0992106598984772),
                   Point(-0.183730027548209, -0.0675964467005076),
                   Point(-0.204258953168044, -0.0482157360406092)]
        sign.big = big

        let small = [Point(-0.0850303030303031, 0.0380761421319797)]
        sign.small = small

        return sign
    }

    func columba() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.115157024793388, -0.103786802030457),
                   Point(0.0392396694214876, -0.0554644670050762),
                   Point(-0.169068870523416, -0.11848730964467),
                   Point(0.168426997245179, -0.0598578680203046),
                   Point(-0.0115922865013774, 0.15291116751269)]
        sign.big = big

        return sign
    }

    func comaBerenices() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.0490027548209367, -0.0951725888324873),
                     Point(-0.0431597796143251, 0.134395939086294),
                     Point(0.190292011019284, -0.107855329949239)]
        sign.small = small

        return sign
    }

    func coronaAustralis() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.18828650137741, -0.0612766497461929),
                   Point(-0.205176308539945, -0.0348401015228426),
                   Point(-0.204170798898072, 0.007756345177665),
                   Point(-0.190325068870523, 0.0408705583756345),
                   Point(0.0217961432506887, 0.0858299492385787)]
        sign.big = big

        return sign
    }

    func coronaBorealis() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.19432782369146, 0.109855329949239),
                   Point(0.238063360881543, 0.036497461928934),
                   Point(0.137052341597796, 0.124728426395939),
                   Point(0.0299752066115703, 0.109616751269036),
                   Point(0.198121212121212, -0.0278959390862945),
                   Point(0.0878567493112948, 0.132812182741117)]
        sign.big = big

        let small = [Point(0.0026501377410468, 0.0217258883248731)]
        sign.small = small

        return sign
    }

    func corvus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.121575757575758, -0.0523578680203045),
                   Point(-0.0194628099173554, 0.119796954314721),
                   Point(0.0139338842975206, -0.0837868020304569),
                   Point(0.160239669421488, 0.098746192893401)]
        sign.big = big

        return sign
    }

    func crater() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0947575757575757, 0.0100253807106599),
                   Point(0.24264738292011, 0.117291878172589),
                   Point(0.0512286501377411, 0.0955786802030456),
                   Point(0.14902479338843, 0.248829949238579)]
        sign.big = big

        let small = [Point(-0.0409917355371901, -0.137421319796954),
                     Point(-0.100559228650138, 0.116053299492386),
                     Point(0.0546528925619835, -0.106225888324873),
                     Point(-0.187531680440771, 0.0824086294416243)]
        sign.small = small

        return sign
    }

    func crux() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.0252561983471075, 0.0974670050761421),
                     Point(-0.0588154269972452, -0.00122842639593911),
                     Point(0.00780716253443527, -0.0795989847715736),
                     Point(0.0746997245179064, -0.0296319796954315)]
        sign.small = small

        return sign
    }

    func cygnus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0339669421487604, 0.00399746192893398),
                   Point(0.0502314049586777, 0.114827411167513),
                   Point(-0.0677741046831956, 0.252751269035533),
                   Point(0.20495867768595, -0.00411167512690356),
                   Point(0.339848484848485, 0.360426395939086),
                   Point(-0.21469696969697, 0.324598984771574)]
        sign.big = big

        let small = [Point(0.239542699724518, -0.15757614213198),
                     Point(0.277074380165289, -0.20189847715736),
                     Point(-0.108782369146006, 0.0912360406091371),
                     Point(0.0732920110192837, -0.0504035532994924)]
        sign.small = small

        return sign
    }

    func delphinus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0303829201101928, -0.0314568527918782),
                   Point(0.014129476584022, -0.0703857868020305),
                   Point(-0.0400881542699724, -0.0768350253807106),
                   Point(0.064771349862259, 0.0657715736040609),
                   Point(-0.0154986225895317, -0.0456598984771574)]
        sign.big = big

        return sign
    }

    func dorado() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.13267217630854, -0.130865482233503),
                   Point(0.233719008264463, -0.224560913705584),
                   Point(-0.134878787878788, 0.19138578680203),
                   Point(-0.182495867768595, 0.12010152284264)]
        sign.big = big

        let small = [Point(-0.111512396694215, 0.0911548223350254),
                     Point(-0.0108980716253443, -0.0642639593908629)]
        sign.small = small

        return sign
    }

    func draco() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.290413223140496, 0.149718274111675)]
        sign.big = big

        let small = [Point(-0.0371101928374656, 0.0713020304568528),
                     Point(-0.221928374655647, 0.166994923857868),
                     Point(-0.256347107438017, -0.127164974619289),
                     Point(-0.104573002754821, -0.00455329949238581),
                     Point(0.0865757575757576, 0.105926395939086),
                     Point(-0.14931129476584, -0.139124365482234),
                     Point(0.209421487603306, -0.0158959390862944),
                     Point(-0.242066115702479, 0.0833654822335025),
                     Point(-0.255060606060606, -0.188868020304569),
                     Point(0.31634435261708, -0.22891116751269),
                     Point(0.264977961432507, -0.16207614213198),
                     Point(0.0064876033057851, 0.117208121827411),
                     Point(-0.20832782369146, 0.126203045685279),
                     Point(-0.161942148760331, -0.122073604060914),
                     Point(-0.126404958677686, -0.0499695431472081)]
        sign.small = small

        return sign
    }

    func equuleus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0301267217630854, 0.0974619289340102),
                   Point(0.0405482093663912, -0.0433426395939086)]
        sign.big = big

        let small = [Point(0.073267217630854, -0.0471192893401015)]
        sign.small = small

        return sign
    }

    func eridanus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.320482093663912, 0.461682741116751)]
        sign.big = big

        let small = [Point(-0.365399449035813, -0.314010152284264),
                     Point(0.14231955922865, 0.179652284263959),
                     Point(-0.0606969696969697, -0.22060152284264),
                     Point(-0.00148484848484845, -0.277185279187817),
                     Point(-0.114636363636364, 0.0828223350253807),
                     Point(0.295019283746556, 0.370322335025381),
                     Point(0.0414931129476584, -0.28156345177665),
                     Point(0.0889338842975206, -0.0983604060913705),
                     Point(-0.179520661157025, 0.0406751269035533),
                     Point(0.194429752066116, -0.282307106598985),
                     Point(-0.234057851239669, -0.358527918781726),
                     Point(-0.134785123966942, 0.0876802030456853),
                     Point(-0.274165289256198, -0.355200507614213),
                     Point(0.150727272727273, -0.0672106598984771),
                     Point(0.197903581267218, 0.178467005076142),
                     Point(-0.0188292011019284, 0.113941624365482),
                     Point(-0.0133388429752066, -0.0776852791878173),
                     Point(0.221068870523416, 0.298662436548223),
                     Point(0.0729917355371901, 0.216459390862944),
                     Point(0.0353939393939394, -0.101604060913706),
                     Point(-0.013038567493113, -0.242527918781726),
                     Point(0.223658402203857, -0.135659898477157),
                     Point(-0.173955922865014, 0.0282233502538071),
                     Point(0.0211212121212121, 0.173931472081218),
                     Point(-0.0612314049586777, -0.0650786802030457),
                     Point(-0.0381157024793389, -0.0570177664974619),
                     Point(0.194415977961433, 0.223314720812183),
                     Point(0.23632782369146, -0.204472081218274),
                     Point(-0.123661157024793, -0.316296954314721),
                     Point(-0.137269972451791, -0.303446700507614)]
        sign.small = small

        return sign
    }

    func fornax() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.110600550964187, -0.00722081218274111),
                     Point(0.0104628099173554, 0.0654670050761422),
                     Point(0.243898071625344, 0.00651015228426395)]
        sign.small = small

        return sign
    }

    func gemini() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.283526170798898, -0.178248730964467),
                   Point(-0.219953168044077, -0.259771573604061),
                   Point(0.084129476584022, 0.0903071065989847),
                   Point(0.163487603305785, -0.047497461928934),
                   Point(0.0462479338842975, -0.102888324873096),
                   Point(0.208421487603306, -0.0492639593908629),
                   Point(0.0408870523415978, 0.168517766497462),
                   Point(-0.155101928374656, -0.0363959390862944),
                   Point(-0.285933884297521, -0.0976903553299493),
                   Point(-0.149269972451791, 0.0846446700507614),
                   Point(-0.0013250688705234, -0.298621827411167)]
        sign.big = big

        let small = [Point(-0.178900826446281, -0.166619289340102),
                     Point(-0.0664435261707989, -0.00236548223350251),
                     Point(-0.235082644628099, -0.149730964467005),
                     Point(0.131840220385675, 0.00462690355329951),
                     Point(0.266933884297521, -0.0693426395939086),
                     Point(-0.0986997245179063, -0.217799492385787)]
        sign.small = small

        return sign
    }

    func grus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.105413223140496, 0.057251269035533),
                   Point(-0.0360909090909091, 0.053738578680203),
                   Point(0.189614325068871, -0.149418781725888),
                   Point(-0.0541900826446281, 0.152944162436548)]
        sign.big = big

        let small = [Point(0.0192093663911846, -0.0223578680203046),
                     Point(-0.097435261707989, 0.187954314720812),
                     Point(0.0170716253443526, -0.016738578680203),
                     Point(0.127234159779614, -0.106241116751269),
                     Point(0.0811101928374656, -0.0686878172588832),
                     Point(0.0770826446280992, -0.0626243654822335),
                     Point(0.161504132231405, -0.129124365482233)]
        sign.small = small

        return sign
    }

    func hercules() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.238606060606061, -0.0781294416243655),
                   Point(0.322424242424243, 0.139446700507614),
                   Point(0.0763774104683195, 0.312220812182741),
                   Point(0.068939393939394, 0.0805761421319797),
                   Point(0.0629862258953168, -0.184817258883249),
                   Point(-0.0998650137741047, 0.0148401015228427),
                   Point(0.215220385674931, -0.239210659898477)]
        sign.big = big

        let small = [Point(-0.157512396694215, -0.021992385786802),
                     Point(0.376099173553719, 0.185642131979695),
                     Point(-0.0495785123966943, -0.389200507614213),
                     Point(-0.137269972451791, -0.198624365482234),
                     Point(-0.209732782369146, -0.0149137055837564),
                     Point(0.301388429752066, -0.412832487309645),
                     Point(0.142101928374656, -0.0568730964467005),
                     Point(0.020831955922865, -0.191835025380711),
                     Point(0.248203856749311, -0.320406091370558),
                     Point(0.354426997245179, -0.389071065989848),
                     Point(-0.0165977961432507, 0.052733502538071),
                     Point(0.371170798898072, 0.300654822335025),
                     Point(0.436699724517906, -0.346357868020305)]
        sign.small = small

        return sign
    }

    func horologium() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.250559228650138, -0.311393401015228)]
        sign.big = big

        let small = [Point(0.125633608815427, 0.319312182741117),
                     Point(0.121432506887052, 0.190091370558376),
                     Point(0.242785123966942, 0.0504517766497462),
                     Point(0.269584022038567, -0.00537817258883249),
                     Point(0.254165289256198, -0.060251269035533),
                     Point(0.0109256198347108, -0.180106598984772)]
        sign.small = small

        return sign
    }

    func hydra() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.308685950413223, -0.0337690355329949),
                     Point(-0.284606060606061, 0.110081218274112),
                     Point(0.0889614325068871, 0.0253527918781726),
                     Point(0.417134986225895, -0.16538578680203),
                     Point(-0.394911845730028, 0.16048730964467),
                     Point(0.441953168044077, -0.166484771573604),
                     Point(-0.0202231404958678, 0.178776649746193),
                     Point(0.192146005509642, -0.00752791878172591),
                     Point(0.148988980716253, 0.0341497461928934),
                     Point(0.359049586776859, -0.136921319796954),
                     Point(0.284801652892562, -0.110794416243655),
                     Point(0.0623856749311294, 0.0454543147208122),
                     Point(0.239432506887052, 0.0207664974619289),
                     Point(0.466066115702479, -0.155604060913706),
                     Point(0.446534435261708, -0.135616751269036),
                     Point(-0.0670881542699725, 0.20003807106599),
                     Point(0.43634435261708, -0.161522842639594),
                     Point(-0.497454545454545, 0.192365482233502),
                     Point(0.458727272727273, -0.133144670050761),
                     Point(0.0317134986225895, 0.0896472081218274),
                     Point(0.205785123966942, 0.00045685279187819)]
        sign.small = small

        return sign
    }

    func hydrus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.21462258953168, 0.225317258883249),
                   Point(0.127341597796143, -0.28511421319797),
                   Point(-0.164068870523416, 0.108164974619289),
                   Point(0.0279559228650138, -0.082748730964467),
                   Point(-0.0258953168044077, -0.0942055837563451)]
        sign.big = big

        return sign
    }

    func indus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.150776859504132, -0.263230964467005),
                   Point(0.063840220385675, -0.0220050761421319)]
        sign.big = big

        let small = [Point(-0.0195371900826447, -0.133664974619289),
                     Point(-0.149096418732782, -0.0862360406091371),
                     Point(0.113074380165289, -0.163786802030457)]
        sign.small = small

        return sign
    }

    func lacerta() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.00807162534435264, -0.106373096446701),
                     Point(0.080297520661157, 0.170279187817259),
                     Point(0.0149586776859504, -0.049246192893401),
                     Point(0.0369944903581267, -0.149771573604061),
                     Point(0.0879559228650138, 0.126294416243655),
                     Point(-0.0322451790633609, 0.0261675126903553),
                     Point(0.0109090909090909, 0.0524111675126904),
                     Point(0.0502148760330579, -0.0237614213197969),
                     Point(0.0345619834710744, -0.0886573604060914)]
        sign.small = small

        return sign
    }

    func leo() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.200752066115702, -0.0346878172588833),
                   Point(0.129570247933884, -0.20811421319797),
                   Point(-0.38901652892562, -0.100147208121827),
                   Point(-0.181170798898072, -0.224771573604061),
                   Point(0.321713498622589, -0.300347715736041),
                   Point(-0.185123966942149, -0.111824873096447),
                   Point(0.146895316804408, -0.287700507614213),
                   Point(0.204027548209366, -0.141167512690355)]
        sign.big = big

        let small = [Point(0.280575757575758, -0.348459390862944),
                     Point(-0.245454545454545, -0.00472588832487308),
                     Point(-0.232355371900826, 0.0955431472081218),
                     Point(0.402848484848485, -0.285916243654822),
                     Point(-0.113779614325069, -0.215804568527919),
                     Point(0.438589531680441, -0.359116751269036),
                     Point(0.131030303030303, -0.199916243654822),
                     Point(0.143862258953168, -0.280756345177665),
                     Point(0.147710743801653, -0.28961421319797)]
        sign.small = small

        return sign
    }

    func leoMinor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.151223140495868, 0.0441040609137056),
                     Point(-0.0236143250688705, -0.00499238578680206),
                     Point(0.0762121212121212, 0.0268857868020304),
                     Point(0.235674931129477, -0.00974619289340102),
                     Point(-0.0151707988980716, 0.0597208121827411),
                     Point(-0.00632506887052339, 0.0615507614213198),
                     Point(-0.00109090909090905, 0.0573908629441624)]
        sign.small = small

        return sign
    }

    func lepus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0698870523415978, -0.0591624365482234),
                   Point(0.102595041322314, 0.0281472081218274),
                   Point(0.271090909090909, 0.0809619289340101),
                   Point(0.223198347107438, -0.103565989847716),
                   Point(-0.0188925619834711, 0.0775203045685279),
                   Point(-0.0398209366391185, -0.147956852791878),
                   Point(-0.113831955922865, -0.166175126903553),
                   Point(-0.0706473829201102, 0.0315964467005076)]
        sign.big = big

        let small = [Point(0.174760330578512, -0.194736040609137),
                     Point(0.224865013774105, -0.200159898477157),
                     Point(-0.189046831955923, -0.141370558375634)]
        sign.small = small

        return sign
    }

    func libra() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0338815426997245, -0.113565989847716),
                   Point(0.184482093663912, 0.0366649746192893),
                   Point(0.104179063360882, 0.239817258883249)]
        sign.big = big

        let small = [Point(-0.0768677685950413, 0.303200507614213),
                     Point(-0.0849393939393939, 0.339794416243655),
                     Point(-0.0743250688705234, 0.00707106598984772)]
        sign.small = small

        return sign
    }

    func lupus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.151157024793388, 0.1353730964467),
                   Point(0.088305785123967, 0.0366243654822335),
                   Point(-0.0130909090909091, -0.0198629441624365),
                   Point(0.0262148760330578, 0.233865482233502),
                   Point(-0.0168815426997245, 0.0698604060913706),
                   Point(-0.196570247933884, -0.0571065989847716)]
        sign.big = big

        let small = [Point(-0.0171735537190083, -0.11707614213198),
                     Point(-0.165611570247934, -0.166997461928934),
                     Point(0.00166942148760329, 0.140225888324873),
                     Point(-0.0961046831955923, 0.0728274111675127)]
        sign.small = small

        return sign
    }

    func lynx() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.391628099173554, 0.200939086294416)]
        sign.big = big

        let small = [Point(-0.366820936639118, 0.151548223350254),
                     Point(-0.258005509641873, 0.0603984771573604),
                     Point(-0.0871349862258953, 0.0494060913705584),
                     Point(0.216253443526171, -0.303515228426396),
                     Point(0.330743801652893, -0.344073604060914),
                     Point(-0.30030303030303, 0.128002538071066),
                     Point(0.144121212121212, -0.0871776649746193)]
        sign.small = small

        return sign
    }

    func lyra() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.094564738292011, -0.0958604060913706),
                   Point(-0.0477465564738292, 0.0849238578680203),
                   Point(0.0121542699724518, 0.0656446700507614),
                   Point(0.0459559228650137, -0.059994923857868)]
        sign.big = big

        let small = [Point(-0.0162258953168044, -0.0390583756345178),
                     Point(0.0475482093663912, -0.119380710659898),
                     Point(-0.0346556473829201, 0.0788959390862944)]
        sign.small = small

        return sign
    }

    func mensa() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.0725840220385675, -0.0138883248730965),
                     Point(0.00931955922865016, 0.0261928934010152),
                     Point(0.0841570247933884, -0.118604060913706),
                     Point(0.0860881542699724, -0.010238578680203)]
        sign.small = small

        return sign
    }

    func microscopium() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.00552341597796142, -0.0636598984771573),
                   Point(-0.107677685950413, -0.0636751269035533)]
        sign.big = big

        let small = [Point(-0.112451790633609, 0.192317258883249),
                     Point(0.0812341597796143, -0.0178832487309644),
                     Point(0.0816887052341598, 0.284208121827411)]
        sign.small = small

        return sign
    }

    func monoceros() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.231402203856749, 0.121829949238579),
                     Point(-0.202595041322314, 0.177682741116751),
                     Point(0.315264462809917, 0.105515228426396),
                     Point(-0.0268925619834711, -0.0237664974619289),
                     Point(0.263438016528926, -0.135868020304569),
                     Point(-0.367853994490358, 0.0331700507614213),
                     Point(0.117804407713499, -0.0880964467005076),
                     Point(0.208592286501377, -0.196928934010152),
                     Point(0.15997520661157, -0.253967005076142),
                     Point(0.143358126721763, -0.121748730964467)]
        sign.small = small

        return sign
    }

    func musca() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.00625068870523417, -0.0150507614213198),
                   Point(-0.0344214876033058, -0.0442182741116751),
                   Point(-0.0674517906336089, 0.0610253807106599),
                   Point(0.154451790633609, -0.0747182741116751),
                   Point(0.00819834710743801, 0.0733426395939086),
                   Point(0.0516969696969697, -0.0491954314720812)]
        sign.big = big

        let small = [Point(0.145749311294766, -0.0735609137055838),
                     Point(0.0374214876033058, -0.039484771573604)]
        sign.small = small

        return sign
    }

    func norma() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0877162534435262, -0.0410913705583756),
                   Point(-0.133148760330579, -0.114857868020305),
                   Point(-0.00258402203856746, -0.0715888324873096)]
        sign.big = big

        let small = [Point(-0.0226721763085399, -0.191261421319797),
                     Point(-0.0733636363636364, -0.0445177664974619),
                     Point(-0.10262258953168, -0.0573781725888325)]
        sign.small = small

        return sign
    }

    func octans() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.217471074380165, -0.0512309644670051),
                   Point(0.0668429752066116, -0.0978984771573604),
                   Point(-0.209936639118457, 0.201205583756345)]
        sign.big = big

        return sign
    }

    func ophiucus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.048534435261708, -0.489337563451777),
                   Point(0.0996225895316805, 0.138505076142132),
                   Point(0.297564738292011, 0.0283502538071066),
                   Point(0.441316804407713, -0.118357868020305),
                   Point(-0.0999917355371901, -0.31144923857868),
                   Point(0.186143250688705, -0.417236040609137),
                   Point(0.416110192837466, -0.0973781725888325),
                   Point(0.0313608815426997, 0.3438730964467),
                   Point(-0.187426997245179, 0.00840609137055841),
                   Point(0.346884297520661, -0.24860152284264)]
        sign.big = big

        let small = [Point(-0.126595041322314, -0.269802030456853),
                     Point(0.00134159779614324, 0.451865482233503),
                     Point(0.327223140495868, 0.163639593908629),
                     Point(0.352052341597796, 0.31641116751269),
                     Point(0.364253443526171, 0.241185279187817),
                     Point(0.355179063360882, -0.0182918781725888)]
        sign.small = small

        return sign
    }

    func orion() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.10900826446281, 0.296860406091371),
                   Point(-0.135925619834711, -0.0497385786802031),
                   Point(0.0435674931129477, -0.0256497461928934),
                   Point(-0.0231707988980716, 0.141824873096447),
                   Point(-0.0507520661157025, 0.158172588832487),
                   Point(-0.0944077134986226, 0.329340101522843),
                   Point(0.00230853994490356, 0.121837563451777),
                   Point(0.0479228650137741, 0.168345177664975),
                   Point(0.254515151515152, -0.0408756345177665),
                   Point(-0.0161349862258953, -0.105154822335025)]
        sign.big = big

        let small = [Point(0.246798898071625, -0.0106878172588833),
                     Point(0.229597796143251, 0.0597284263959391),
                     Point(0.213426997245179, -0.185710659898477),
                     Point(-0.17833608815427, -0.0998604060913705),
                     Point(0.249173553719008, -0.0838121827411167),
                     Point(-0.128349862258953, -0.335121827411168),
                     Point(-0.207460055096419, -0.213809644670051),
                     Point(-0.233471074380165, -0.201756345177665),
                     Point(0.203944903581267, 0.0761497461928934),
                     Point(-0.184225895316804, -0.332634517766497),
                     Point(0.223247933884297, -0.111220812182741),
                     Point(0.164479338842975, -0.227116751269036)]
        sign.small = small

        return sign
    }

    func pavo() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.167848484848485, -0.153565989847716),
                   Point(-0.163432506887052, 0.0624644670050761),
                   Point(-0.0777079889807162, 0.0438654822335025),
                   Point(0.276515151515151, 0.0551446700507614),
                   Point(-0.0386170798898072, 0.189624365482233)]
        sign.big = big

        let small = [Point(0.121884297520661, -0.04401269035533),
                     Point(-0.265917355371901, 0.0801370558375635),
                     Point(0.229768595041322, 0.01351269035533),
                     Point(0.20598347107438, -0.0434619289340101),
                     Point(0.0928705234159779, 0.0652639593908629),
                     Point(0.106253443526171, 0.161426395939086)]
        sign.small = small

        return sign
    }

    func pegasus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.337404958677686, -0.165812182741117),
                   Point(0.195223140495868, 0.135332487309645)]
        sign.big = big

        let small = [Point(-0.109035812672176, -0.131045685279188),
                     Point(-0.122776859504132, 0.0589492385786802),
                     Point(-0.387121212121212, 0.0353248730964467),
                     Point(-0.0339559228650138, -0.160383248730964),
                     Point(-0.033573002754821, 0.126345177664975),
                     Point(-0.0612727272727272, -0.0778654822335025),
                     Point(0.0929256198347107, 0.194147208121827),
                     Point(0.0959090909090909, -0.0891573604060913),
                     Point(-0.0489449035812672, -0.062248730964467),
                     Point(0.177093663911846, -0.0972335025380711),
                     Point(-0.053870523415978, 0.10611421319797),
                     Point(0.0814710743801653, -0.204621827411167),
                     Point(0.0155206611570248, 0.151852791878173),
                     Point(-0.271650137741047, -0.154406091370558)]
        sign.small = small

        return sign
    }

    func perseus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.114330578512397, -0.100431472081218),
                   Point(-0.00717630853994488, 0.301814720812183),
                   Point(-0.0218980716253444, 0.121294416243655),
                   Point(0.177707988980716, -0.188137055837563),
                   Point(0.0430716253443526, -0.0510812182741117),
                   Point(0.204484848484849, 0.0894213197969543),
                   Point(0.22502479338843, 0.134210659898477)]
        sign.big = big

        let small = [Point(0.22502479338843, 0.134208121827411),
                     Point(0.21767217630854, -0.247799492385787),
                     Point(0.186787878787879, 0.00425126903553302),
                     Point(0.043969696969697, 0.292730964467005),
                     Point(0.218498622589532, -0.177340101522843),
                     Point(-0.0611790633608815, -0.0511345177664974),
                     Point(0.486528925619835, -0.201),
                     Point(0.174245179063361, -0.100604060913706),
                     Point(-0.0298429752066116, 0.214715736040609),
                     Point(0.27202479338843, -0.106931472081218),
                     Point(-0.0851184573002755, -0.0681091370558376),
                     Point(-0.0495234159779614, -0.109159898477157),
                     Point(-0.0945123966942149, -0.110794416243655)]
        sign.small = small

        return sign
    }

    func phoenix() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.16700826446281, -0.15053807106599),
                   Point(-0.00912396694214879, -0.0602690355329949),
                   Point(-0.108771349862259, -0.13047461928934)]
        sign.big = big

        let small = [Point(0.22801652892562, -0.065497461928934),
                     Point(-0.012870523415978, 0.128984771573604),
                     Point(-0.106972451790634, -0.00236040609137058)]
        sign.small = small

        return sign
    }

    func picisAustrinus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.284181818181818, 0.0177284263959391),
                   Point(-0.24004958677686, 0.110758883248731),
                   Point(-0.170606060606061, -0.0665304568527919),
                   Point(-0.264022038567493, 0.102682741116751),
                   Point(-0.0990606060606061, 0.0874111675126903),
                   Point(0.215261707988981, 0.111766497461929)]
        sign.big = big

        let small = [Point(0.0575123966942149, 0.104845177664975),
                     Point(0.0458044077134986, 0.0916979695431472),
                     Point(0.200564738292011, 0.0478807106598985)]
        sign.small = small

        return sign
    }

    func pictor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.245752066115702, 0.303116751269036),
                   Point(-0.0238457300275482, -0.046507614213198)]
        sign.big = big

        let small = [Point(-0.0310578512396694, 0.104568527918782)]
        sign.small = small

        return sign
    }

    func pisces() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.207826446280992, -0.0186548223350254),
                     Point(-0.344305785123967, 0.158362944162437),
                     Point(0.327495867768595, 0.153733502538071),
                     Point(0.153889807162534, 0.110286802030457),
                     Point(0.232677685950413, 0.125109137055838),
                     Point(-0.268914600550964, 0.0692766497461929),
                     Point(-0.101011019283747, 0.0960786802030457),
                     Point(0.280055096418733, 0.111154822335025),
                     Point(-0.0440909090909091, 0.101738578680203),
                     Point(-0.25733608815427, 0.124459390862944),
                     Point(0.22766391184573, 0.182350253807107),
                     Point(-0.122038567493113, -0.233032994923858),
                     Point(-0.133212121212121, -0.151964467005076),
                     Point(-0.152407713498623, -0.192413705583756),
                     Point(0.290121212121212, 0.186441624365482)]
        sign.small = small

        return sign
    }

    func puppis() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.142468319559229, 0.17960152284264),
                   Point(0.0757658402203856, 0.110418781725888),
                   Point(-0.193617079889807, -0.165847715736041),
                   Point(0.247283746556474, 0.257819796954315),
                   Point(-0.0922892561983471, -0.159647208121827),
                   Point(0.273787878787879, 0.473819796954315),
                   Point(-0.153961432506887, 0.343715736040609),
                   Point(0.176531680440771, 0.416286802030457)]
        sign.big = big

        let small = [Point(-0.0589862258953168, -0.0699441624365482),
                     Point(0.0101404958677686, -0.026492385786802),
                     Point(-0.0147465564738292, -0.0838350253807107),
                     Point(-0.0841818181818182, 0.35607614213198)]
        sign.small = small

        return sign
    }

    func pyxis() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.088465564738292, 0.170314720812183),
                   Point(0.109917355371901, 0.233624365482234),
                   Point(0.0432617079889807, 0.00766243654822336)]
        sign.big = big

        return sign
    }

    func reticulum() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0419917355371901, 0.0906395939086294),
                   Point(0.0657052341597796, 0.159786802030457),
                   Point(-0.0559724517906336, -0.00257868020304566)]
        sign.big = big

        let small = [Point(0.0163471074380165, 0.0575507614213198),
                     Point(0.00647658402203857, 0.0480558375634518),
                     Point(-0.0439256198347107, 0.0823883248730965)]
        sign.small = small

        return sign
    }

    func sagitta() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.204790633608815, 0.0264010152284264),
                   Point(-0.119633608815427, 0.0574467005076142)]
        sign.big = big

        let small = [Point(-0.0719586776859504, 0.0896802030456853),
                     Point(-0.0643994490358127, 0.0738832487309645)]
        sign.small = small

        return sign
    }

    func sagittarius() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.19433608815427, 0.114522842639594),
                   Point(0.0416198347107438, -0.0711700507614213),
                   Point(0.00239118457300274, 0.00822588832487313),
                   Point(0.219443526170799, 0.0150126903553299),
                   Point(0.190526170798898, -0.0850888324873097),
                   Point(0.0930440771349862, -0.0547842639593909),
                   Point(-0.0210055096418733, -0.0405761421319797),
                   Point(0.296625344352617, 0.0355456852791878)]
        sign.big = big

        return sign
    }

    func scorpius() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.09867217630854, -0.0226015228426396),
                   Point(-0.221421487603306, 0.223662436548223),
                   Point(-0.224198347107438, 0.355337563451777),
                   Point(-0.0112314049586777, 0.150611675126904),
                   Point(0.263457300275482, -0.0978451776649746),
                   Point(-0.258911845730028, 0.27039847715736),
                   Point(0.240584022038567, -0.162355329949239),
                   Point(-0.207214876033058, 0.226670050761421),
                   Point(0.0629779614325069, 0.0161421319796955),
                   Point(0.263752066115703, -0.0200329949238579),
                   Point(0.143928374655647, -0.0395431472081219),
                   Point(-0.018465564738292, 0.233964467005076),
                   Point(-0.279661157024793, 0.297274111675127)]
        sign.big = big

        let small = [Point(-0.300118457300275, 0.230776649746193),
                     Point(-0.109168044077135, 0.352045685279188),
                     Point(-0.0295013774104683, 0.329807106598985),
                     Point(0.203749311294766, -0.172548223350254),
                     Point(0.266997245179063, 0.0493248730964467)]
        sign.small = small

        return sign
    }

    func sculptor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(-0.136856749311295, -0.0430355329949238),
                     Point(0.285140495867769, 0.156621827411168),
                     Point(0.372887052341598, 0.0501294416243655),
                     Point(0.231479338842975, -0.0652893401015228),
                     Point(0.0579862258953168, -0.0555558375634518)]
        sign.small = small

        return sign
    }

    func scutum() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.051030303030303, -0.0936548223350254),
                   Point(-0.0449173553719008, -0.196906091370558)]
        sign.big = big

        let small = [Point(0.0968595041322314, 0.0935710659898477),
                     Point(-0.00513774104683198, -0.0697893401015229),
                     Point(-0.0151129476584022, -0.092751269035533)]
        sign.small = small

        return sign
    }

    func serpensCaput() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0213608815426997, 0.0934238578680203),
                   Point(-0.26903305785124, 0.389664974619289),
                   Point(-0.0661735537190082, 0.384670050761421),
                   Point(-0.035465564738292, -0.172654822335025),
                   Point(-0.0740853994490358, 0.150776649746193),
                   Point(0.053702479338843, -0.0282360406091371),
                   Point(-0.115269972451791, -0.180401015228426)]
        sign.big = big

        let small = [Point(-0.0548264462809917, -0.253177664974619),
                     Point(0.000760330578512425, -0.298203045685279),
                     Point(-0.0704077134986226, 0.218253807106599)]
        sign.small = small

        return sign
    }

    func serpensCauda() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.079633608815427, -0.105111675126904),
                   Point(0.0980881542699724, 0.0981345177664974),
                   Point(0.264641873278237, 0.266187817258883)]
        sign.big = big

        let small = [Point(-0.365517906336088, -0.310989847715736),
                     Point(-0.271429752066116, -0.249489847715736)]
        sign.small = small

        return sign
    }

    func sextans() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.0856556473829201, -0.00299746192893404),
                     Point(-0.0488760330578512, 0.00288071065989845),
                     Point(0.178126721763085, 0.168647208121827),
                     Point(-0.0439476584022039, 0.049497461928934)]
        sign.small = small

        return sign
    }

    func taurus() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0654573002754821, 0.000766497461928915),
                   Point(-0.21067217630854, -0.272439086294416),
                   Point(-0.283484848484849, -0.110383248730965),
                   Point(0.10764738292011, 0.0143451776649746),
                   Point(0.273859504132231, 0.0837791878172588),
                   Point(0.10633608815427, -0.0590558375634518),
                   Point(0.492429752066116, 0.145647208121827)]
        sign.big = big

        let small = [Point(0.159151515151515, 0.0185558375634518),
                     Point(0.476812672176309, 0.131340101522843),
                     Point(0.139727272727273, -0.0234289340101523),
                     Point(0.267173553719008, 0.228494923857868),
                     Point(0.437498622589532, 0.342271573604061)]
        sign.small = small

        return sign
    }

    func telescopium() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.236030303030303, -0.0821979695431472)]
        sign.big = big

        let small = [Point(-0.0465619834710743, -0.0518756345177665),
                     Point(-0.156798898071625, 0.0654263959390863),
                     Point(0.00463360881542696, 0.0869720812182741),
                     Point(0.0648842975206611, 0.0418045685279188),
                     Point(-0.0790633608815427, 0.134022842639594)]
        sign.small = small

        return sign
    }

    func triangulum() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0514931129476584, -0.0714263959390863),
                   Point(0.0596308539944903, 0.0887664974619289),
                   Point(-0.104093663911846, -0.0392030456852792)]
        sign.big = big

        let small = [Point(-0.101796143250689, -0.0502918781725888),
                     Point(-0.0955068870523416, -0.0244517766497462),
                     Point(-0.00858953168044076, -0.0204847715736041)]
        sign.small = small

        return sign
    }

    func triangulumAustrale() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.127774104683196, 0.122776649746193),
                   Point(0.0289586776859504, -0.05501269035533),
                   Point(0.131168044077135, 0.10906345177665),
                   Point(0.0864903581267217, 0.0333984771573604)]
        sign.big = big

        return sign
    }

    func tucana() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.351322314049587, -0.0410634517766498),
                   Point(-0.155977961432507, -0.000416243654822303),
                   Point(0.129666666666667, -0.148477157360406),
                   Point(-0.106079889807163, 0.0496497461928934)]
        sign.big = big

        let small = [Point(0.272608815426997, 0.0814593908629442),
                     Point(-0.036573002754821, 0.0641294416243655)]
        sign.small = small

        return sign
    }

    func ursaMajor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.23663085399449, -0.126845177664975),
                   Point(0.00752066115702477, -0.167829949238579),
                   Point(-0.400906336088154, -0.0940203045685279),
                   Point(-0.30564738292011, -0.139281725888325)]
        sign.big = big

        let small = [Point(0.0106776859504132, -0.0884187817258883),
                     Point(-0.112669421487603, -0.0592639593908629),
                     Point(-0.0129807162534435, 0.0868883248730965),
                     Point(0.128809917355372, 0.125022842639594),
                     Point(0.330236914600551, -0.0245736040609137),
                     Point(0.228586776859504, -0.047748730964467),
                     Point(-0.149515151515152, -0.117205583756345),
                     Point(0.302479338842975, -0.220266497461929),
                     Point(0.141300275482094, 0.102352791878173),
                     Point(-0.0495840220385675, 0.254086294416244),
                     Point(0.324702479338843, -0.008246192893401),
                     Point(0.178556473829201, -0.209642131979695),
                     Point(-0.108969696969697, 0.03),
                     Point(0.158013774104683, -0.142977157360406),
                     Point(-0.0500661157024794, 0.277246192893401)]
        sign.small = small

        return sign
    }

    func ursaMinor() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.0097796143250689, -0.359032994923858),
                   Point(0.0332920110192838, 0.130609137055838),
                   Point(-0.0399752066115702, 0.197431472081218),
                   Point(-0.10130303030303, -0.126746192893401)]
        sign.big = big

        let small = [Point(-0.0621515151515152, 0.016761421319797),
                     Point(-0.0548429752066115, -0.257969543147208),
                     Point(-0.138986225895317, 0.0598553299492386)]
        sign.small = small

        return sign
    }

    func vela() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.376917355371901, 0.0458527918781726),
                   Point(0.205909090909091, 0.175784263959391),
                   Point(0.153269972451791, -0.0835152284263959),
                   Point(0.0754545454545454, 0.168187817258883),
                   Point(-0.246129476584022, 0.0685279187817259)]
        sign.big = big

        let small = [Point(-0.045961432506887, 0.158197969543147),
                     Point(0.0561542699724518, -0.155383248730964),
                     Point(-0.142209366391185, -0.111200507614213)]
        sign.small = small

        return sign
    }

    func virgo() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(-0.0135041322314049, 0.171796954314721),
                   Point(0.195856749311295, -3.80710659898131e-05),
                   Point(0.097771349862259, -0.220598984771574)]
        sign.big = big

        let small = [Point(-0.0594325068870524, -0.0156040609137056),
                     Point(0.129096418732782, -0.0863350253807106),
                     Point(0.442071625344353, -0.0548781725888325),
                     Point(-0.40464738292011, -0.0573223350253807),
                     Point(-0.387421487603306, 0.0764543147208122),
                     Point(0.300732782369146, -0.0132005076142132),
                     Point(0.46667217630854, -0.139106598984772),
                     Point(-0.257526170798898, 0.0812588832487309),
                     Point(0.373561983471074, -0.179304568527919),
                     Point(-0.189482093663912, -0.0530710659898477),
                     Point(0.0595977961432506, 0.0720609137055837)]
        sign.small = small

        return sign
    }

    func volans() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let big = [Point(0.176603305785124, 0.045746192893401),
                   Point(-0.0368760330578512, -0.10060152284264),
                   Point(0.173190082644628, -0.0322664974619289),
                   Point(-0.153212121212121, -0.0777994923857868),
                   Point(0.0203250688705234, -0.028756345177665)]
        sign.big = big

        return sign
    }

    func vulpecula() -> AstrologicalSign {
        var sign = AstrologicalSign()

        let small = [Point(0.29331955922865, -0.0406091370558376),
                     Point(0.15900826446281, -0.0186954314720813)]
        sign.small = small

        return sign
    }
}
