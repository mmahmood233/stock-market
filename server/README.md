# Stock Market WebSocket Server

Mock WebSocket server for the stock market simulation app.

## Features

- ✅ WebSocket server on `ws://localhost:8080`
- ✅ Real-time updates every 200ms (5 times per second)
- ✅ 20 stocks monitored (AAPL, GOOGL, MSFT, etc.)
- ✅ Simulated price movements (±1% per update)
- ✅ Complete stock data (price, volume, high/low, etc.)

## Installation

```bash
cd server
npm install
```

## Running the Server

```bash
npm start
```

Or directly:

```bash
node stock_server.js
```

## Output

You should see:
```
📈 Stock Market WebSocket Server running on ws://localhost:8080
📊 Monitoring 20 stocks
⚡ Updates every 200ms (5 times per second)
🚀 Server ready! Connect your Flutter app now.
```

## Data Format

Each update sends an array of stock objects:

```json
[
  {
    "symbol": "AAPL",
    "name": "Apple Inc.",
    "currentPrice": 178.50,
    "changeAmount": 0.70,
    "changePercentage": 0.39,
    "previousClose": 177.80,
    "dayHigh": 179.20,
    "dayLow": 177.30,
    "volume": 45678900,
    "lastUpdated": "2026-02-17T08:43:00.000Z"
  },
  ...
]
```

## Testing

Once the server is running:
1. Open your Flutter app
2. The Market tab should load with 20 stocks
3. Prices should update 5+ times per second
4. You should see real-time price changes

## Stopping the Server

Press `Ctrl+C` in the terminal running the server.
