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
            subsections: [
                ChecklistSubsection(
                    title: "Boat documents / Документы",
                    items: [
                        ChecklistItem(title: "Registration / Регистрация"),
                        ChecklistItem(title: "Insurance / Страховка"),
                        ChecklistItem(title: "Charter agreement / Чартерный договор"),
                        ChecklistItem(title: "Transit log / Судовой журнал"),
                        ChecklistItem(title: "Crew list / Список экипажа"),
                        ChecklistItem(title: "Skipper's licence / Права шкипера"),
                        ChecklistItem(title: "VHF Radio licence / Лицензия радиооператора")
                    ]
                ),
                ChecklistSubsection(
                    title: "Safety Equipment / Безопасность",
                    items: [
                        ChecklistItem(title: "First aid kit / Аптечка"),
                        ChecklistItem(title: "Life jackets / Спасательные жилеты"),
                        ChecklistItem(title: "Life lines / Страховочные стропы"),
                        ChecklistItem(title: "Fire extinguishers / Огнетушители"),
                        ChecklistItem(title: "Fire blanket / Противопожарная кошма"),
                        ChecklistItem(title: "Life raft / Спасательный плот"),
                        ChecklistItem(title: "Horsseshoe safety ring with light / Спасательный круг и MOB маячок"),
                        ChecklistItem(title: "Floating line / Плавучий линь"),
                        ChecklistItem(title: "Red rockets, hand flares, fogs / Сигнальная пиротехника"),
                        ChecklistItem(title: "EPIRB / АРБ"),
                        ChecklistItem(title: "VHF radio / УКВ-радио"),
                        ChecklistItem(title: "Fog horn / Туманный горн"),
                        ChecklistItem(title: "Searchlight / Прожектор"),
                        ChecklistItem(title: "Radar reflector / Радарный отражатель"),
                        ChecklistItem(title: "Automatic bilge pump / Автоматическая трюмная помпа"),
                        ChecklistItem(title: "Manual bilge pump / Ручная трюмная помпа"),
                        ChecklistItem(title: "Snorkeling equipment / Снаряжение для снорклинга"),
                        ChecklistItem(title: "Emergency tiller / Аварийный румпель")
                    ]
                ),
                ChecklistSubsection(
                    title: "Engine / Двигатель",
                    items: [
                        ChecklistItem(title: "Impeller / Запасная рыльчатка"),
                        ChecklistItem(title: "Alternator belt / Запасной ремень"),
                        ChecklistItem(title: "Diesel can / Канистра для дизеля")
                    ]
                ),
                ChecklistSubsection(
                    title: "Sails / Паруса",
                    items: [
                        ChecklistItem(title: "Winch handles / Ручки лебедок"),
                        ChecklistItem(title: "Sails repair kit / Ремкомплект парусов")
                    ]
                ),
                ChecklistSubsection(
                    title: "Electronic and Navigation / Электроника и навигация",
                    items: [
                        ChecklistItem(title: "Chartplotter with charts / Картплоттер с картами"),
                        ChecklistItem(title: "Navigation indicators with covers / Навигационные индикатор в кокпите с крышками"),
                        ChecklistItem(title: "Cockpit compass with covers / Компас в кокпите с крышкой"),
                        ChecklistItem(title: "Nautical charts / Бумажные карты"),
                        ChecklistItem(title: "Pilots / Лоции"),
                        ChecklistItem(title: "Parallel ruler / Параллельная линейка"),
                        ChecklistItem(title: "Breton plotter / Плоттер"),
                        ChecklistItem(title: "Divider / Циркуль"),
                        ChecklistItem(title: "Hand bearing compass / Ручной пеленгатор"),
                        ChecklistItem(title: "Binocular / Бинокль"),
                        ChecklistItem(title: "FM Radio / Аудиосистема"),
                        ChecklistItem(title: "Inverter 12-220V / Инвертор 12-220В"),
                        ChecklistItem(title: "Webasto / Обогреватель"),
                        ChecklistItem(title: "Fans / Вентиляторы"),
                        ChecklistItem(title: "Spare fuses and lights / Предохранители и лампы")
                    ]
                ),
                ChecklistSubsection(
                    title: "Hull and deck / Корпус и палуба",
                    items: [
                        ChecklistItem(title: "Swimming ladder / Лестница для купания"),
                        ChecklistItem(title: "Cockpit shower / Душ в кокпите"),
                        ChecklistItem(title: "Gangway / Трап"),
                        ChecklistItem(title: "Cockpit table / Столик"),
                        ChecklistItem(title: "Tool box / Инструменты"),
                        ChecklistItem(title: "Day figures / Дневные фигуры"),
                        ChecklistItem(title: "Moorings / Швартовые концы"),
                        ChecklistItem(title: "Cockpit cushions / Подушки"),
                        ChecklistItem(title: "Boat hook / Багор"),
                        ChecklistItem(title: "Fenders / Кранцы"),
                        ChecklistItem(title: "Water hose with connector / Водяной шланг с коннектором"),
                        ChecklistItem(title: "Water deck fill with opener / Крышки водяных танков с ручкой"),
                        ChecklistItem(title: "Spare anchor / Запасной якорь"),
                        ChecklistItem(title: "Bucket / Ведро"),
                        ChecklistItem(title: "Mop, brushes / Швабра, щетки")
                    ]
                ),
                ChecklistSubsection(
                    title: "Dinghy / Тузик",
                    items: [
                        ChecklistItem(title: "Air pump / Насос"),
                        ChecklistItem(title: "Oars / Вёсла"),
                        ChecklistItem(title: "Spare oil and petrol / Бензин и масло"),
                        ChecklistItem(title: "Dinghy repair kit / Ремонтный комплект")
                    ]
                )
            ]
        ),
        ChecklistSection(
            title: "Inside the Boat / Внутри яхты",
            subsections: [
                ChecklistSubsection(
                    title: "12V Panel / 12В панель",
                    items: [
                        ChecklistItem(
                            title: "Water pump ON / Водяная помпа включена",
                            note: "Работает. Узнайте у представителя чартерной компании, как переключать баки"
                        ),
                        ChecklistItem(
                            title: "Bilge pump ON / Трюмная помпа ON",
                            note: "Трюмная помпа ON - ручной и автоматический режим"
                        ),
                        ChecklistItem(
                            title: "Navigation ON / Навигация ON",
                            note: "Навигация ON - картплоттер с картами"
                        ),
                        ChecklistItem(
                            title: "VHF radio ON / VHF-радио ON",
                            note: "VHF-радио ON - громкость, проверьте радио"
                        ),
                        ChecklistItem(
                            title: "Cabin lights ON / Освещение внутри ON",
                        ),
                        ChecklistItem(
                            title: "All navigation lights ON / Все навигационные огни ON",
                            note: "Все навигационные огни ON - все индикаторы горят"
                        ),
                        ChecklistItem(
                            title: "Fridge(s) ON / Холодильник(и) ON",
                        ),
                        ChecklistItem(
                            title: "Windlass ON (if there is) / Якорная лебедка ON",
                            note: "Спросите у представителя чартерной компании про запасной предохранитель"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "220V Panel / Панель 220В",
                    items: [
                        ChecklistItem(title: "Battery charger is on / Индикатор берегового питания ON"),
                        ChecklistItem(title: "220V sockets work / Розетки и зарядное устройство работают"),
                        ChecklistItem(title: "Cable connection is serviceable / Береговой кабель исправен")
                    ]
                ),
                ChecklistSubsection(
                    title: "Saloon & Cabins / Салон и каюты",
                    items: [
                        ChecklistItem(
                            title: "Lights / Лампочки",
                            note: "Лампочки светят, светильники целые, выключатели работают"
                        ),
                        ChecklistItem(
                            title: "Hatches / Люки",
                            note: "Люки без трещин и царапин, ручки и петли надежные, не протекают (проверьте с помощью шланга/ведра и полотенца)"
                        ),
                        ChecklistItem(
                            title: "Cushions / Подушки",
                            note: "Подушки диванов сухие и чистые (снизу тоже), без повреждений"
                        ),
                        ChecklistItem(
                            title: "Floors / Пайолы",
                            note: "Пайолы - откройте все, проверьте килевые болты, кингстоны, фитинги, краны, шланги. Если есть вода, проверьте, соленая или пресная"
                        ),
                        ChecklistItem(
                            title: "Furniture / Мебель",
                            note: "Мебель без сильных повреждений, без вмятин, дверцы шкафов держатся надежно, замки крепко фиксируют"
                        ),
                        ChecklistItem(
                            title: "Fans / Вентиляторы",
                            note: "Вентиляторы дуют, без повреждений"
                        ),
                        ChecklistItem(
                            title: "Scratches / Царапины",
                            note: "Царапины и сколы - сделайте фото и видео салона"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Toilets / Гальюны",
                    items: [
                        ChecklistItem(
                            title: "Toilet pump(s) / Помпа туалета",
                            note: "Помпа туалета работает на смыв и промыв, душевая помпа, все краны исправны, накопитель пустой, кран закрыт, запахи отсутствуют"
                        ),
                        ChecklistItem(
                            title: "Lights / Лампочки",
                            note: "Лампочки светят, светильники целые, выключатели работают"
                        ),
                        ChecklistItem(
                            title: "Hatches / Люки",
                            note: "Люки без трещин и царапин, ручки и петли надежные, не протекают (проверьте с помощью шланга/ведра и полотенца)"
                        ),
                        ChecklistItem(
                            title: "Doors / Двери",
                            note: "Двери открываются и закрываются надежно, ручки и замки не выпадают"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Galley / Камбуз",
                    items: [
                        ChecklistItem(
                            title: "Gas stove / Плита",
                            note: "Плита - включите газ, кран газа перекрывается, плита блокируется, дверца духовки блокируется, второй баллон полный"
                        ),
                        ChecklistItem(
                            title: "Fridges / Холодильники",
                            note: "Холодильники охлаждают, вода откачивается, запахи отсутствуют"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Engine / Двигатель",
                    items: [
                        ChecklistItem(
                            title: "Cleanliness / Чистота",
                            note: "Чисто и сухо - мотор и под мотором"
                        ),
                        ChecklistItem(
                            title: "Oil / Масло",
                            note: "Уровень масла в двигателе, в трансмиссии, следы эмульсии в трансмиссии, резерв масла"
                        ),
                        ChecklistItem(
                            title: "Coolant / Охлаждающая жидкость",
                            note: "Уровень охлаждающей жидкости, резерв антифриза. Важно: не открывайте на теплом или горячем моторе!"
                        ),
                        ChecklistItem(
                            title: "Alternator belt / Ремень генератора",
                            note: "Ремень генератора - состояние и натяжение"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Steering / Рулевое устройство",
                    items: [
                        ChecklistItem(
                            title: "Steering ropes / Штуртросы",
                            note: "Штуртросы - состояние и натяжение"
                        )
                    ]
                )
            ]
        ),
        ChecklistSection(
            title: "Outside the Boat / Снаружи яхты",
            subsections: [
                ChecklistSubsection(
                    title: "Stern / Корма",
                    items: [
                        ChecklistItem(
                            title: "Pulpit / Носовые рейлинги",
                            note: "Носовые рейлинги не имеют люфта, не погнуты"
                        ),
                        ChecklistItem(
                            title: "Guardrails / Леера",
                            note: "Леера натянуты, стопорные кольца, карабины"
                        ),
                        ChecklistItem(
                            title: "Sternlight / Кормовой огонь",
                            note: "Кормовой огонь светит"
                        ),
                        ChecklistItem(
                            title: "Fenders / Кранцы",
                            note: "Кранцы - посчитайте все кранцы на яхте, привяжите надежно"
                        ),
                        ChecklistItem(
                            title: "Mooring lines / Швартовы",
                            note: "Швартовы - количество, длина, проверьте состояние"
                        ),
                        ChecklistItem(
                            title: "Gas bottles / Газовые баллоны",
                            note: "Газовые баллоны - количество, вес, объем"
                        ),
                        ChecklistItem(
                            title: "Ramp / Аппарель",
                            note: "Аппарель - откройте/закройте"
                        ),
                        ChecklistItem(
                            title: "Outboard / Мотор для тузика",
                            note: "Мотор для тузика - проверьте уровень топлива, откройте подачу топлива и воздуха, вытяните подсос, заведите мотор, заглушите мотор через 10-15 секунд, закройте подачу воздуха и топлива"
                        ),
                        ChecklistItem(
                            title: "Damages / Повреждения",
                            note: "Повреждения - сделайте фото/видео"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Sides / Борта",
                    items: [
                        ChecklistItem(
                            title: "Guardrails / Леера",
                            note: "Леера натянуты, стопорные кольца, карабины"
                        ),
                        ChecklistItem(
                            title: "Stanchions / Стойки лееров",
                            note: "Стойки лееров не имеют люфта, не погнуты"
                        ),
                        ChecklistItem(
                            title: "Damages / Повреждения",
                            note: "Повреждения - сделайте фото/видео"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Bow / Бак",
                    items: [
                        ChecklistItem(
                            title: "Pulpit / Носовые рейлинги",
                            note: "Носовые рейлинги не имеют люфта, не погнуты"
                        ),
                        ChecklistItem(
                            title: "Lights / Навигационные огни",
                            note: "Навигационные огни - бортовые, подсветка палубы, топовый, круговой"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Windlass / Якорная лебедка",
                    items: [
                        ChecklistItem(
                            title: "Open and fix hatch (lid) / Откройте и зафиксируйте люк",
                        ),
                        ChecklistItem(
                            title: "Anchor / Якорь",
                            note: "Якорь подвязан шкертиком"
                        ),
                        ChecklistItem(
                            title: "Chain / Цепь",
                            note: "Цепь подвязана шкертиком к лодке надежно, проверьте длину цепи и разметку"
                        ),
                        ChecklistItem(
                            title: "Windlass / Якорная лебедка",
                            note: "Якорная лебедка - затяните брашпиль (шпиль), отвяжите якорь, опустите и поднимите якорь, подвяжите якорь"
                        ),
                        ChecklistItem(
                            title: "Close hatch (lid) / Закройте люк",
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Engine / Двигатель",
                    items: [
                        ChecklistItem(
                            title: "Start engine / Запустите",
                            note: "Запустите - проверьте мокрый выхлоп, проверьте струю воды на ходу вперед, переключите на ход назад и проверьте заброс кормы, запишите моточасы"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Navigation / Навигация",
                    items: [
                        ChecklistItem(
                            title: "Echo sounder / Эхолот",
                            note: "Эхолот - спросите про глубину от киля/датчика/уровня воды"
                        ),
                        ChecklistItem(
                            title: "Boat speed / Датчик скорости",
                            note: "Датчик скорости - больше нуля на ходу назад"
                        ),
                        ChecklistItem(
                            title: "Autopilot / Автопилот",
                            note: "Автопилот - включается, поворачивает руль влево/вправо"
                        ),
                        ChecklistItem(
                            title: "Windex / Анемометр",
                            note: "Анемометр - показания силы и направления"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "After check / После проверки",
                    items: [
                        ChecklistItem(
                            title: "Engine - neutral and stop / Двигатель - нейтралка и стоп",
                            note: "Двигатель - нейтралка и стоп"
                        ),
                        ChecklistItem(
                            title: "Nav lights - off / Навигационные огни - выключены",
                            note: "Навигационные огни - выключены"
                        ),
                        ChecklistItem(
                            title: "Navigation - off / Навигация - выключена",
                            note: "Навигация - выключена"
                        ),
                        ChecklistItem(
                            title: "Windlass - off / Якорная лебедка - выключена",
                            note: "Якорная лебедка - выключена"
                        )
                    ]
                ),
                ChecklistSubsection(
                    title: "Rig / Снаряжение",
                    items: [
                        ChecklistItem(
                            title: "Winches / Лебедки",
                            note: "Лебедки - крутятся руками по часовой стрелке легко и без хруста, не крутятся против часовой стрелки, крутятся ручкой в режимах легко и без хруста, вертикальный люфт минимальный, люфт вращения минимальный, юбка без трещин и повреждений"
                        ),
                        ChecklistItem(
                            title: "Ropes / Тросы",
                            note: "Тросы - пройдитесь руками и взглядом, без надрывов и потертостей"
                        ),
                        ChecklistItem(
                            title: "Before open clutches on deck / Перед открытием стопоров на палубе",
                            note: "Перед открытием стопоров на палубе - зафиксируйте тросы на лебедке"
                        ),
                        ChecklistItem(
                            title: "Clutches / Стопоры",
                            note: "Стопоры - откройте/закройте, оттяните кулачок и проверьте пружину"
                        ),
                        ChecklistItem(
                            title: "Shackles / Скобы",
                            note: "Скобы - все протяните пассатижами"
                        ),
                        ChecklistItem(
                            title: "Blocks / Блоки",
                            note: "Блоки - осмотрите, вращаются без хруста"
                        ),
                        ChecklistItem(
                            title: "Jib cars / Каретки стакселя",
                            note: "Каретки стакселя - двигаются вдоль погона без перекосов"
                        ),
                        ChecklistItem(
                            title: "Mainsheet car / Каретка грота",
                            note: "Каретка грота - двигается вдоль погона без перекосов"
                        ),
                        ChecklistItem(
                            title: "Boom / Гик",
                            note: "Гик - проверьте все блоки у нока и пятки, крепление к мачте, крепление оттяжки"
                        )
                    ]
                )
            ]
        ),
        ChecklistSection(
            title: "Sails / Паруса",
            items: [
                ChecklistItem(
                    title: "Jib (Genoa) / Стаксель",
                    note: "Стаксель - откройте руками легко, ткань без надрывов, швы не расходятся, шкотовый угол без надрывов, шкоты надежно закреплены, нижняя шкаторина без надрывов, галсовый угол надежно закреплен, задняя шкаторина без надрывов, корд по задней надежно закреплен, ликтрос без надрывов, особенно снизу, фал без надрывов, надежно закреплен, закрывается руками легко"
                ),
                ChecklistItem(
                    title: "Battens Main / Грот с латами",
                    note: "Грот - откройте руками легко, ткань без надрывов, швы не расходятся, шкотовый угол без надрывов, шкоты надежно закреплены, нижняя шкаторина без надрывов, галсовый угол надежно закреплен, задняя шкаторина без надрывов, корд по задней надежно закреплен, ликтрос без надрывов, особенно снизу, фал без надрывов, надежно закреплен, закрывается руками легко"
                ),
                ChecklistItem(
                    title: "Furling Main / Грот с закруткой",
                    note: "Грот с закруткой - откройте руками легко, ткань без надрывов, швы не расходятся, шкотовый угол без надрывов, шкоты надежно закреплены, нижняя шкаторина без надрывов, галсовый угол надежно закреплен, задняя шкаторина без надрывов, корд по задней надежно закреплен, ликтрос без надрывов, особенно снизу, фал без надрывов, надежно закреплен, закрывается руками легко"
                )
            ]
        ),
        ChecklistSection(
            title: "Optional Equipment / Дополнительное оборудование",
            items: [
                ChecklistItem(
                    title: "Generator / Генератор",
                    note: "Генератор - узнайте у представителя чартерной компании: как правильно запускать и останавливать, как переключать лодку на генератор или береговое питание"
                ),
                ChecklistItem(
                    title: "Air conditioner / Кондиционер",
                    note: "Кондиционер - проверьте кран трубы забортного охлаждения, перед включением убедитесь, что он открыт"
                ),
                ChecklistItem(
                    title: "Watermaker / Опреснитель",
                    note: "Опреснитель - не используйте в марине, узнайте у представителя чартерной компании, как правильно запускать и использовать"
                )
            ]
        ),
        ChecklistSection(
            title: "Safety Equipment Check / Безопасность",
            items: [
                ChecklistItem(
                    title: "Life jackets / Спасательные жилеты",
                    note: "Спасательные жилеты - количество, попросите в чартерной детские жилеты, если в экипаже есть дети, состояние баллонов, если жилеты надувные"
                ),
                ChecklistItem(
                    title: "Safety harnesses / Страховочные обвязки",
                    note: "Страховочные обвязки - количество, стропы с карабинами, карабины исправны"
                ),
                ChecklistItem(
                    title: "Life raft / Спасательный плот",
                    note: "Спасательный плот - проверьте дату последнего осмотра, проверьте надежность и метод крепления плота"
                ),
                ChecklistItem(
                    title: "Life ring/horseshoe / Спасательный круг и MOB маячок",
                    note: "Спасательный круг и MOB маячок - проверьте исправность лампочки"
                ),
                ChecklistItem(
                    title: "Visual Distress signals / Пиротехника",
                    note: "Пиротехника - расположение, количество, срок годности"
                ),
                ChecklistItem(
                    title: "Fire extinguishers / Огнетушители",
                    note: "Огнетушители - расположение, тип, количество, срок годности"
                ),
                ChecklistItem(
                    title: "Smoke and CO detectors (if any) / Датчики дыма и CO (если есть)",
                    note: "Датчики дыма и CO (если есть) - расположение"
                ),
                ChecklistItem(
                    title: "First aid kit / Аптечка",
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
                    title: "Ask for list of required documents for state authorities / Уточните список необходимых документов для госорганов",
                    note: "Уточните список необходимых документов для госорганов"
                ),
                ChecklistItem(
                    title: "Write down contacts / Запишите контакты",
                    note: "Запишите контакты чартерной, спасательных служб и береговой охраны"
                )
            ]
        )
    ]
}
