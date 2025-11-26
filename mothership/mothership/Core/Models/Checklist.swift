//
//  Checklist.swift
//  mothership
//
//  Core models for checklists
//

import Foundation

// MARK: - Checklist Types

enum ChecklistType: String, Codable, CaseIterable {
    case charterScoped = "charter_scoped"
    case reference = "reference"
}

enum CharterChecklistType: String, Codable, CaseIterable {
    case preCharter = "pre_charter"
    case checkIn = "check_in"
    case daily = "daily"
    case postCharter = "post_charter"
}

enum ReferenceChecklistType: String, Codable, CaseIterable {
    case safety = "safety"
    case systems = "systems"
    case emergency = "emergency"
}

// MARK: - Checklist Models

struct Checklist: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var type: ChecklistType
    var charterType: CharterChecklistType?
    var referenceType: ReferenceChecklistType?
    var sections: [ChecklistSection]
    var source: ChecklistSource
    var lastFetched: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        type: ChecklistType,
        charterType: CharterChecklistType? = nil,
        referenceType: ReferenceChecklistType? = nil,
        sections: [ChecklistSection] = [],
        source: ChecklistSource = .bundled,
        lastFetched: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.charterType = charterType
        self.referenceType = referenceType
        self.sections = sections
        self.source = source
        self.lastFetched = lastFetched
    }
}

enum ChecklistSource: String, Codable {
    case bundled
    case remote
    case userCreated
}

struct ChecklistSection: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subsections: [ChecklistSubsection]
    
    // Computed property for backward compatibility - returns all items from all subsections
    var items: [ChecklistItem] {
        subsections.flatMap { $0.items }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        subsections: [ChecklistSubsection] = [],
        items: [ChecklistItem] = []
    ) {
        self.id = id
        self.title = title
        
        // If subsections are provided, use them; otherwise create a default subsection from items
        if !subsections.isEmpty {
            self.subsections = subsections
        } else if !items.isEmpty {
            // Backward compatibility: wrap items in a default subsection
            self.subsections = [ChecklistSubsection(title: "", items: items)]
        } else {
            self.subsections = []
        }
    }
}

struct ChecklistSubsection: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var items: [ChecklistItem]
    
    init(
        id: UUID = UUID(),
        title: String,
        items: [ChecklistItem] = []
    ) {
        self.id = id
        self.title = title
        self.items = items
    }
}

struct ChecklistItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var note: String?
    var isChecked: Bool
    var userNote: String?
    var checkedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        note: String? = nil,
        isChecked: Bool = false,
        userNote: String? = nil,
        checkedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.isChecked = isChecked
        self.userNote = userNote
        self.checkedAt = checkedAt
    }
}

// MARK: - Checklist State Management

struct ChecklistState: Codable {
    var checklistId: UUID
    var itemStates: [UUID: ChecklistItemState]
    var lastReset: Date?
    
    init(checklistId: UUID, itemStates: [UUID: ChecklistItemState] = [:], lastReset: Date? = nil) {
        self.checklistId = checklistId
        self.itemStates = itemStates
        self.lastReset = lastReset
    }
}

struct ChecklistItemState: Codable {
    var isChecked: Bool
    var checkedAt: Date?
    var userNote: String?
    
    init(isChecked: Bool = false, checkedAt: Date? = nil, userNote: String? = nil) {
        self.isChecked = isChecked
        self.checkedAt = checkedAt
        self.userNote = userNote
    }
}

struct CharterChecklistStates: Codable {
    var charterId: UUID
    var checklistStates: [UUID: ChecklistState]
    
    init(charterId: UUID, checklistStates: [UUID: ChecklistState] = [:]) {
        self.charterId = charterId
        self.checklistStates = checklistStates
    }
}

// MARK: - Default Check-in Checklist Data

extension Checklist {
    static func defaultCheckInChecklist(using localization: LocalizationService) -> Checklist {
        Checklist(
            title: formatTitleLabel(english: "Yacht Check-in Checklist", russian: "Чек-лист приемки яхты", using: localization),
            type: .charterScoped,
            charterType: .checkIn,
            sections: CheckInChecklistData.defaultSections(using: localization),
            source: .bundled
        )
    }
}

// MARK: - Localization Helpers

/// Formats a bilingual title label based on language:
/// - Russian: "English / Russian"
/// - English: "English"
private func formatTitleLabel(english: String, russian: String, using localization: LocalizationService) -> String {
    let languageCode = localization.effectiveLanguage.code
    if languageCode == "ru" {
        return "\(english) / \(russian)"
    } else {
        return english
    }
}

/// Formats note labels so Russian locale sees only Russian text
private func formatNoteLabel(english: String, russian: String, using localization: LocalizationService) -> String {
    let languageCode = localization.effectiveLanguage.code
    if languageCode == "ru" {
        return russian
    } else {
        return english
    }
}

enum CheckInChecklistData {
    static func defaultSections(using localization: LocalizationService) -> [ChecklistSection] {
        [
        ChecklistSection(
            title: formatTitleLabel(english: "Equipment and Documents", russian: "Оборудование и документы", using: localization),
            subsections: [
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Boat documents", russian: "Документы", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Registration", russian: "Регистрация", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Insurance", russian: "Страховка", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Charter agreement", russian: "Чартерный договор", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Transit log", russian: "Судовой журнал", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Crew list", russian: "Список экипажа", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Skipper's licence", russian: "Права шкипера", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "VHF Radio licence", russian: "Лицензия радиооператора", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Safety Equipment", russian: "Безопасность", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "First aid kit", russian: "Аптечка", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Life jackets", russian: "Спасательные жилеты", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Life lines", russian: "Страховочные стропы", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Fire extinguishers", russian: "Огнетушители", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Fire blanket", russian: "Противопожарная кошма", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Life raft", russian: "Спасательный плот", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Horsseshoe safety ring with light", russian: "Спасательный круг и MOB маячок", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Floating line", russian: "Плавучий линь", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Red rockets, hand flares, fogs", russian: "Сигнальная пиротехника", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "EPIRB", russian: "АРБ", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "VHF radio", russian: "УКВ-радио", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Fog horn", russian: "Туманный горн", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Searchlight", russian: "Прожектор", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Radar reflector", russian: "Радарный отражатель", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Automatic bilge pump", russian: "Автоматическая трюмная помпа", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Manual bilge pump", russian: "Ручная трюмная помпа", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Snorkeling equipment", russian: "Снаряжение для снорклинга", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Emergency tiller", russian: "Аварийный румпель", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Engine", russian: "Двигатель", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Impeller", russian: "Запасная рыльчатка", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Alternator belt", russian: "Запасной ремень", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Diesel can", russian: "Канистра для дизеля", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Sails", russian: "Паруса", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Winch handles", russian: "Ручки лебедок", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Sails repair kit", russian: "Ремкомплект парусов", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Electronic and Navigation", russian: "Электроника и навигация", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Chartplotter with charts", russian: "Картплоттер с картами", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Navigation indicators with covers", russian: "Навигационные индикатор в кокпите с крышками", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Cockpit compass with covers", russian: "Компас в кокпите с крышкой", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Nautical charts", russian: "Бумажные карты", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Pilots", russian: "Лоции", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Parallel ruler", russian: "Параллельная линейка", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Breton plotter", russian: "Плоттер", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Divider", russian: "Циркуль", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Hand bearing compass", russian: "Ручной пеленгатор", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Binocular", russian: "Бинокль", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "FM Radio", russian: "Аудиосистема", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Inverter 12-220V", russian: "Инвертор 12-220В", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Webasto", russian: "Обогреватель", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Fans", russian: "Вентиляторы", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Spare fuses and lights", russian: "Предохранители и лампы", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Hull and deck", russian: "Корпус и палуба", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Swimming ladder", russian: "Лестница для купания", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Cockpit shower", russian: "Душ в кокпите", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Gangway", russian: "Трап", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Cockpit table", russian: "Столик", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Tool box", russian: "Инструменты", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Day figures", russian: "Дневные фигуры", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Moorings", russian: "Швартовые концы", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Cockpit cushions", russian: "Подушки", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Boat hook", russian: "Багор", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Fenders", russian: "Кранцы", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Water hose with connector", russian: "Водяной шланг с коннектором", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Water deck fill with opener", russian: "Крышки водяных танков с ручкой", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Spare anchor", russian: "Запасной якорь", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Bucket", russian: "Ведро", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Mop, brushes", russian: "Швабра, щетки", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Dinghy", russian: "Тузик", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Air pump", russian: "Насос", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Oars", russian: "Вёсла", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Spare oil and petrol", russian: "Бензин и масло", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Dinghy repair kit", russian: "Ремонтный комплект", using: localization))
                    ]
                )
            ]
        ),
        ChecklistSection(
            title: formatTitleLabel(english: "Inside the Boat", russian: "Внутри яхты", using: localization),
            subsections: [
                ChecklistSubsection(
                    title: formatTitleLabel(english: "12V Panel", russian: "12В панель", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Water pump ON", russian: "Водяная помпа включена", using: localization),
                            note: formatNoteLabel(english: "Working. Ask the charter company representative how to switch tanks", russian: "Работает. Узнайте у представителя чартерной компании, как переключать баки", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Bilge pump ON", russian: "Трюмная помпа ON", using: localization),
                            note: formatNoteLabel(english: "Bilge pump ON - manual and automatic mode", russian: "Трюмная помпа ON - ручной и автоматический режим", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Navigation ON", russian: "Навигация ON", using: localization),
                            note: formatNoteLabel(english: "Navigation ON - chartplotter with charts", russian: "Навигация ON - картплоттер с картами", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "VHF radio ON", russian: "VHF-радио ON", using: localization),
                            note: formatNoteLabel(english: "VHF radio ON - volume, check the radio", russian: "VHF-радио ON - громкость, проверьте радио", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Cabin lights ON", russian: "Освещение внутри ON", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "All navigation lights ON", russian: "Все навигационные огни ON", using: localization),
                            note: formatNoteLabel(english: "All navigation lights ON - all indicators are on", russian: "Все навигационные огни ON - все индикаторы горят", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Fridge(s) ON", russian: "Холодильник(и) ON", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Windlass ON (if there is)", russian: "Якорная лебедка ON", using: localization),
                            note: formatNoteLabel(english: "Ask the charter company representative about spare fuse", russian: "Спросите у представителя чартерной компании про запасной предохранитель", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "220V Panel", russian: "Панель 220В", using: localization),
                    items: [
                        ChecklistItem(title: formatTitleLabel(english: "Battery charger is on", russian: "Индикатор берегового питания ON", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "220V sockets work", russian: "Розетки и зарядное устройство работают", using: localization)),
                        ChecklistItem(title: formatTitleLabel(english: "Cable connection is serviceable", russian: "Береговой кабель исправен", using: localization))
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Saloon & Cabins", russian: "Салон и каюты", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Lights", russian: "Лампочки", using: localization),
                            note: formatNoteLabel(english: "Lights work, fixtures are intact, switches work", russian: "Лампочки светят, светильники целые, выключатели работают", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Hatches", russian: "Люки", using: localization),
                            note: formatNoteLabel(english: "Hatches without cracks and scratches, handles and hinges are reliable, don't leak (check with hose/bucket and towel)", russian: "Люки без трещин и царапин, ручки и петли надежные, не протекают (проверьте с помощью шланга/ведра и полотенца)", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Cushions", russian: "Подушки", using: localization),
                            note: formatNoteLabel(english: "Sofa cushions are dry and clean (underneath too), no damage", russian: "Подушки диванов сухие и чистые (снизу тоже), без повреждений", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Floors", russian: "Пайолы", using: localization),
                            note: formatNoteLabel(english: "Floorboards - open all, check keel bolts, seacocks, fittings, valves, hoses. If there is water, check if it's salt or fresh", russian: "Пайолы - откройте все, проверьте килевые болты, кингстоны, фитинги, краны, шланги. Если есть вода, проверьте, соленая или пресная", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Furniture", russian: "Мебель", using: localization),
                            note: formatNoteLabel(english: "Furniture without major damage, no dents, cabinet doors hold securely, locks fix firmly", russian: "Мебель без сильных повреждений, без вмятин, дверцы шкафов держатся надежно, замки крепко фиксируют", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Fans", russian: "Вентиляторы", using: localization),
                            note: formatNoteLabel(english: "Fans blow, no damage", russian: "Вентиляторы дуют, без повреждений", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Scratches", russian: "Царапины", using: localization),
                            note: formatNoteLabel(english: "Scratches and chips - take photos and video of the saloon", russian: "Царапины и сколы - сделайте фото и видео салона", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Toilets", russian: "Гальюны", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Toilet pump(s)", russian: "Помпа туалета", using: localization),
                            note: formatNoteLabel(english: "Toilet pump works for flush and rinse, shower pump, all valves are working, holding tank is empty, valve is closed, no odors", russian: "Помпа туалета работает на смыв и промыв, душевая помпа, все краны исправны, накопитель пустой, кран закрыт, запахи отсутствуют", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Lights", russian: "Лампочки", using: localization),
                            note: formatNoteLabel(english: "Lights work, fixtures are intact, switches work", russian: "Лампочки светят, светильники целые, выключатели работают", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Hatches", russian: "Люки", using: localization),
                            note: formatNoteLabel(english: "Hatches without cracks and scratches, handles and hinges are reliable, don't leak (check with hose/bucket and towel)", russian: "Люки без трещин и царапин, ручки и петли надежные, не протекают (проверьте с помощью шланга/ведра и полотенца)", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Doors", russian: "Двери", using: localization),
                            note: formatNoteLabel(english: "Doors open and close securely, handles and locks don't fall out", russian: "Двери открываются и закрываются надежно, ручки и замки не выпадают", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Galley", russian: "Камбуз", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Gas stove", russian: "Плита", using: localization),
                            note: formatNoteLabel(english: "Stove - turn on gas, gas valve closes, stove locks, oven door locks, second bottle is full", russian: "Плита - включите газ, кран газа перекрывается, плита блокируется, дверца духовки блокируется, второй баллон полный", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Fridges", russian: "Холодильники", using: localization),
                            note: formatNoteLabel(english: "Fridges cool, water is pumped out, no odors", russian: "Холодильники охлаждают, вода откачивается, запахи отсутствуют", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Engine", russian: "Двигатель", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Cleanliness", russian: "Чистота", using: localization),
                            note: formatNoteLabel(english: "Clean and dry - engine and under engine", russian: "Чисто и сухо - мотор и под мотором", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Oil", russian: "Масло", using: localization),
                            note: formatNoteLabel(english: "Engine oil level, transmission oil level, traces of emulsion in transmission, oil reserve", russian: "Уровень масла в двигателе, в трансмиссии, следы эмульсии в трансмиссии, резерв масла", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Coolant", russian: "Охлаждающая жидкость", using: localization),
                            note: formatNoteLabel(english: "Coolant level, antifreeze reserve. Important: do not open on warm or hot engine!", russian: "Уровень охлаждающей жидкости, резерв антифриза. Важно: не открывайте на теплом или горячем моторе!", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Alternator belt", russian: "Ремень генератора", using: localization),
                            note: formatNoteLabel(english: "Alternator belt - condition and tension", russian: "Ремень генератора - состояние и натяжение", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Steering", russian: "Рулевое устройство", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Steering ropes", russian: "Штуртросы", using: localization),
                            note: formatNoteLabel(english: "Steering ropes - condition and tension", russian: "Штуртросы - состояние и натяжение", using: localization)
                        )
                    ]
                )
            ]
        ),
        ChecklistSection(
            title: formatTitleLabel(english: "Outside the Boat", russian: "Снаружи яхты", using: localization),
            subsections: [
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Stern", russian: "Корма", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Pulpit", russian: "Носовые рейлинги", using: localization),
                            note: formatNoteLabel(english: "Pulpit has no play, not bent", russian: "Носовые рейлинги не имеют люфта, не погнуты", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Guardrails", russian: "Леера", using: localization),
                            note: formatNoteLabel(english: "Guardrails are taut, stop rings, carabiners", russian: "Леера натянуты, стопорные кольца, карабины", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Sternlight", russian: "Кормовой огонь", using: localization),
                            note: formatNoteLabel(english: "Stern light works", russian: "Кормовой огонь светит", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Fenders", russian: "Кранцы", using: localization),
                            note: formatNoteLabel(english: "Fenders - count all fenders on the yacht, tie securely", russian: "Кранцы - посчитайте все кранцы на яхте, привяжите надежно", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Mooring lines", russian: "Швартовы", using: localization),
                            note: formatNoteLabel(english: "Mooring lines - quantity, length, check condition", russian: "Швартовы - количество, длина, проверьте состояние", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Gas bottles", russian: "Газовые баллоны", using: localization),
                            note: formatNoteLabel(english: "Gas bottles - quantity, weight, volume", russian: "Газовые баллоны - количество, вес, объем", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Ramp", russian: "Аппарель", using: localization),
                            note: formatNoteLabel(english: "Ramp - open/close", russian: "Аппарель - откройте/закройте", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Outboard", russian: "Мотор для тузика", using: localization),
                            note: formatNoteLabel(english: "Outboard - check fuel level, open fuel and air supply, pull choke, start engine, stop engine after 10-15 seconds, close air and fuel supply", russian: "Мотор для тузика - проверьте уровень топлива, откройте подачу топлива и воздуха, вытяните подсос, заведите мотор, заглушите мотор через 10-15 секунд, закройте подачу воздуха и топлива", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Damages", russian: "Повреждения", using: localization),
                            note: formatNoteLabel(english: "Damages - take photos/video", russian: "Повреждения - сделайте фото/видео", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Sides", russian: "Борта", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Guardrails", russian: "Леера", using: localization),
                            note: formatNoteLabel(english: "Guardrails are taut, stop rings, carabiners", russian: "Леера натянуты, стопорные кольца, карабины", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Stanchions", russian: "Стойки лееров", using: localization),
                            note: formatNoteLabel(english: "Stanchions have no play, not bent", russian: "Стойки лееров не имеют люфта, не погнуты", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Damages", russian: "Повреждения", using: localization),
                            note: formatNoteLabel(english: "Damages - take photos/video", russian: "Повреждения - сделайте фото/видео", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Bow", russian: "Бак", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Pulpit", russian: "Носовые рейлинги", using: localization),
                            note: formatNoteLabel(english: "Pulpit has no play, not bent", russian: "Носовые рейлинги не имеют люфта, не погнуты", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Lights", russian: "Навигационные огни", using: localization),
                            note: formatNoteLabel(english: "Navigation lights - side lights, deck lighting, masthead, all-round", russian: "Навигационные огни - бортовые, подсветка палубы, топовый, круговой", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Windlass", russian: "Якорная лебедка", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Open and fix hatch (lid)", russian: "Откройте и зафиксируйте люк", using: localization),
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Anchor", russian: "Якорь", using: localization),
                            note: formatNoteLabel(english: "Anchor is tied with seizing", russian: "Якорь подвязан шкертиком", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Chain", russian: "Цепь", using: localization),
                            note: formatNoteLabel(english: "Chain is securely tied to boat with seizing, check chain length and markings", russian: "Цепь подвязана шкертиком к лодке надежно, проверьте длину цепи и разметку", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Windlass", russian: "Якорная лебедка", using: localization),
                            note: formatNoteLabel(english: "Windlass - tighten windlass (capstan), untie anchor, lower and raise anchor, tie anchor", russian: "Якорная лебедка - затяните брашпиль (шпиль), отвяжите якорь, опустите и поднимите якорь, подвяжите якорь", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Close hatch (lid)", russian: "Закройте люк", using: localization),
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Engine", russian: "Двигатель", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Start engine", russian: "Запустите", using: localization),
                            note: formatNoteLabel(english: "Start - check wet exhaust, check water stream in forward gear, switch to reverse and check stern wash, record engine hours", russian: "Запустите - проверьте мокрый выхлоп, проверьте струю воды на ходу вперед, переключите на ход назад и проверьте заброс кормы, запишите моточасы", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Navigation", russian: "Навигация", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Echo sounder", russian: "Эхолот", using: localization),
                            note: formatNoteLabel(english: "Echo sounder - ask about depth from keel/sensor/water level", russian: "Эхолот - спросите про глубину от киля/датчика/уровня воды", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Boat speed", russian: "Датчик скорости", using: localization),
                            note: formatNoteLabel(english: "Speed sensor - greater than zero in reverse", russian: "Датчик скорости - больше нуля на ходу назад", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Autopilot", russian: "Автопилот", using: localization),
                            note: formatNoteLabel(english: "Autopilot - turns on, turns rudder left/right", russian: "Автопилот - включается, поворачивает руль влево/вправо", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Windex", russian: "Анемометр", using: localization),
                            note: formatNoteLabel(english: "Anemometer - readings of strength and direction", russian: "Анемометр - показания силы и направления", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "After check", russian: "После проверки", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Engine - neutral and stop", russian: "Двигатель - нейтралка и стоп", using: localization),
                            note: formatNoteLabel(english: "Engine - neutral and stop", russian: "Двигатель - нейтралка и стоп", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Nav lights - off", russian: "Навигационные огни - выключены", using: localization),
                            note: formatNoteLabel(english: "Navigation lights - off", russian: "Навигационные огни - выключены", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Navigation - off", russian: "Навигация - выключена", using: localization),
                            note: formatNoteLabel(english: "Navigation - off", russian: "Навигация - выключена", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Windlass - off", russian: "Якорная лебедка - выключена", using: localization),
                            note: formatNoteLabel(english: "Windlass - off", russian: "Якорная лебедка - выключена", using: localization)
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: formatTitleLabel(english: "Rig", russian: "Снаряжение", using: localization),
                    items: [
                        ChecklistItem(
                            title: formatTitleLabel(english: "Winches", russian: "Лебедки", using: localization),
                            note: formatNoteLabel(english: "Winches - turn clockwise by hand easily and without grinding, don't turn counterclockwise, turn with handle in modes easily and without grinding, vertical play minimal, rotation play minimal, skirt without cracks and damage", russian: "Лебедки - крутятся руками по часовой стрелке легко и без хруста, не крутятся против часовой стрелки, крутятся ручкой в режимах легко и без хруста, вертикальный люфт минимальный, люфт вращения минимальный, юбка без трещин и повреждений", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Ropes", russian: "Тросы", using: localization),
                            note: formatNoteLabel(english: "Ropes - go through by hand and visually, no tears and wear", russian: "Тросы - пройдитесь руками и взглядом, без надрывов и потертостей", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Before open clutches on deck", russian: "Перед открытием стопоров на палубе", using: localization),
                            note: formatNoteLabel(english: "Before opening clutches on deck - secure ropes on winch", russian: "Перед открытием стопоров на палубе - зафиксируйте тросы на лебедке", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Clutches", russian: "Стопоры", using: localization),
                            note: formatNoteLabel(english: "Clutches - open/close, pull back cam and check spring", russian: "Стопоры - откройте/закройте, оттяните кулачок и проверьте пружину", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Shackles", russian: "Скобы", using: localization),
                            note: formatNoteLabel(english: "Shackles - tighten all with pliers", russian: "Скобы - все протяните пассатижами", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Blocks", russian: "Блоки", using: localization),
                            note: formatNoteLabel(english: "Blocks - inspect, rotate without grinding", russian: "Блоки - осмотрите, вращаются без хруста", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Jib cars", russian: "Каретки стакселя", using: localization),
                            note: formatNoteLabel(english: "Jib cars - move along track without distortion", russian: "Каретки стакселя - двигаются вдоль погона без перекосов", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Mainsheet car", russian: "Каретка грота", using: localization),
                            note: formatNoteLabel(english: "Mainsheet car - moves along track without distortion", russian: "Каретка грота - двигается вдоль погона без перекосов", using: localization)
                        ),
                        ChecklistItem(
                            title: formatTitleLabel(english: "Boom", russian: "Гик", using: localization),
                            note: formatNoteLabel(english: "Boom - check all blocks at head and foot, attachment to mast, vang attachment", russian: "Гик - проверьте все блоки у нока и пятки, крепление к мачте, крепление оттяжки", using: localization)
                        )
                    ]
                )
            ]
        ),
        ChecklistSection(
            title: formatTitleLabel(english: "Sails", russian: "Паруса", using: localization),
            items: [
                ChecklistItem(
                    title: formatTitleLabel(english: "Jib (Genoa)", russian: "Стаксель", using: localization),
                    note: formatNoteLabel(english: "Jib - open easily by hand, fabric without tears, seams don't separate, clew without tears, sheets securely fastened, foot without tears, tack securely fastened, leech without tears, leech cord securely fastened, luff tape without tears especially at bottom, halyard without tears, securely fastened, closes easily by hand", russian: "Стаксель - откройте руками легко, ткань без надрывов, швы не расходятся, шкотовый угол без надрывов, шкоты надежно закреплены, нижняя шкаторина без надрывов, галсовый угол надежно закреплен, задняя шкаторина без надрывов, корд по задней надежно закреплен, ликтрос без надрывов, особенно снизу, фал без надрывов, надежно закреплен, закрывается руками легко", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Battens Main", russian: "Грот с латами", using: localization),
                    note: formatNoteLabel(english: "Mainsail - open easily by hand, fabric without tears, seams don't separate, clew without tears, sheets securely fastened, foot without tears, tack securely fastened, leech without tears, leech cord securely fastened, luff tape without tears especially at bottom, halyard without tears, securely fastened, closes easily by hand", russian: "Грот - откройте руками легко, ткань без надрывов, швы не расходятся, шкотовый угол без надрывов, шкоты надежно закреплены, нижняя шкаторина без надрывов, галсовый угол надежно закреплен, задняя шкаторина без надрывов, корд по задней надежно закреплен, ликтрос без надрывов, особенно снизу, фал без надрывов, надежно закреплен, закрывается руками легко", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Furling Main", russian: "Грот с закруткой", using: localization),
                    note: formatNoteLabel(english: "Furling mainsail - open easily by hand, fabric without tears, seams don't separate, clew without tears, sheets securely fastened, foot without tears, tack securely fastened, leech without tears, leech cord securely fastened, luff tape without tears especially at bottom, halyard without tears, securely fastened, closes easily by hand", russian: "Грот с закруткой - откройте руками легко, ткань без надрывов, швы не расходятся, шкотовый угол без надрывов, шкоты надежно закреплены, нижняя шкаторина без надрывов, галсовый угол надежно закреплен, задняя шкаторина без надрывов, корд по задней надежно закреплен, ликтрос без надрывов, особенно снизу, фал без надрывов, надежно закреплен, закрывается руками легко", using: localization)
                )
            ]
        ),
        ChecklistSection(
            title: formatTitleLabel(english: "Optional Equipment", russian: "Дополнительное оборудование", using: localization),
            items: [
                ChecklistItem(
                    title: formatTitleLabel(english: "Generator", russian: "Генератор", using: localization),
                    note: formatNoteLabel(english: "Generator - ask charter company representative: how to properly start and stop, how to switch boat to generator or shore power", russian: "Генератор - узнайте у представителя чартерной компании: как правильно запускать и останавливать, как переключать лодку на генератор или береговое питание", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Air conditioner", russian: "Кондиционер", using: localization),
                    note: formatNoteLabel(english: "Air conditioner - check seacock for raw water cooling, before turning on make sure it's open", russian: "Кондиционер - проверьте кран трубы забортного охлаждения, перед включением убедитесь, что он открыт", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Watermaker", russian: "Опреснитель", using: localization),
                    note: formatNoteLabel(english: "Watermaker - don't use in marina, ask charter company representative how to properly start and use", russian: "Опреснитель - не используйте в марине, узнайте у представителя чартерной компании, как правильно запускать и использовать", using: localization)
                )
            ]
        ),
        ChecklistSection(
            title: formatTitleLabel(english: "Safety Equipment Check", russian: "Безопасность", using: localization),
            items: [
                ChecklistItem(
                    title: formatTitleLabel(english: "Life jackets", russian: "Спасательные жилеты", using: localization),
                    note: formatNoteLabel(english: "Life jackets - quantity, ask charter company for children's jackets if there are children in crew, cylinder condition if jackets are inflatable", russian: "Спасательные жилеты - количество, попросите в чартерной детские жилеты, если в экипаже есть дети, состояние баллонов, если жилеты надувные", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Safety harnesses", russian: "Страховочные обвязки", using: localization),
                    note: formatNoteLabel(english: "Safety harnesses - quantity, straps with carabiners, carabiners are working", russian: "Страховочные обвязки - количество, стропы с карабинами, карабины исправны", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Life raft", russian: "Спасательный плот", using: localization),
                    note: formatNoteLabel(english: "Life raft - check last inspection date, check reliability and method of raft attachment", russian: "Спасательный плот - проверьте дату последнего осмотра, проверьте надежность и метод крепления плота", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Life ring/horseshoe", russian: "Спасательный круг и MOB маячок", using: localization),
                    note: formatNoteLabel(english: "Life ring and MOB beacon - check light functionality", russian: "Спасательный круг и MOB маячок - проверьте исправность лампочки", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Visual Distress signals", russian: "Пиротехника", using: localization),
                    note: formatNoteLabel(english: "Pyrotechnics - location, quantity, expiration date", russian: "Пиротехника - расположение, количество, срок годности", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Fire extinguishers", russian: "Огнетушители", using: localization),
                    note: formatNoteLabel(english: "Fire extinguishers - location, type, quantity, expiration date", russian: "Огнетушители - расположение, тип, количество, срок годности", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Smoke and CO detectors (if any)", russian: "Датчики дыма и CO (если есть)", using: localization),
                    note: formatNoteLabel(english: "Smoke and CO detectors (if any) - location", russian: "Датчики дыма и CO (если есть) - расположение", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "First aid kit", russian: "Аптечка", using: localization),
                    note: formatNoteLabel(english: "First aid kit - location, contents, expiration date", russian: "Аптечка - расположение, состав, срок годности", using: localization)
                )
            ]
        ),
        ChecklistSection(
            title: formatTitleLabel(english: "Communication with Charter Manager", russian: "Общение с чартерной", using: localization),
            items: [
                ChecklistItem(
                    title: formatTitleLabel(english: "Point out major problems", russian: "Укажите на основные недочеты и проблемы", using: localization),
                    note: formatNoteLabel(english: "Point out major shortcomings and problems. Discuss everything marked in the checklist", russian: "Укажите на основные недочеты и проблемы. Обсудите все, что пометили в чек-листе", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Ask about: cruising engine speeds, fuel consumption", russian: "Узнайте про: крейсерские обороты двигателя, расход топлива", using: localization),
                    note: formatNoteLabel(english: "Ask about: cruising engine speeds, fuel consumption, fuel and water tank capacity, water tank switch location", russian: "Узнайте про: крейсерские обороты двигателя, расход топлива, емкость топливного и водяных баков, расположение переключателя водяных баков", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Ask for list of required documents for state authorities", russian: "Уточните список необходимых документов для госорганов", using: localization),
                    note: formatNoteLabel(english: "Clarify list of required documents for state authorities", russian: "Уточните список необходимых документов для госорганов", using: localization)
                ),
                ChecklistItem(
                    title: formatTitleLabel(english: "Write down contacts", russian: "Запишите контакты", using: localization),
                    note: formatNoteLabel(english: "Write down contacts of charter company, rescue services and coast guard", russian: "Запишите контакты чартерной, спасательных служб и береговой охраны", using: localization)
                )
            ]
        )
        ]
    }
}
