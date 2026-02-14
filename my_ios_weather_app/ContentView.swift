//
//  ContentView.swift
//  my_ios_weather_app
//

import SwiftUI

struct Raindrop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let speed: CGFloat
    let length: CGFloat
    let opacity: Double
}

struct RainView: View {
    let isRaining: Bool
    @State private var raindrops: [Raindrop] = []
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(raindrops) { drop in
                    Capsule()
                        .fill(Color.white.opacity(drop.opacity))
                        .frame(width: 2, height: drop.length)
                        .position(x: drop.x, y: drop.y)
                }
            }
            .onAppear {
                if isRaining {
                    startRain(in: geometry.size)
                }
            }
            .onChange(of: isRaining) { _, raining in
                if raining {
                    startRain(in: geometry.size)
                } else {
                    stopRain()
                }
            }
            .onDisappear {
                stopRain()
            }
        }
    }
    
    private func startRain(in size: CGSize) {
        stopRain()
        
        raindrops = (0..<100).map { _ in
            Raindrop(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -size.height...size.height),
                speed: CGFloat.random(in: 8...15),
                length: CGFloat.random(in: 15...30),
                opacity: Double.random(in: 0.2...0.5)
            )
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            for i in raindrops.indices {
                raindrops[i].y += raindrops[i].speed
                if raindrops[i].y > size.height + 50 {
                    raindrops[i].y = -50
                    raindrops[i].x = CGFloat.random(in: 0...size.width)
                }
            }
        }
    }
    
    private func stopRain() {
        timer?.invalidate()
        timer = nil
        raindrops = []
    }
}

struct WeatherCondition: Identifiable {
    let id = UUID()
    let day: String
    let icon: String
    let highTemp: Int
    let lowTemp: Int
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let hour: String
    let icon: String
    let temp: Int
    let precipChance: Int
}

struct ContentView: View {
    @State private var currentTemp: Int = 72
    @State private var feelsLike: Int = 74
    @State private var condition: String = "Partly Cloudy"
    @State private var location: String = "San Francisco"
    @State private var iconName: String = "cloud.sun.fill"
    @State private var humidity: Int = 65
    @State private var windSpeed: Int = 12
    @State private var uvIndex: Int = 4
    @State private var lastUpdated: Date = Date()
    @State private var isRefreshing: Bool = false

    let forecast: [WeatherCondition] = [
        WeatherCondition(day: "Mon", icon: "sun.max.fill", highTemp: 75, lowTemp: 58),
        WeatherCondition(day: "Tue", icon: "cloud.sun.fill", highTemp: 72, lowTemp: 55),
        WeatherCondition(day: "Wed", icon: "cloud.rain.fill", highTemp: 65, lowTemp: 52),
        WeatherCondition(day: "Thu", icon: "cloud.bolt.rain.fill", highTemp: 62, lowTemp: 50),
        WeatherCondition(day: "Fri", icon: "sun.max.fill", highTemp: 78, lowTemp: 60),
    ]
    
    let hourlyForecast: [HourlyForecast] = [
        HourlyForecast(hour: "Now", icon: "cloud.sun.fill", temp: 72, precipChance: 0),
        HourlyForecast(hour: "3PM", icon: "sun.max.fill", temp: 74, precipChance: 0),
        HourlyForecast(hour: "4PM", icon: "sun.max.fill", temp: 75, precipChance: 5),
        HourlyForecast(hour: "5PM", icon: "cloud.sun.fill", temp: 73, precipChance: 10),
        HourlyForecast(hour: "6PM", icon: "cloud.fill", temp: 70, precipChance: 20),
        HourlyForecast(hour: "7PM", icon: "cloud.fill", temp: 68, precipChance: 25),
        HourlyForecast(hour: "8PM", icon: "cloud.moon.fill", temp: 66, precipChance: 30),
        HourlyForecast(hour: "9PM", icon: "cloud.moon.rain.fill", temp: 64, precipChance: 60),
        HourlyForecast(hour: "10PM", icon: "cloud.rain.fill", temp: 62, precipChance: 80),
        HourlyForecast(hour: "11PM", icon: "cloud.rain.fill", temp: 61, precipChance: 75),
        HourlyForecast(hour: "12AM", icon: "cloud.moon.fill", temp: 60, precipChance: 40),
        HourlyForecast(hour: "1AM", icon: "moon.stars.fill", temp: 58, precipChance: 10),
    ]
    
    var timeAgoText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }

    private func refreshWeather() async {
        isRefreshing = true

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Simulate weather data update with slight variations
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTemp = Int.random(in: 68...76)
            feelsLike = currentTemp + Int.random(in: 0...4)
            humidity = Int.random(in: 55...75)
            windSpeed = Int.random(in: 8...18)
            uvIndex = Int.random(in: 2...6)
            lastUpdated = Date()
        }

        // Success haptic
        let successGenerator = UINotificationFeedbackGenerator()
        successGenerator.notificationOccurred(.success)

        isRefreshing = false
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.6, blue: 0.9),
                Color(red: 0.2, green: 0.4, blue: 0.8),
                Color(red: 0.1, green: 0.2, blue: 0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var isRainyCondition: Bool {
        let rainyKeywords = ["rain", "rainy", "drizzle", "shower", "storm", "thunderstorm"]
        return rainyKeywords.contains { condition.lowercased().contains($0) }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            if isRainyCondition {
                RainView(isRaining: true)
                    .ignoresSafeArea()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Location Header
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "location.fill")
                                .font(.subheadline)
                            Text(location)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        HStack(spacing: 4) {
                            if isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.7)))
                                    .scaleEffect(0.7)
                                Text("Updating...")
                            } else {
                                Text("Updated \(timeAgoText)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Main Weather Display
                    VStack(spacing: 8) {
                        Image(systemName: iconName)
                            .font(.system(size: 100))
                            .symbolRenderingMode(.multicolor)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        
                        Text("\(currentTemp)°")
                            .font(.system(size: 84, weight: .thin))
                        
                        Text(condition)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Feels like \(feelsLike)°")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                    
                    // Weather Stats
                    HStack(spacing: 0) {
                        WeatherStatView(icon: "humidity.fill", value: "\(humidity)%", label: "Humidity")
                        Divider()
                            .frame(height: 50)
                            .background(.white.opacity(0.3))
                        WeatherStatView(icon: "wind", value: "\(windSpeed) mph", label: "Wind")
                        Divider()
                            .frame(height: 50)
                            .background(.white.opacity(0.3))
                        WeatherStatView(icon: "sun.max.fill", value: "\(uvIndex)", label: "UV Index")
                    }
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    
                    // Hourly Forecast
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                            Text("HOURLY FORECAST")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(hourlyForecast) { hour in
                                    HourlyForecastView(forecast: hour)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    // 5-Day Forecast
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("5-DAY FORECAST")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in
                                ForecastRowView(forecast: day)
                                if index < forecast.count - 1 {
                                    Divider()
                                        .background(.white.opacity(0.2))
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .refreshable {
                await refreshWeather()
            }
        }
        .foregroundStyle(.white)
    }
}

struct WeatherStatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .symbolRenderingMode(.multicolor)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ForecastRowView: View {
    let forecast: WeatherCondition
    
    var body: some View {
        HStack {
            Text(forecast.day)
                .font(.body)
                .fontWeight(.medium)
                .frame(width: 50, alignment: .leading)
            
            Image(systemName: forecast.icon)
                .font(.title2)
                .symbolRenderingMode(.multicolor)
                .frame(width: 40)
            
            Spacer()
            
            HStack(spacing: 16) {
                Text("L: \(forecast.lowTemp)°")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                Text("H: \(forecast.highTemp)°")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct HourlyForecastView: View {
    let forecast: HourlyForecast
    
    var body: some View {
        VStack(spacing: 8) {
            Text(forecast.hour)
                .font(.subheadline)
                .fontWeight(forecast.hour == "Now" ? .semibold : .regular)
            
            Image(systemName: forecast.icon)
                .font(.title2)
                .symbolRenderingMode(.multicolor)
                .frame(height: 30)
            
            if forecast.precipChance > 0 {
                Text("\(forecast.precipChance)%")
                    .font(.caption2)
                    .foregroundStyle(.cyan)
            } else {
                Text(" ")
                    .font(.caption2)
            }
            
            Text("\(forecast.temp)°")
                .font(.title3)
                .fontWeight(.medium)
        }
        .frame(width: 60)
    }
}

#Preview {
    ContentView()
}
