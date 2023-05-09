//
//  SessionDetailView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 19.01.23.
//

import SwiftUI
import MapKit

struct SessionDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var session: SessionEntity
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default)
    private var spots: FetchedResults<LocationEntity>
    
    struct Location: Identifiable {
        let id = UUID()
        let coordinate: CLLocation
    }
    
    let locations = [
        Location(coordinate: CLLocation(latitude: 54.499998, longitude: 11.2166658)),
        Location(coordinate: CLLocation(latitude: 54.518, longitude: 11.0904))
    ]
    
    var body: some View {
        Form {
            if editMode?.wrappedValue.isEditing == true {
                EditEntityPickerView(title: "Spot", selection: $session.spot, values: spots)
                EditStringPickerView(title: "Sport", selection: $session.name)
                EditDateView(title: "When", date: $session.date)
                EditDoubleFieldView(title: "Distance", value: $session.distance, unit: "m")
                EditDoubleFieldView(title: "Max Speed", value: $session.maxspeed, unit: "km/h")
                EditDurationView(title: "Duration", value: $session.duration, unit: "minutes")
            } else {
                DetailView(title: "Spot", value: session.spot?.name ?? "Unknwon")
                DetailView(title: "Sport", value: session.name)
                DetailView(title: "When", value: toString(from: session.date ?? Date()))
                let distance = Measurement(value: session.distance, unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated, usage: .road))
                DetailView(title: "Distance", value: distance)
                let maxSpeed = Measurement(value: session.maxspeed, unit: UnitSpeed.metersPerSecond)
                    .formatted()
                DetailView(title: "Max Speed", value: maxSpeed)
                HStack {
                    Text("Duration")
                    Spacer()
                    DurationView(duration: session.duration)
                }
            }
            
            MapView(region: MKCoordinateRegion(
                center: locations[0].coordinate.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)), lineCoordinates: locations.map( {
                    l in return l.coordinate.coordinate
                }))
            .frame(height: 200)
            
        }
        .navigationTitle("Your Session")
        .toolbar{
            EditButton()
        }
        .onChange(of: editMode!.wrappedValue, perform: { value in
            if !value.isEditing {
                session.maxspeed = session.maxspeed / 3.6
                session.duration = session.duration * 60
                try? context.save()
            } else {
                session.maxspeed = session.maxspeed * 3.6
                session.duration = session.duration / 60
            }
        })
    }
    
    func locations(session: SessionEntity) -> [CLLocationCoordinate2D] {
        if let locations = session.locations {
            if let locationsArr = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: locations) as? [CLLocation] {
                return locationsArr.map({l in return l.coordinate})
            }
        }
        return []
    }    
}

struct DetailView: View {
    var title: String
    var value: String?
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if value != nil {
                Text(value!)
            }
        }
    }
}

struct EditDoubleFieldView: View {
    var title: String
    var value: Binding<Double>
    var unit: String
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: value, formatter: formatter).multilineTextAlignment(.trailing)
            Text(unit)
        }
    }
}

struct EditDurationView: View {
    var title: String
    var value: Binding<Double>
    var unit: String
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: value, formatter: formatter).multilineTextAlignment(.trailing)
            Text(unit)
        }
    }
}

struct EditEntityPickerView: View {
    var title: String
    var selection: Binding<LocationEntity?>
    var values: FetchedResults<LocationEntity>
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let selection = Binding<LocationEntity>(selection) {
                Picker(title, selection: selection) {
                    ForEach(values, id: \.self) { s in
                        Text(s.name!)
                    }
                }
            }
        }
    }
}

struct EditStringPickerView: View {
    var title: String
    var selection: Binding<String?>
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let selection = Binding<String>(selection) {
                Picker(title, selection: selection) {
                    ForEach(Constants.SPORTS, id: \.self) { s in
                        Text(s)
                    }
                }
            }
        }
    }
}

struct EditDateView: View {
    var title: String
    var date: Binding<Date?>
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let date = Binding<Date>(date) {
                DatePicker("", selection: date, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: "de_DE"))
            }
        }
    }
}
