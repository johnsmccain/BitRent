# 🏠 BitRent - Fractional Bitcoin-Backed Rental dApp

> **Stacks Vibe Coding Hackathon Project**

BitRent is a decentralized application that enables fractional ownership of rental properties using Bitcoin-backed NFTs on the Stacks blockchain.

## 🎯 Features

- **Fractional Property Ownership**: Buy and sell fractions of rental properties as NFTs
- **Stacks Wallet Integration**: Connect with your Stacks wallet for seamless transactions
- **AI-Powered Fraud Detection**: Validate property documents and images
- **Revenue Distribution**: Automatic rent distribution to NFT holders
- **Marketplace**: Browse and invest in fractional properties
- **AI Chatbot**: Get insights about investment returns and property analysis

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Smart        │
│   (Next.js)     │◄──►│   (Node.js)     │◄──►│   Contracts    │
│                 │    │   (Express)     │    │   (Clarity)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Stacks       │    │   PostgreSQL    │    │   Stacks       │
│   Wallet       │    │   (Prisma)      │    │   Testnet      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Tech Stack

- **Frontend**: Next.js 15, TailwindCSS, TypeScript, ShadCN/UI
- **Wallet**: @stacks/connect-react
- **Backend**: Node.js, Express, Prisma ORM
- **Database**: PostgreSQL
- **Blockchain**: Stacks (Clarity smart contracts)
- **AI**: Claude/OpenAI integration for fraud detection and chatbot

## 📁 Project Structure

```
bitrent/
├── apps/
│   ├── frontend/          # Next.js frontend application
│   ├── backend/           # Express backend API
│   └── contracts/         # Clarity smart contracts
├── packages/
│   ├── shared/            # Shared types and utilities
│   └── ui/                # Reusable UI components
├── turbo.json             # Turborepo configuration
└── package.json           # Root package.json
```

## 🛠️ Quick Start

### Prerequisites

- Node.js 18+
- npm 10+
- PostgreSQL
- Stacks wallet (Hiro or Xverse)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bitrent
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your configuration
   ```

4. **Start development servers**
   ```bash
   npm run dev
   ```

### Environment Variables

Create a `.env.local` file in the root directory:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/bitrent"

# Stacks
STACKS_NETWORK="testnet"
STACKS_API_URL="https://api.testnet.hiro.so"

# AI Services
OPENAI_API_KEY="your-openai-api-key"
ANTHROPIC_API_KEY="your-anthropic-api-key"

# JWT Secret
JWT_SECRET="your-jwt-secret"
```

## 🧪 Testing

```bash
# Run all tests
npm run test

# Run tests for specific package
npm run test --workspace=apps/contracts
```

## 🚀 Deployment

### Smart Contracts
- Deploy to Stacks testnet using Clarinet

### Backend
- Deploy to Railway or Render
- Set up PostgreSQL on Supabase

### Frontend
- Deploy to Vercel
- Configure environment variables

## 📚 Documentation

- [Smart Contract Architecture](./apps/contracts/README.md)
- [API Documentation](./apps/backend/README.md)
- [Frontend Components](./apps/frontend/README.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

## 🏆 Hackathon Submission

This project was built for the **Stacks Vibe Coding Hackathon** and demonstrates:
- Fractional ownership using NFTs
- Real-time blockchain integration
- AI-powered fraud detection
- Modern web3 user experience
- Production-ready architecture

---

**Built with ❤️ for the Stacks community**
