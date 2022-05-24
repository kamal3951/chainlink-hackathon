import '../styles/globals.css'
import { TransactionProvider } from '../context/TransactionContext'
import { MoralisProvider } from 'react-moralis'

function MyApp({ Component, pageProps }) {
  return (
    <MoralisProvider
      appId="0Hvg7s3GkosqLnJz2Zhn2cNzUnjrJCAJioaFQGVJ"
      serverUrl="https://fkf53bqkcrqn.usemoralis.com:2053/server"
    >
      <TransactionProvider>
        <Component {...pageProps} />
      </TransactionProvider>
    </MoralisProvider>
  )
}

export default MyApp
