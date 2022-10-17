import SwiftUI
import CoreData

struct SessionView: View {
    @State var session: Session
    
    var body: some View {
        Form {
            HStack {
                Text("Spot")
                Spacer()
                Text(session.location)
            }
            
            HStack {
                Text("Wann")
                Spacer()
                Text(toString(from: session.date))
                    .font(.subheadline)
            }
            
            HStack {
                Text("Aktivität")
                Spacer()
                Text(session.name)
                    .font(.subheadline)
            }
            
            let distance = Measurement(
                value: session.distance,
                unit: UnitLength.meters
            ).formatted(
                .measurement(width: .abbreviated,
                             usage: .road)
            )
            HStack {
                Text("Distanz")
                Spacer()
                Text(distance)
                    .font(.subheadline)
            }
            
            
            let maxSpeed = Measurement(
                value: session.maxspeed,
                unit: UnitSpeed.metersPerSecond
            ).formatted(
            )
            HStack {
                Text("Max")
                Spacer()
                Text(maxSpeed)
                    .font(.subheadline)
            }
            HStack {
                Text("Dauer")
                Spacer()
                DurationView(duration: session.duration)
                    .font(.subheadline)
            }
            
        }
        .navigationTitle("Deine Session")
    }
}
