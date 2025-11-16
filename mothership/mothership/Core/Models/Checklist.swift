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
    static func defaultCheckInChecklist() -> Checklist {
        Checklist(
            title: "Yacht Check-in Checklist / Чек-лист приема яхты",
            type: .charterScoped,
            charterType: .checkIn,
            sections: CheckInChecklistData.defaultSections,
            source: .bundled
        )
    }
}

enum CheckInChecklistData {
    static let defaultSections: [ChecklistSection] = [
        ChecklistSection(
            title: "Equipment and Documents / Оборудование и документы",
            items: [
                ChecklistItem(title: "Registration / Регистрация"),
                ChecklistItem(title: "Insurance / Страховка"),
                ChecklistItem(title: "Charter agreement / Чартерный договор"),
                ChecklistItem(title: "Transit log / Судовой журнал"),
                ChecklistItem(title: "Crew list / Список экипажа"),
                ChecklistItem(title: "Skipper's licence / Права шкипера"),
                ChecklistItem(title: "VHF Radio licence / Лицензия на радиостанцию"),
                ChecklistItem(title: "First aid kit / Аптечка"),
                ChecklistItem(title: "Life jackets / Спасательные жилеты"),
                ChecklistItem(title: "Life lines / Страховочные стропы"),
                ChecklistItem(title: "Fire extinguishers / Огнетушители"),
                ChecklistItem(title: "Fire blanket / Противопожарная кошма"),
                ChecklistItem(title: "EPIRB / EPIRB"),
                ChecklistItem(title: "VHF radio / УКВ-радио"),
                ChecklistItem(title: "Fog horn / Туманный горн"),
                ChecklistItem(title: "Bilge pumps / Трюмные помпы"),
                ChecklistItem(title: "Pyrotechnics / Пиротехника"),
                ChecklistItem(title: "Searchlight / Прожектор"),
                ChecklistItem(title: "Radar reflector / Радарный отражатель"),
                ChecklistItem(title: "Life raft / Спасательный плот"),
                ChecklistItem(title: "Safety ring / Спасательный круг"),
                ChecklistItem(title: "Floating line / Плавучий линь"),
                ChecklistItem(title: "Snorkeling equipment / Снаряжение для снорклинга"),
                ChecklistItem(title: "Emergency tiller / Аварийный румпель"),
                ChecklistItem(title: "Impeller / Крыльчатка помпы"),
                ChecklistItem(title: "Alternator belt / Ремень генератора"),
                ChecklistItem(title: "Diesel can / Канистра для дизеля"),
                ChecklistItem(title: "Winch handles / Ручки для лебедок"),
                ChecklistItem(title: "Sails repair kit / Ремкомплект парусов")
            ]
        ),
        ChecklistSection(
            title: "Inside the Boat / Внутри яхты - 12V Panel",
            items: [
                ChecklistItem(
                    title: "Water pump ON / Водяная помпа включена",
                    note: "Работает. Узнайте у представителя чартерной компании, как переключать баки"
                ),
                ChecklistItem(
                    title: "Bilge pump ON - manual and automatic / Трюмная помпа ON - ручной и автоматический режим",
                    note: "Трюмная помпа ON - ручной и автоматический режим"
                ),
                ChecklistItem(
                    title: "Navigation ON - chart plotter with charts / Навигация ON - картплоттер с картами",
                    note: "Навигация ON - картплоттер с картами"
                ),
                ChecklistItem(
                    title: "VHF radio ON - volume and radio check / VHF-радио ON - громкость, проверьте радио",
                    note: "VHF-радио ON - громкость, проверьте радио"
                ),
                ChecklistItem(
                    title: "Cabin lights ON / Освещение внутри ON",
                    note: "Освещение внутри ON"
                ),
                ChecklistItem(
                    title: "All navigation lights ON - all indicators are on / Все навигационные огни ON - все индикаторы горят",
                    note: "Все навигационные огни ON - все индикаторы горят"
                ),
                ChecklistItem(
                    title: "Fridge(s) ON / Холодильник(и) ON",
                    note: "Холодильник(и) ON"
                ),
                ChecklistItem(
                    title: "Windlass ON (if there is) / Якорная лебедка ON",
                    note: "Якорная лебедка ON. Спросите про запасной предохранитель"
                )
            ]
        ),
        ChecklistSection(
            title: "Engine / Двигатель",
            items: [
                ChecklistItem(
                    title: "Cleanliness - engine and under engine dry and clean / Чисто и сухо - мотор и под мотором",
                    note: "Чисто и сухо - мотор и под мотором"
                ),
                ChecklistItem(
                    title: "Oil - engine level, saildrive level, spare oil / Уровень масла в двигателе, в трансмиссии, резерв масла",
                    note: "Уровень масла в двигателе, в трансмиссии, следы эмульсии в трансмиссии, резерв масла"
                ),
                ChecklistItem(
                    title: "Coolant level and spare coolant / Уровень охлаждающей жидкости, резерв антифриза",
                    note: "Важно: не открывайте на теплом или горячем моторе!"
                ),
                ChecklistItem(
                    title: "Alternator belt - condition and tension / Ремень генератора - состояние и натяжение",
                    note: "Ремень генератора - состояние и натяжение"
                ),
                ChecklistItem(
                    title: "Start engine - check wet exhaust / Запустите - проверьте мокрый выхлоп",
                    note: "Запустите - проверьте мокрый выхлоп, проверьте струю воды на ходу вперед, переключите на ход назад и проверьте заброс кормы, запишите моточасы"
                )
            ]
        ),
        ChecklistSection(
            title: "Sails / Паруса",
            items: [
                ChecklistItem(
                    title: "Jib - open by hand easily / Стаксель - открывается руками легко",
                    note: "Ткань паруса без надрывов, швы не расходятся"
                ),
                ChecklistItem(
                    title: "Jib - close by hand easily / Стаксель - закрывается руками легко",
                    note: "Закрывается руками легко"
                ),
                ChecklistItem(
                    title: "Main - set and down / Грот - поднимите и опустите",
                    note: "Ткань паруса без надрывов, швы не расходятся, латы не сломаны"
                )
            ]
        ),
        ChecklistSection(
            title: "Navigation / Навигация",
            items: [
                ChecklistItem(
                    title: "Echo sounder - ask about depth from keel/sensor/sea level / Эхолот - спросите про глубину",
                    note: "Эхолот - спросите у представителя чартерной компании про глубину от киля/датчика/уровня воды"
                ),
                ChecklistItem(
                    title: "Boat speed - indicate more than zero / Датчик скорости - больше нуля на ходу",
                    note: "Датчик скорости - больше нуля на ходу назад"
                ),
                ChecklistItem(
                    title: "Autopilot - fix course, turn right/left / Автопилот - включается, поворачивает руль",
                    note: "Автопилот - включается, поворачивает руль влево/вправо"
                ),
                ChecklistItem(
                    title: "Windex - check wind speed and direction / Анемометр - показания силы и направления",
                    note: "Анемометр - показания силы и направления"
                )
            ]
        ),
        ChecklistSection(
            title: "Safety Equipment Check / Безопасность",
            items: [
                ChecklistItem(
                    title: "Life jackets - quantity, check cylinders / Спасательные жилеты - количество, состояние баллонов",
                    note: "Спасательные жилеты - количество, попросите в чартерной детские жилеты, если в экипаже есть дети, состояние баллонов, если жилеты надувные"
                ),
                ChecklistItem(
                    title: "Safety harnesses - quantity / Страховочные обвязки - количество",
                    note: "Страховочные обвязки - количество, стропы с карабинами, карабины исправны"
                ),
                ChecklistItem(
                    title: "Life raft - check date / Спасательный плот - проверьте дату",
                    note: "Спасательный плот - проверьте дату последнего осмотра, проверьте надежность и метод крепления плота"
                ),
                ChecklistItem(
                    title: "Fire extinguishers - location, quantity, expiry date / Огнетушители - расположение, количество, срок годности",
                    note: "Огнетушители - расположение, тип, количество, срок годности"
                ),
                ChecklistItem(
                    title: "First aid kit - location, contents / Аптечка - расположение, состав",
                    note: "Аптечка - расположение, состав, срок годности"
                )
            ]
        ),
        ChecklistSection(
            title: "Communication with Charter Manager / Общение с чартерной",
            items: [
                ChecklistItem(
                    title: "Point out major problems / Укажите на основные недочеты и проблемы",
                    note: "Укажите на основные недочеты и проблемы. Обсудите все, что пометили в чек-листе"
                ),
                ChecklistItem(
                    title: "Ask about: cruising engine speeds, fuel consumption / Узнайте про: крейсерские обороты двигателя, расход топлива",
                    note: "Узнайте про: крейсерские обороты двигателя, расход топлива, емкость топливного и водяных баков, расположение переключателя водяных баков"
                ),
                ChecklistItem(
                    title: "Write down contacts / Запишите контакты",
                    note: "Запишите контакты чартерной, спасательных служб и береговой охраны"
                )
            ]
        )
    ]
}

