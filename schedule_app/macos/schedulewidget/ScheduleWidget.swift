//
//  ScheduleWidget.swift
//  ScheduleWidget
//
//  Created by randzhu on 2023/12/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Schedule: Decodable {
    let startTime: Int
    let endTime: Int
    let isAllDay: Bool
    let title: String
    let subtitle: String
}

struct ScheduleView: View {
    let schedules: [Schedule]
    let margin: CGFloat;
    
    @Environment(\.widgetFamily) var family:WidgetFamily

    var body: some View {
        GeometryReader { geometry in
            let macOSTitleBarColor = Color(red: 38.0/255.0, green: 38.0/255.0, blue: 38.0/255.0)
            let date = Date()
            let calendar = Calendar.current
            let dateString = calendar.component(.day, from: date)
            let weekday = calendar.component(.weekday, from: date)
            let weekdayString = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday - 1]
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center){
                    Text(String(dateString))
                        .padding(EdgeInsets(top: 5, leading: 16, bottom: 0, trailing: 0))
                        .font(.system(size: 25, weight: .light, design: .default))
                    Text(weekdayString).padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                }
                if schedules.isEmpty {
                    GeometryReader{ geometry1 in
                        ZStack(alignment: .center){
                            Text("暂无日程").font(.headline)
                        }.frame(width: geometry1.size.width, height: geometry1.size.height-30, alignment: .center)
                    }
                } else {
                    let maxCount = family == .systemLarge ? 8 : 3
                    let showSchedules = Array(schedules.prefix(maxCount))
                    let leftSpace = CGFloat(geometry.size.height - CGFloat(50 * showSchedules.count) - 30)
                    ForEach(showSchedules, id: \.title) { schedule in
                        scheduleView(schedule: schedule)
                    }
                    if(maxCount < schedules.count){ 
                        Text("+" + String(schedules.count - maxCount) + " more schedules")
                            .padding(EdgeInsets(top: 3, leading: 10, bottom: 7, trailing: 0))
                            .font(.system(size: 10, weight: .light, design: .default))
                    }else {
                        Spacer(minLength: leftSpace+20)
                    }
              
                }
            }
            .padding(0)
            .background(macOSTitleBarColor)
            .position(x: geometry.size.width/2, y: geometry.size.height/2)
            .frame(width: geometry.size.width+margin, height: geometry.size.height+margin, alignment: .top)
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
    
    func scheduleView(schedule: Schedule) -> some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    if !schedule.isAllDay {
                        let startTimeTimestamp: TimeInterval = Double(schedule.startTime)
                        let startDate = Date(timeIntervalSince1970: startTimeTimestamp)
                        
                        let endTimeTimestamp: TimeInterval = Double(schedule.endTime)
                        let endDate = Date(timeIntervalSince1970: endTimeTimestamp)
                        
                        let calendar = Calendar.current
                        let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
                        let startFormattedDate = String(format: "%02d:%02d", startComponents.hour!, startComponents.minute!)
                        
                        let endComponents = calendar.dateComponents([.hour, .minute], from: endDate)
                        let endFormattedDate = String(format: "%02d:%02d", endComponents.hour!, endComponents.minute!)
                        
                        Text(startFormattedDate)
                            .font(.system(size: 12, weight: .light, design: .default))
                            .frame(width: CGFloat(34))
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Text(endFormattedDate)
                            .font(.system(size: 12, weight: .light, design: .default))
                            .frame(width: CGFloat(34))
                            .fixedSize(horizontal: true, vertical: false)
                    }else{
                        Text("全天")
                            .font(.system(size: 12, weight: .light, design: .default))
                            .frame(width: CGFloat(34))
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2)
                VStack(alignment: .leading) {
                    Text(schedule.title)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                    if !schedule.subtitle.isEmpty {
                        Text(schedule.subtitle)
                            .font(.system(size: 11, weight: .light, design: .default))
                    }
                }
            }
            .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 5))
            .frame(maxWidth: .infinity, maxHeight: CGFloat(40), alignment: .leading)
        }
    }
}

struct EmptyView: View {
    var body: some View {
        Text("暂无日程").font(.headline)
    }
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let schedules: [Schedule]
}

struct ScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), schedules: [])
    }
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        let entry = ScheduleEntry(date: Date(), schedules: loadSchedulesFromJSON())
        completion(entry)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        let entry = ScheduleEntry(date: Date(), schedules: loadSchedulesFromJSON())
     //   debugPrint(entry.schedules)
        let currentDate = Date()
        let updateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(updateDate))
        completion(timeline)
    }
}

func loadSchedulesFromJSON() -> [Schedule] {
    let sharedDefaults = UserDefaults(suiteName: "groupdata")
    let jsonData = sharedDefaults?.string(forKey: "schedule")
    if jsonData != nil {
        let data = Data(jsonData!.utf8)
        let decoder = JSONDecoder()
        if let schedules = try? decoder.decode([Schedule].self, from: data) {
            let currentDate = Date()
            let filteredSchedules = schedules.filter { schedule in
                return schedule.isAllDay || schedule.endTime > Int(currentDate.timeIntervalSince1970)
            }
            return filteredSchedules.sorted { $0.startTime < $1.startTime }
        } else {
            return []
        }
    }
    return []
}

@main
struct ScheduleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ScheduleWidget", provider: ScheduleProvider()) { entry in
            if #available(macOSApplicationExtension 14.0, *){
                ScheduleView(schedules: entry.schedules, margin: 32)
                    .padding(0)
                    .contentMargins(0)
                    .containerBackground(.windowBackground, for: .widget)
            }else{
               ScheduleView(schedules: entry.schedules, margin: 0)
            }
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("日程")
        .description("日程展示")
    }
}
