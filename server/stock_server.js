const WebSocket = require('ws');

const PORT = 8080;
const UPDATE_INTERVAL = 200; // 5 times per second

// Stock data with initial prices
const stocks = {
  'AAPL': { name: 'Apple Inc.', price: 178.50, previousClose: 177.80 },
  'GOOGL': { name: 'Alphabet Inc.', price: 141.20, previousClose: 140.50 },
  'MSFT': { name: 'Microsoft Corporation', price: 378.90, previousClose: 377.20 },
  'AMZN': { name: 'Amazon.com Inc.', price: 151.30, previousClose: 150.80 },
  'TSLA': { name: 'Tesla Inc.', price: 242.80, previousClose: 245.10 },
  'META': { name: 'Meta Platforms Inc.', price: 484.50, previousClose: 482.30 },
  'NVDA': { name: 'NVIDIA Corporation', price: 875.20, previousClose: 870.50 },
  'NFLX': { name: 'Netflix Inc.', price: 598.70, previousClose: 595.40 },
  'AMD': { name: 'Advanced Micro Devices', price: 162.40, previousClose: 161.80 },
  'INTC': { name: 'Intel Corporation', price: 43.20, previousClose: 43.50 },
  'ORCL': { name: 'Oracle Corporation', price: 127.80, previousClose: 126.90 },
  'IBM': { name: 'IBM Corporation', price: 186.50, previousClose: 185.70 },
  'CSCO': { name: 'Cisco Systems Inc.', price: 51.30, previousClose: 51.10 },
  'ADBE': { name: 'Adobe Inc.', price: 562.40, previousClose: 560.20 },
  'CRM': { name: 'Salesforce Inc.', price: 284.60, previousClose: 283.50 },
  'PYPL': { name: 'PayPal Holdings Inc.', price: 62.80, previousClose: 63.20 },
  'UBER': { name: 'Uber Technologies Inc.', price: 71.40, previousClose: 70.90 },
  'LYFT': { name: 'Lyft Inc.', price: 14.20, previousClose: 14.50 },
  'SNAP': { name: 'Snap Inc.', price: 11.80, previousClose: 12.10 },
  'SPOT': { name: 'Spotify Technology', price: 298.50, previousClose: 296.80 }
};

// Generate random price change
function getRandomChange(currentPrice) {
  const changePercent = (Math.random() - 0.5) * 0.02; // ±1% max change
  return currentPrice * changePercent;
}

// Generate stock data
function generateStockData(symbol, data) {
  const change = getRandomChange(data.price);
  data.price = Math.max(data.price + change, 0.01); // Ensure price stays positive
  
  const changeAmount = data.price - data.previousClose;
  const changePercentage = (changeAmount / data.previousClose) * 100;
  
  // Simulate day high/low
  const dayHigh = data.price * (1 + Math.random() * 0.02);
  const dayLow = data.price * (1 - Math.random() * 0.02);
  
  return {
    symbol,
    name: data.name,
    price: parseFloat(data.price.toFixed(2)),
    previousClose: parseFloat(data.previousClose.toFixed(2)),
    dayHigh: parseFloat(dayHigh.toFixed(2)),
    dayLow: parseFloat(dayLow.toFixed(2)),
    volume: Math.floor(Math.random() * 100000000) + 10000000,
    timestamp: new Date().toISOString()
  };
}

// Create WebSocket server - bind to all interfaces
const wss = new WebSocket.Server({ 
  port: PORT,
  host: '0.0.0.0'
});

console.log(`📈 Stock Market WebSocket Server running on ws://0.0.0.0:${PORT}`);
console.log(`📊 Monitoring ${Object.keys(stocks).length} stocks`);
console.log(`⚡ Updates every ${UPDATE_INTERVAL}ms (${1000/UPDATE_INTERVAL} times per second)`);

wss.on('connection', (ws) => {
  console.log('✅ New client connected');
  
  // Send initial data for all stocks
  const initialData = Object.keys(stocks).map(symbol => 
    generateStockData(symbol, stocks[symbol])
  );
  ws.send(JSON.stringify(initialData));
  
  // Send updates every 200ms
  const interval = setInterval(() => {
    if (ws.readyState === WebSocket.OPEN) {
      const updates = Object.keys(stocks).map(symbol => 
        generateStockData(symbol, stocks[symbol])
      );
      ws.send(JSON.stringify(updates));
    }
  }, UPDATE_INTERVAL);
  
  ws.on('close', () => {
    console.log('❌ Client disconnected');
    clearInterval(interval);
  });
  
  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
    clearInterval(interval);
  });
});

wss.on('error', (error) => {
  console.error('Server error:', error);
});

console.log('\n🚀 Server ready! Connect your Flutter app now.\n');
