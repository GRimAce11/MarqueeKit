import SwiftUI
import MarqueeKit

struct StockQuote: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double
    let change: Double
    var isPositive: Bool { change >= 0 }
}

struct CryptoQuote: Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double
    let change24h: Double
    var isPositive: Bool { change24h >= 0 }
}

struct TickerDemoView: View {

    private let stocks = [
        StockQuote(symbol: "AAPL", price: 192.40, change: 1.2),
        StockQuote(symbol: "MSFT", price: 415.00, change: 0.8),
        StockQuote(symbol: "GOOGL", price: 175.20, change: -0.3),
        StockQuote(symbol: "AMZN", price: 185.60, change: 2.1),
        StockQuote(symbol: "META", price: 487.90, change: -1.4),
    ]

    private let crypto = [
        CryptoQuote(symbol: "BTC", price: 67_840, change24h: 3.2),
        CryptoQuote(symbol: "ETH", price: 3_520, change24h: -1.8),
        CryptoQuote(symbol: "SOL", price: 182, change24h: 5.4),
        CryptoQuote(symbol: "XRP", price: 0.64, change24h: 0.9),
    ]

    private let newsHeadlines = [
        "Apple reports record quarterly revenue",
        "Federal Reserve holds interest rates steady",
        "New climate accord signed by 140 countries",
        "SpaceX completes sixth Starship test flight",
    ]

    var body: some View {
        List {
            Section("Stock quotes") {
                MarqueeTicker(stocks) { quote in
                    HStack(spacing: 6) {
                        Text(quote.symbol)
                            .fontWeight(.bold)
                            .monospacedDigit()
                        Text(quote.price, format: .currency(code: "USD"))
                            .monospacedDigit()
                        Text(quote.isPositive ? "+\(quote.change, specifier: "%.1f")%" :
                                "\(quote.change, specifier: "%.1f")%")
                            .foregroundStyle(quote.isPositive ? .green : .red)
                            .font(.caption)
                    }
                }
                .marqueeTheme(.ticker)
                .speed(.medium)
                .fadeEdges(true)
                .frame(height: 32)
            }

            Section("Crypto") {
                MarqueeTicker(crypto, separator: Text("  |  ").foregroundStyle(.tertiary)) { quote in
                    HStack(spacing: 4) {
                        Text(quote.symbol)
                            .fontWeight(.semibold)
                        Text(quote.price, format: .currency(code: "USD"))
                            .monospacedDigit()
                            .font(.caption)
                        Image(systemName: quote.isPositive ? "arrow.up" : "arrow.down")
                            .foregroundStyle(quote.isPositive ? .green : .red)
                            .font(.caption2)
                    }
                }
                .speed(.slow)
                .fadeEdges(true, width: 30)
                .frame(height: 28)
            }

            Section("News headlines (strings)") {
                MarqueeTicker(newsHeadlines)
                    .speed(.slow)
                    .fadeEdges(true)
                    .frame(height: 24)
            }
        }
        .navigationTitle("MarqueeTicker")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { NavigationStack { TickerDemoView() } }
